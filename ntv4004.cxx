// Console host for the Intel 4004 and 4040. Build with i4004.cxx (C++11 or later).
// Windows: cl /EHsc /O2 ntv4004.cxx i4004.cxx
// Linux/macOS: c++ -std=c++11 -O2 ntv4004.cxx i4004.cxx -o ntv4004

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <signal.h>
#include <algorithm>
#include <chrono>
#include <thread>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <sstream>
#ifdef _WIN32
#define NOMINMAX
#include <windows.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#else
#include <unistd.h>
#include <termios.h>
#include <poll.h>
#endif
#include "i4004.hxx"

// The 4004's 740 kHz clock: an instruction cycle of 8 clock periods is 10.8 microseconds.
static const unsigned g_originalClockHz = 740000;
static const unsigned g_consolePort = 15, g_statusPort = 14; // ROM I/O ports, selected by SRC
static bool g_showPorts = false;                               // -o: print other port writes as lamps
static uint64_t g_interruptPeriod = 0, g_nextInterrupt = 0;    // -I: a 4040 timer interrupt every so many cycles
uint8_t rom[ 8192 ];
static I4004 cpu;
static CTrace tracer;
static FILE * g_input = stdin;
static volatile sig_atomic_t g_stopped = 0;
static bool g_eof = false;
static int g_pendingInput = -1;
static bool g_inputEof = false;
static int g_outputHigh = -1; // console characters are written high nibble first
static int g_inputLow = -1;   // and read high nibble first
static uint32_t g_loadedEnd = 0; // one past the highest loaded address

// Map addresses are hexadecimal, independent of command-line number syntax.
static std::map< uint16_t, std::string > g_symbols;

static const char * symbol_lookup( uint16_t address, uint16_t & offset )
{
    auto found = g_symbols.upper_bound( address );
    if ( found == g_symbols.begin() ) return 0;
    --found;
    offset = address - found->first;
    return found->second.c_str();
} //symbol_lookup

static bool load_symbols( const char * path )
{
    std::ifstream input( path );
    if ( !input ) { fprintf( stderr, "can't open symbol map: %s\n", path ); return false; }
    std::string line;
    unsigned lineNumber = 0;
    while ( std::getline( input, line ) )
    {
        lineNumber++;
        std::istringstream fields( line );
        std::string address, name, extra;
        if ( !( fields >> address ) || '#' == address[ 0 ] ) continue;
        char * end;
        errno = 0;
        unsigned long value = strtoul( address.c_str(), &end, 16 );
        if ( errno || *end || end == address.c_str() || value >= sizeof rom ||
             !( fields >> name ) || ( fields >> extra ) )
        {
            fprintf( stderr, "invalid symbol map %s, line %u\n", path, lineNumber );
            return false;
        }
        g_symbols.emplace( (uint16_t) value, name ); // the first of several names for an address labels it
    }
    return !input.bad();
} //load_symbols

static void on_signal( int ) { g_stopped = 1; }

class ConsoleConfiguration
{
#ifdef _WIN32
    HANDLE output;
    DWORD saved;
    bool changed;
#else
    termios saved;
    bool changed;
#endif
public:
    ConsoleConfiguration()
    {
#ifdef _WIN32
        output = GetStdHandle( STD_OUTPUT_HANDLE );
        changed = GetConsoleMode( output, &saved ) &&
            SetConsoleMode( output, saved | ENABLE_PROCESSED_OUTPUT | ENABLE_VIRTUAL_TERMINAL_PROCESSING );
#else
        changed = false;
        if ( stdin == g_input && isatty( STDIN_FILENO ) && 0 == tcgetattr( STDIN_FILENO, &saved ) )
        {
            termios raw = saved;
            raw.c_lflag &= ~( ICANON | ECHO );
            raw.c_iflag &= ~( ICRNL | INLCR );
            raw.c_cc[ VMIN ] = 1;
            raw.c_cc[ VTIME ] = 0;
            changed = ( 0 == tcsetattr( STDIN_FILENO, TCSANOW, &raw ) );
        }
#endif
    }
    ~ConsoleConfiguration()
    {
#ifdef _WIN32
        if ( changed )
            SetConsoleMode( output, saved );
#else
        if ( changed )
            tcsetattr( STDIN_FILENO, TCSANOW, &saved );
#endif
    }
}; //ConsoleConfiguration

static int read_character()
{
#ifdef _WIN32
    // Read exactly one byte through the CRT descriptor so PeekNamedPipe sees everything else.
    unsigned char ch;
    return 1 == _read( _fileno( g_input ), &ch, 1 ) ? ch : EOF;
#else
    return fgetc( g_input );
#endif
} //read_character

// A status read never waits, consumes a character, or ends the emulation at EOF.
static bool keyboard_ready()
{
    if ( g_pendingInput >= 0 || g_inputLow >= 0 )
        return true;
    if ( g_inputEof )
        return false;
#ifdef _WIN32
    if ( stdin == g_input && _isatty( _fileno( stdin ) ) )
        return 0 != _kbhit();
    HANDLE input = (HANDLE) _get_osfhandle( _fileno( g_input ) );
    if ( FILE_TYPE_PIPE == GetFileType( input ) )
    {
        DWORD available = 0;
        if ( !PeekNamedPipe( input, 0, 0, 0, &available, 0 ) || !available )
            return false;
    }
    else if ( FILE_TYPE_DISK != GetFileType( input ) )
        return false;
#else
    pollfd input = { fileno( g_input ), POLLIN, 0 };
    if ( poll( &input, 1, 0 ) <= 0 || !( input.revents & ( POLLIN | POLLHUP ) ) )
        return false;
#endif
    g_pendingInput = read_character();
    g_inputEof = ( EOF == g_pendingInput );
    return !g_inputEof;
} //keyboard_ready

static int next_character()
{
    int ch;
    if ( g_pendingInput >= 0 )
    {
        ch = g_pendingInput;
        g_pendingInput = -1;
        return ch;
    }
#ifdef _WIN32
    if ( stdin == g_input && _isatty( _fileno( stdin ) ) )
    {
        while ( !_kbhit() && !g_stopped )
            std::this_thread::sleep_for( std::chrono::milliseconds( 1 ) );
        ch = g_stopped ? EOF : _getch();
        if ( 0 == ch || 0xe0 == ch )
        {
            _getch();
            return 0x7f;
        }
        return ch;
    }
#endif
    return read_character();
} //next_character

uint8_t i4004_rom_input( uint8_t port )
{
    if ( g_statusPort == port )
        return keyboard_ready() ? 1 : 0;
    if ( g_consolePort != port )
    {
        tracer.Trace( "input ROM port %u unmapped, returning 0\n", port );
        return 0;
    }
    if ( g_inputLow >= 0 )
    {
        uint8_t low = (uint8_t) g_inputLow;
        g_inputLow = -1;
        return low;
    }
    int ch = next_character();
    if ( EOF == ch || 3 == ch || 17 == ch )
    {
        g_eof = ( EOF == ch );
        tracer.Trace( "keyboard %s; ending emulation\n", g_eof ? "EOF" : "exit key" );
        cpu.end_emulation();
        return 0;
    }
    if ( '\n' == ch )
        ch = '\r';
    ch &= 0x7f;
    tracer.Trace( "input ROM port %u, character %02x\n", port, ch );
    g_inputLow = ch & 0xf;
    return (uint8_t) ( ch >> 4 );
} //i4004_rom_input

// Print an output port's four lines, bit 3 first: * for 1 and . for 0.
static void show_port( const char * name, uint8_t value )
{
    printf( "%s: %c%c%c%c\n", name, ( value & 8 ) ? '*' : '.', ( value & 4 ) ? '*' : '.', ( value & 2 ) ? '*' : '.',
            ( value & 1 ) ? '*' : '.' );
    fflush( stdout );
} //show_port

void i4004_rom_output( uint8_t port, uint8_t value )
{
    tracer.Trace( "output ROM port %u, value %x%s\n", port, value, port != g_consolePort ? " (unmapped)" : "" );
    if ( port != g_consolePort )
    {
        if ( g_showPorts )
        {
            char name[ 32 ];
            snprintf( name, sizeof name, "ROM port %u", port );
            show_port( name, value );
        }
        return;
    }
    if ( g_outputHigh < 0 )
    {
        g_outputHigh = value;
        return;
    }
    uint8_t ch = (uint8_t) ( ( ( g_outputHigh << 4 ) | value ) & 0x7f );
    g_outputHigh = -1;
    putchar( '\r' == ch ? '\n' : ch );
    fflush( stdout );
} //i4004_rom_output

void i4004_ram_output( uint8_t bank, uint8_t chip, uint8_t value )
{
    tracer.Trace( "output RAM bank %u chip %u port, value %x\n", bank, chip, value );
    if ( g_showPorts )
    {
        char name[ 32 ];
        snprintf( name, sizeof name, "RAM bank %u chip %u", bank, chip );
        show_port( name, value );
    }
} //i4004_ram_output

static int hex_value( const std::string & line, size_t offset )
{
    if ( offset + 2 > line.size() || !isxdigit( (unsigned char) line[ offset ] ) || !isxdigit( (unsigned char) line[ offset + 1 ] ) )
        return -1;
    return (int) strtoul( line.substr( offset, 2 ).c_str(), 0, 16 );
} //hex_value

static bool load_hex( const char * path )
{
    std::ifstream file( path );
    if ( !file )
    {
        fprintf( stderr, "can't open %s\n", path );
        return false;
    }
    std::string line;
    unsigned lineno = 0;
    uint32_t base = 0;
    bool eof = false, data = false;
    while ( std::getline( file, line ) )
    {
        lineno++;
        if ( !line.empty() && '\r' == line.back() )
            line.pop_back();
        size_t colon = line.find_first_not_of( " \t" );
        if ( std::string::npos == colon || eof )
            continue;
        if ( ':' != line[ colon ] )
        {
            fprintf( stderr, "%s line %u: not an Intel HEX record\n", path, lineno );
            return false;
        }
        int count = hex_value( line, colon + 1 ), high = hex_value( line, colon + 3 ), low = hex_value( line, colon + 5 );
        int type = hex_value( line, colon + 7 );
        if ( count < 0 || high < 0 || low < 0 || type < 0 || line.size() < colon + 11 + 2 * count )
        {
            fprintf( stderr, "%s line %u: malformed record\n", path, lineno );
            return false;
        }
        unsigned sum = count + high + low + type;
        std::vector< uint8_t > bytes;
        for ( int i = 0; i <= count; i++ )
        {
            int value = hex_value( line, colon + 9 + 2 * i );
            if ( value < 0 ) { fprintf( stderr, "%s line %u: malformed record\n", path, lineno ); return false; }
            sum += value;
            if ( i < count ) bytes.push_back( (uint8_t) value );
        }
        if ( sum & 0xff )
        {
            fprintf( stderr, "%s line %u: checksum mismatch\n", path, lineno );
            return false;
        }
        if ( 1 == type || ( 0 == type && 0 == count ) ) // MAC4 ends with :0000000000
            eof = true;
        else if ( 0 == type )
        {
            uint32_t address = base + ( high << 8 ) + low;
            if ( address + count > sizeof rom )
            {
                fprintf( stderr, "%s line %u: data beyond the 8K ROM address space\n", path, lineno );
                return false;
            }
            memcpy( rom + address, bytes.data(), count );
            if ( address + count > g_loadedEnd )
                g_loadedEnd = address + count;
            data = true;
        }
        else if ( 2 == type && 2 == count )
            base = (uint32_t) ( ( bytes[ 0 ] << 8 ) | bytes[ 1 ] ) << 4;
        else if ( 4 == type && 2 == count )
            base = (uint32_t) ( ( bytes[ 0 ] << 8 ) | bytes[ 1 ] ) << 16;
        else if ( 3 != type && 5 != type )
        {
            fprintf( stderr, "%s line %u: unsupported record type %d\n", path, lineno, type );
            return false;
        }
    }
    if ( !data )
    {
        fprintf( stderr, "%s: no data records\n", path );
        return false;
    }
    return true;
} //load_hex

static void usage()
{
    printf( "Intel 4004/4040 console machine\n"
            "usage: ntv4004 [options] file.hex [more.hex ...]\n"
            "  -4          emulate the 4040 (default 4004)\n"
            "  -a:address  entry address (default 0)\n"
            "  -l:file     read keyboard input from a file (EOF exits)\n"
            "  -n:cycles   stop after at least this many instruction cycles; failure if not ended\n"
            "  -s:Hz       limit speed to this clock rate (e.g. 740000); 8 clock periods per cycle\n"
            "  -p          report instruction cycles, elapsed time, and the 740 kHz 4004 runtime\n"
            "  -r          report the final CPU state on stderr\n"
            "  -t          enable debug tracing to ntv4004.log (overwrites previous log)\n"
            "  -i          include each instruction in the log; requires -t\n"
            "  -m:file     override automatic adjacent .map files for instruction tracing\n"
            "  -o          show writes to other ROM ports and to RAM output ports as lamps: * on, . off\n"
            "  -I:cycles   4040: request an interrupt every this many instruction cycles; HLT waits for it\n"
            "Numbers use decimal, 0x hex, or leading-zero octal.\n"
            "Console: ROM port 15 (SRC 0F0H) writes or reads a character as two nibbles, high first;\n"
            "ROM port 14 reads 1 when a key is ready. LF input becomes CR, CR output becomes LF.\n"
            "Ctrl-C or Ctrl-Q exits. HLT or a JUN to its own address ends the program successfully,\n"
            "unless a timer interrupt (-I) can still be taken.\n" );
} //usage

static bool number( const char * text, uint64_t & value )
{
    if ( !*text || '-' == *text || isspace( (unsigned char) *text ) )
        return false;
    char * end;
    errno = 0;
    value = strtoull( text, &end, 0 );
    return !errno && !*end;
} //number

// A JUN to its own address is the usual way to stop a 4004 program.
static bool jump_to_self()
{
    uint16_t pc = cpu.pc();
    uint16_t full = ( cpu.romBank1 ? 0x1000 : 0 ) | pc;
    uint8_t op = rom[ full ];
    return 4 == ( op >> 4 ) && ( ( ( op & 0xf ) << 8 ) | rom[ ( full & 0x1000 ) | ( ( pc + 1 ) & 0xfff ) ] ) == pc;
} //jump_to_self

// Whether a timer interrupt can still be taken: one is set up, enabled, and not being served.
static bool interrupt_possible()
{
    return g_interruptPeriod && cpu.interruptEnable && !cpu.interruptAcknowledged;
} //interrupt_possible

// HLT ends the program unless a timer interrupt can end the HLT.
static bool halted_for_good()
{
    return cpu.halted && !interrupt_possible();
} //halted_for_good

static void report_state()
{
    fprintf( stderr, "acc %X carry %u regs ", cpu.acc, cpu.carry ? 1 : 0 );
    for ( unsigned i = 0; i < 16; i++ )
        fputc( "0123456789ABCDEF"[ cpu.r[ i ] ], stderr );
    fputc( ' ', stderr );
    for ( unsigned i = 0; i < 8; i++ )
        fputc( "0123456789ABCDEF"[ cpu.r1[ i ] ], stderr );
    fprintf( stderr, " pc %03X sp %u stack", cpu.pc(), cpu.sp );
    for ( unsigned i = 0; i < 8; i++ )
        fprintf( stderr, " %03X", cpu.stack[ i ] );
    fprintf( stderr, " src %02X cm %u bank %u rombank %u cycles %llu\n", cpu.src, cpu.cm, cpu.registerBank1 ? 1 : 0,
             cpu.romBank1 ? 1 : 0, (unsigned long long) cpu.cycles );
    // Each RAM bank: 16 registers (chip * 4 + register), each 16 main then 4 status characters.
    for ( unsigned bank = 0; bank < 8; bank++ )
    {
        fprintf( stderr, "ram %u ", bank );
        for ( unsigned reg = 0; reg < 16; reg++ )
        {
            for ( unsigned c = 0; c < 16; c++ )
                fputc( "0123456789ABCDEF"[ cpu.ram[ bank ][ reg ][ c ] ], stderr );
            for ( unsigned c = 0; c < 4; c++ )
                fputc( "0123456789ABCDEF"[ cpu.status[ bank ][ reg ][ c ] ], stderr );
        }
        fputc( '\n', stderr );
    }
} //report_state

int main( int argc, char * argv[] )
{
    uint64_t address = 0, limit = 0, hz = 0;
    bool performance = false, trace = false, traceInstructions = false, report = false, options = true;
    I4004::Model model = I4004::model4004;
    std::vector< const char * > files;
    const char * inputPath = 0, * symbolPath = 0;
    for ( int i = 1; i < argc; i++ )
    {
        const char * arg = argv[ i ];
        uint64_t value = 0;
        if ( options && 0 == strcmp( arg, "--" ) ) { options = false; continue; }
        if ( options && ( 0 == strcmp( arg, "--help" ) || 0 == strcmp( arg, "-h" ) ) ) { usage(); return 0; }
        if ( options && 0 == strcmp( arg, "-p" ) ) performance = true;
        else if ( options && 0 == strcmp( arg, "-4" ) ) model = I4004::model4040;
        else if ( options && 0 == strcmp( arg, "-r" ) ) report = true;
        else if ( options && 0 == strcmp( arg, "-o" ) ) g_showPorts = true;
        else if ( options && 0 == strcmp( arg, "-t" ) ) trace = true;
        else if ( options && 0 == strcmp( arg, "-i" ) ) traceInstructions = true;
        else if ( options && 0 == strncmp( arg, "-m:", 3 ) && arg[ 3 ] ) symbolPath = arg + 3;
        else if ( options && 0 == strncmp( arg, "-l:", 3 ) && arg[ 3 ] ) inputPath = arg + 3;
        else if ( options && '-' == *arg )
        {
            const char * colon = strchr( arg, ':' );
            bool valid = colon && number( colon + 1, value );
            if ( valid && 0 == strncmp( arg, "-a:", 3 ) && value < sizeof rom ) address = value;
            else if ( valid && 0 == strncmp( arg, "-n:", 3 ) && value ) limit = value;
            else if ( valid && 0 == strncmp( arg, "-s:", 3 ) && value ) hz = value;
            else if ( valid && 0 == strncmp( arg, "-I:", 3 ) && value ) g_interruptPeriod = g_nextInterrupt = value;
            else { fprintf( stderr, "invalid option: %s\n", arg ); return 1; }
        }
        else
            files.push_back( arg );
    }
    if ( files.empty() ) { usage(); return 1; }
    if ( g_interruptPeriod && I4004::model4040 != model )
    {
        fprintf( stderr, "interrupts (-I) need the 4040 (-4)\n" );
        return 1;
    }
    if ( address >= 0x1000 && I4004::model4040 != model )
    {
        fprintf( stderr, "entry addresses above 0FFFH need the 4040 (-4)\n" );
        return 1;
    }
    if ( !tracer.Enable( trace, "ntv4004.log", true ) )
    {
        fprintf( stderr, "can't create ntv4004.log\n" );
        return 1;
    }
    if ( symbolPath && !load_symbols( symbolPath ) ) return 1;
    if ( !symbolPath && trace && traceInstructions )
    {
        for ( size_t i = 0; i < files.size(); i++ )
        {
            std::string path = files[ i ];
            size_t slash = path.find_last_of( "/\\" ), dot = path.find_last_of( '.' );
            if ( dot != std::string::npos && ( slash == std::string::npos || dot > slash ) ) path.erase( dot );
            path += ".map";
            std::ifstream available( path.c_str() );
            if ( available && !load_symbols( path.c_str() ) ) return 1;
        }
    }
    if ( !g_symbols.empty() ) cpu.set_symbol_lookup( symbol_lookup );
    cpu.set_tracer( &tracer );
    cpu.trace_instructions( traceInstructions );
    tracer.Trace( "Intel %s console, entry %04x, limit %llu, Hz %llu\n", I4004::model4040 == model ? "4040" : "4004",
                  (unsigned) address, (unsigned long long) limit, (unsigned long long) hz );
    for ( size_t i = 0; i < files.size(); i++ )
        if ( !load_hex( files[ i ] ) )
            return 1;
    if ( I4004::model4040 != model && g_loadedEnd > 0x1000 )
    {
        fprintf( stderr, "code above 0FFFH needs the 4040 (-4)\n" );
        return 1;
    }
    if ( inputPath )
    {
        g_input = fopen( inputPath, "rb" );
        if ( !g_input )
        {
            fprintf( stderr, "can't open %s\n", inputPath );
            return 1;
        }
    }
#ifdef _WIN32
    _setmode( _fileno( g_input ), _O_BINARY );
#endif
    setvbuf( g_input, 0, _IONBF, 0 );
    ConsoleConfiguration console;
#ifdef _WIN32
    signal( SIGINT, on_signal );
    signal( SIGTERM, on_signal );
#else
    struct sigaction action = {};
    action.sa_handler = on_signal;
    sigemptyset( &action.sa_mask );
    sigaction( SIGINT, &action, 0 ); // interrupt a blocked keyboard read, too
    sigaction( SIGTERM, &action, 0 );
#endif
    cpu.power_on( model, (uint16_t) address );
    bool selfJump = false;
    auto start = std::chrono::steady_clock::now();
    while ( !halted_for_good() && !cpu.ended && !g_stopped && ( !limit || cpu.cycles < limit ) )
    {
        uint64_t budget = hz ? 128 : 65536;
        for ( uint64_t n = 0; n < budget && !halted_for_good() && !cpu.ended && ( !limit || cpu.cycles < limit ); n++ )
        {
            if ( cpu.halted && !cpu.interruptRequest ) // HLT executes NOPs until the next timer interrupt
                cpu.cycles = std::max( cpu.cycles, g_nextInterrupt );
            if ( g_interruptPeriod && cpu.cycles >= g_nextInterrupt )
            {
                cpu.interruptRequest = true;
                g_nextInterrupt += g_interruptPeriod * ( 1 + ( cpu.cycles - g_nextInterrupt ) / g_interruptPeriod );
            }
            if ( jump_to_self() && !interrupt_possible() ) // a program may idle in a loop while interrupts work
            {
                selfJump = true;
                break;
            }
            cpu.step();
        }
        if ( selfJump )
            break;
        if ( hz )
            std::this_thread::sleep_until( start + std::chrono::duration_cast< std::chrono::steady_clock::duration >(
                std::chrono::duration<double>( 8.0 * double( cpu.cycles ) / double( hz ) ) ) );
    }
    tracer.Trace( "execution ended: %s, pc %04x, %llu cycles\n",
                  cpu.halted ? "halt" : selfJump ? "jump to self" : g_stopped ? "signal" : g_eof ? "input EOF" :
                  cpu.ended ? "host exit" : "cycle limit", cpu.pc(), (unsigned long long) cpu.cycles );
    if ( performance )
    {
        fprintf( stderr, "%llu instruction cycles, %.6f seconds elapsed%s\n", (unsigned long long) cpu.cycles,
                 std::chrono::duration<double>( std::chrono::steady_clock::now() - start ).count(), g_eof ? " (input EOF)" : "" );
        fprintf( stderr, "approximate real %s runtime: %.6f seconds at 740 kHz (excluding I/O waits)\n",
                 I4004::model4040 == model ? "4040" : "4004", 8.0 * double( cpu.cycles ) / g_originalClockHz );
    }
    if ( report )
        report_state();
    if ( stdin != g_input ) fclose( g_input );
    if ( limit && cpu.cycles >= limit && !cpu.halted && !cpu.ended && !selfJump && !g_stopped )
    {
        fprintf( stderr, "cycle limit reached at %03X\n", cpu.pc() );
        return 2;
    }
    return g_stopped ? 130 : 0;
} //main
