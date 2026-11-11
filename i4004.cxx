// Intel 4004 and 4040 instruction set, following the MCS-40 User's Manual
// (November 1974). One instruction cycle is 8 clock periods; one-word
// instructions take one cycle, and two-word instructions and FIN take two.

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "i4004.hxx"

#if defined(_MSC_VER)
#define I4004_INLINE __forceinline
#elif defined(__GNUC__) || defined(__clang__)
#define I4004_INLINE inline __attribute__((always_inline))
#else
#define I4004_INLINE inline
#endif

static const char * const accumulatorGroup[ 16 ] =
    { "CLB", "CLC", "IAC", "CMC", "CMA", "RAL", "RAR", "TCC", "DAC", "TCS", "STC", "DAA", "KBP", "DCL", "?FE", "?FF" };
static const char * const ioGroup[ 16 ] =
    { "WRM", "WMP", "WRR", "WPM", "WR0", "WR1", "WR2", "WR3", "SBM", "RDM", "RDR", "ADM", "RD0", "RD1", "RD2", "RD3" };
static const char * const group4040[ 16 ] =
    { "NOP", "HLT", "BBS", "LCR", "OR4", "OR5", "AN6", "AN7", "DB0", "DB1", "SB0", "SB1", "EIN", "DIN", "RPM", "?0F" };

// KBP converts a one-of-four code to binary; anything else is 15.
static const uint8_t kbp[ 16 ] = { 0, 1, 2, 15, 3, 15, 15, 15, 4, 15, 15, 15, 15, 15, 15, 15 };

void I4004::power_on( Model model, uint16_t address )
{
    memset( ram, 0, sizeof ram );
    memset( status, 0, sizeof status );
    memset( r, 0, sizeof r );
    memset( r1, 0, sizeof r1 );
    memset( stack, 0, sizeof stack );
    m_model = model;
    acc = 0;
    carry = false;
    sp = 0;
    src = 0;
    cm = 0;
    test = false;
    registerBank1 = interruptEnable = false;
    interruptRequest = interruptAcknowledged = m_interruptArmed = false;
    halted = ended = false;
    cycles = 0;
    m_bankDelay = 0;
    m_savedSrc = 0;
    m_savedRegisterBank1 = false;
    stack[ 0 ] = address & 0xfff;
    romBank1 = m_pendingRomBank1 = ( address & 0x1000 ) && model4040 == model;
} //power_on

template<bool plain> I4004_INLINE uint8_t I4004::fetch_decoded()
{
    uint16_t & pc = stack[ sp ];
    uint8_t value = rom[ plain ? ( pc & 0xfff ) : full_address( pc ) ];
    pc = ( pc + 1 ) & 0xfff;
    return value;
}

uint8_t I4004::fetch() { return fetch_decoded<false>(); }

void I4004::push( uint16_t address )
{
    // 4004: three return levels plus the PC; 4040: seven. The deepest is lost on overflow.
    unsigned mask = ( model4040 == m_model ) ? 7 : 3;
    sp = (uint8_t) ( ( sp + 1 ) & mask );
    stack[ sp ] = address & 0xfff;
} //push

void I4004::pop()
{
    unsigned mask = ( model4040 == m_model ) ? 7 : 3;
    sp = (uint8_t) ( ( sp + mask ) & mask );
} //pop

void I4004::add( uint8_t value, bool carryIn )
{
    unsigned sum = acc + ( value & 0xf ) + ( carryIn ? 1 : 0 );
    acc = sum & 0xf;
    carry = sum > 0xf;
} //add

#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable: 4127) // compile-time 4004 specialization in C++11/14
#endif
template<bool plain> I4004_INLINE unsigned I4004::execute_decoded( uint16_t address, uint8_t op )
{
    uint8_t opa = op & 0xf;
    switch ( op >> 4 )
    {
        case 0x0:
            if ( plain || model4004 == m_model || 0 == opa )
                return 1; // NOP; the 4004 decodes the whole row as NOP
            switch ( opa )
            {
                case 0x1: halted = true; return 1;                             // HLT
                case 0x2:                                                       // BBS
                    ret<plain>();
                    src = m_savedSrc;
                    registerBank1 = m_savedRegisterBank1;
                    interruptAcknowledged = false;
                    return 1;
                case 0x3: acc = (uint8_t) ( ( romBank1 ? 8 : 0 ) | cm ); return 1; // LCR
                case 0x4: acc |= read_reg<plain>( 4 ); return 1;                           // OR4
                case 0x5: acc |= read_reg<plain>( 5 ); return 1;                           // OR5
                case 0x6: acc &= read_reg<plain>( 6 ); return 1;                           // AN6
                case 0x7: acc &= read_reg<plain>( 7 ); return 1;                           // AN7
                case 0x8: case 0x9:                                             // DB0, DB1
                    // The bank changes on the third instruction cycle after this one, so a
                    // JUN or JMS right after DB0/DB1 is fetched whole from the old bank.
                    // step() counts this instruction's own cycle against the delay.
                    m_pendingRomBank1 = ( 0x9 == opa );
                    m_bankDelay = 3;
                    return 1;
                case 0xa: registerBank1 = false; return 1;                     // SB0
                case 0xb: registerBank1 = true; return 1;                      // SB1
                case 0xc: interruptEnable = true; return 1;                    // EIN
                case 0xd: interruptEnable = false; return 1;                   // DIN
                case 0xe: acc = 0; return 1;                                    // RPM: no 4289 program RAM is attached
                default: return 1;
            }
        case 0x1: // JCN
        {
            uint8_t target = fetch_decoded<plain>();
            bool jump = ( ( opa & 4 ) && 0 == acc ) || ( ( opa & 2 ) && carry ) || ( ( opa & 1 ) && !test );
            if ( opa & 8 )
                jump = !jump;
            if ( jump ) // the page is that of the next instruction, so JCN at 254-255 jumps to the next page
                stack[ sp ] = ( stack[ sp ] & 0xf00 ) | target;
            return 2;
        }
        case 0x2:
            if ( opa & 1 ) // SRC
            {
                src = read_pair<plain>( opa >> 1 );
                return 1;
            }
            write_pair<plain>( opa >> 1, fetch_decoded<plain>() ); // FIM
            return 2;
        case 0x3:
        {
            // FIN and JIN address the page holding the next instruction: the
            // next page when they sit at the last byte of a page.
            uint16_t page = ( address + 1 ) & 0xf00;
            if ( opa & 1 ) // JIN
            {
                stack[ sp ] = page | read_pair<plain>( opa >> 1 );
                return 1;
            }
            write_pair<plain>( opa >> 1, rom[ plain ? ( page | read_pair<plain>( 0 ) ) : full_address( page | read_pair<plain>( 0 ) ) ] ); // FIN
            return 2;
        }
        case 0x4: // JUN
        {
            uint16_t target = (uint16_t) ( ( opa << 8 ) | fetch_decoded<plain>() );
            stack[ sp ] = target;
            // The fast console loop stops before counting a self-jump, as
            // the host's reference loop does. ROM reads have no side effects.
            return ( plain && target == address ) ? 0 : 2;
        }
        case 0x5: // JMS
        {
            uint16_t target = (uint16_t) ( ( opa << 8 ) | fetch_decoded<plain>() );
            call<plain>( target );
            return 2;
        }
        case 0x6: write_reg<plain>( opa, read_reg<plain>( opa ) + 1 ); return 1; // INC
        case 0x7: // ISZ
        {
            uint8_t target = fetch_decoded<plain>();
            write_reg<plain>( opa, read_reg<plain>( opa ) + 1 );
            if ( 0 != read_reg<plain>( opa ) )
                stack[ sp ] = ( stack[ sp ] & 0xf00 ) | target;
            return 2;
        }
        case 0x8: add( read_reg<plain>( opa ), carry ); return 1;              // ADD
        case 0x9: add( ~read_reg<plain>( opa ), !carry ); return 1;            // SUB: carry is set when there is no borrow
        case 0xa: acc = read_reg<plain>( opa ); return 1;                      // LD
        case 0xb: { uint8_t t = acc; acc = read_reg<plain>( opa ); write_reg<plain>( opa, t ); return 1; } // XCH
        case 0xc: ret<plain>(); acc = opa; return 1;                      // BBL
        case 0xd: acc = opa; return 1;                             // LDM
        case 0xe:
            switch ( opa )
            {
                case 0x0: ram_character() = acc; break;                                  // WRM
                case 0x1: i4004_ram_output( cm, src >> 6, acc ); break;                  // WMP
                case 0x2: i4004_rom_output( src >> 4, acc ); break;                      // WRR
                case 0x3: break;                                                         // WPM: no 4008/4009
                case 0x4: case 0x5: case 0x6: case 0x7: status[ cm ][ src >> 4 ][ opa - 4 ] = acc; break; // WR0-WR3
                case 0x8: add( ~ram_character(), !carry ); break;                        // SBM
                case 0x9: acc = ram_character(); break;                                  // RDM
                case 0xa: acc = i4004_rom_input( src >> 4 ) & 0xf; break;                // RDR
                case 0xb: add( ram_character(), carry ); break;                          // ADM
                default: acc = status[ cm ][ src >> 4 ][ opa - 0xc ]; break;             // RD0-RD3
            }
            return 1;
        default: // 0xf: accumulator group
            switch ( opa )
            {
                case 0x0: acc = 0; carry = false; break;                                  // CLB
                case 0x1: carry = false; break;                                           // CLC
                case 0x2: add( 1, false ); break;                                         // IAC
                case 0x3: carry = !carry; break;                                          // CMC
                case 0x4: acc = ~acc & 0xf; break;                                        // CMA
                case 0x5: { bool out = acc & 8; acc = (uint8_t) ( ( ( acc << 1 ) | ( carry ? 1 : 0 ) ) & 0xf ); carry = out; break; } // RAL
                case 0x6: { bool out = acc & 1; acc = (uint8_t) ( ( acc >> 1 ) | ( carry ? 8 : 0 ) ); carry = out; break; } // RAR
                case 0x7: acc = carry ? 1 : 0; carry = false; break;                      // TCC
                case 0x8: add( 0xf, false ); break;                                       // DAC: carry is set when there is no borrow
                case 0x9: acc = carry ? 10 : 9; carry = false; break;                     // TCS
                case 0xa: carry = true; break;                                            // STC
                case 0xb:                                                                 // DAA
                    if ( carry || acc > 9 )
                    {
                        unsigned sum = acc + 6u;
                        acc = sum & 0xf;
                        if ( sum > 0xf )
                            carry = true; // otherwise carry is unaffected
                    }
                    break;
                case 0xc: acc = kbp[ acc ]; break;                                        // KBP
                case 0xd: cm = acc & 7; break;                                            // DCL
                default: break;                                                           // unassigned: no operation
            }
            return 1;
    }
} //execute
#ifdef _MSC_VER
#pragma warning(pop)
#endif

unsigned I4004::execute( uint16_t address, uint8_t op )
{
    return execute_decoded<false>( address, op );
}

// Expand the same instruction body with a constant opcode and the 4004's
// fixed register/ROM banks. There is no instruction cache: ROM is read afresh.
bool I4004::run_fast4004( uint64_t cycleLimit )
{
    assert( model4004 == m_model && !m_trace && !romBank1 && !registerBank1 );
    while ( !halted && !ended && cycles < cycleLimit )
    {
        uint16_t address = pc() & 0xfff;
        uint8_t op = rom[ address ];
        stack[ sp ] = ( address+1 ) & 0xfff;
        unsigned used;
        switch ( op )
        {
#define FAST_OP(value) case value: \
    used = execute_decoded<true>( address, value ); if ( !used ) return true; break;
            FAST_OP(0x00) FAST_OP(0x01) FAST_OP(0x02) FAST_OP(0x03) FAST_OP(0x04) FAST_OP(0x05) FAST_OP(0x06) FAST_OP(0x07)
            FAST_OP(0x08) FAST_OP(0x09) FAST_OP(0x0a) FAST_OP(0x0b) FAST_OP(0x0c) FAST_OP(0x0d) FAST_OP(0x0e) FAST_OP(0x0f)
            FAST_OP(0x10) FAST_OP(0x11) FAST_OP(0x12) FAST_OP(0x13) FAST_OP(0x14) FAST_OP(0x15) FAST_OP(0x16) FAST_OP(0x17)
            FAST_OP(0x18) FAST_OP(0x19) FAST_OP(0x1a) FAST_OP(0x1b) FAST_OP(0x1c) FAST_OP(0x1d) FAST_OP(0x1e) FAST_OP(0x1f)
            FAST_OP(0x20) FAST_OP(0x21) FAST_OP(0x22) FAST_OP(0x23) FAST_OP(0x24) FAST_OP(0x25) FAST_OP(0x26) FAST_OP(0x27)
            FAST_OP(0x28) FAST_OP(0x29) FAST_OP(0x2a) FAST_OP(0x2b) FAST_OP(0x2c) FAST_OP(0x2d) FAST_OP(0x2e) FAST_OP(0x2f)
            FAST_OP(0x30) FAST_OP(0x31) FAST_OP(0x32) FAST_OP(0x33) FAST_OP(0x34) FAST_OP(0x35) FAST_OP(0x36) FAST_OP(0x37)
            FAST_OP(0x38) FAST_OP(0x39) FAST_OP(0x3a) FAST_OP(0x3b) FAST_OP(0x3c) FAST_OP(0x3d) FAST_OP(0x3e) FAST_OP(0x3f)
            FAST_OP(0x40) FAST_OP(0x41) FAST_OP(0x42) FAST_OP(0x43) FAST_OP(0x44) FAST_OP(0x45) FAST_OP(0x46) FAST_OP(0x47)
            FAST_OP(0x48) FAST_OP(0x49) FAST_OP(0x4a) FAST_OP(0x4b) FAST_OP(0x4c) FAST_OP(0x4d) FAST_OP(0x4e) FAST_OP(0x4f)
            FAST_OP(0x50) FAST_OP(0x51) FAST_OP(0x52) FAST_OP(0x53) FAST_OP(0x54) FAST_OP(0x55) FAST_OP(0x56) FAST_OP(0x57)
            FAST_OP(0x58) FAST_OP(0x59) FAST_OP(0x5a) FAST_OP(0x5b) FAST_OP(0x5c) FAST_OP(0x5d) FAST_OP(0x5e) FAST_OP(0x5f)
            FAST_OP(0x60) FAST_OP(0x61) FAST_OP(0x62) FAST_OP(0x63) FAST_OP(0x64) FAST_OP(0x65) FAST_OP(0x66) FAST_OP(0x67)
            FAST_OP(0x68) FAST_OP(0x69) FAST_OP(0x6a) FAST_OP(0x6b) FAST_OP(0x6c) FAST_OP(0x6d) FAST_OP(0x6e) FAST_OP(0x6f)
            FAST_OP(0x70) FAST_OP(0x71) FAST_OP(0x72) FAST_OP(0x73) FAST_OP(0x74) FAST_OP(0x75) FAST_OP(0x76) FAST_OP(0x77)
            FAST_OP(0x78) FAST_OP(0x79) FAST_OP(0x7a) FAST_OP(0x7b) FAST_OP(0x7c) FAST_OP(0x7d) FAST_OP(0x7e) FAST_OP(0x7f)
            FAST_OP(0x80) FAST_OP(0x81) FAST_OP(0x82) FAST_OP(0x83) FAST_OP(0x84) FAST_OP(0x85) FAST_OP(0x86) FAST_OP(0x87)
            FAST_OP(0x88) FAST_OP(0x89) FAST_OP(0x8a) FAST_OP(0x8b) FAST_OP(0x8c) FAST_OP(0x8d) FAST_OP(0x8e) FAST_OP(0x8f)
            FAST_OP(0x90) FAST_OP(0x91) FAST_OP(0x92) FAST_OP(0x93) FAST_OP(0x94) FAST_OP(0x95) FAST_OP(0x96) FAST_OP(0x97)
            FAST_OP(0x98) FAST_OP(0x99) FAST_OP(0x9a) FAST_OP(0x9b) FAST_OP(0x9c) FAST_OP(0x9d) FAST_OP(0x9e) FAST_OP(0x9f)
            FAST_OP(0xa0) FAST_OP(0xa1) FAST_OP(0xa2) FAST_OP(0xa3) FAST_OP(0xa4) FAST_OP(0xa5) FAST_OP(0xa6) FAST_OP(0xa7)
            FAST_OP(0xa8) FAST_OP(0xa9) FAST_OP(0xaa) FAST_OP(0xab) FAST_OP(0xac) FAST_OP(0xad) FAST_OP(0xae) FAST_OP(0xaf)
            FAST_OP(0xb0) FAST_OP(0xb1) FAST_OP(0xb2) FAST_OP(0xb3) FAST_OP(0xb4) FAST_OP(0xb5) FAST_OP(0xb6) FAST_OP(0xb7)
            FAST_OP(0xb8) FAST_OP(0xb9) FAST_OP(0xba) FAST_OP(0xbb) FAST_OP(0xbc) FAST_OP(0xbd) FAST_OP(0xbe) FAST_OP(0xbf)
            FAST_OP(0xc0) FAST_OP(0xc1) FAST_OP(0xc2) FAST_OP(0xc3) FAST_OP(0xc4) FAST_OP(0xc5) FAST_OP(0xc6) FAST_OP(0xc7)
            FAST_OP(0xc8) FAST_OP(0xc9) FAST_OP(0xca) FAST_OP(0xcb) FAST_OP(0xcc) FAST_OP(0xcd) FAST_OP(0xce) FAST_OP(0xcf)
            FAST_OP(0xd0) FAST_OP(0xd1) FAST_OP(0xd2) FAST_OP(0xd3) FAST_OP(0xd4) FAST_OP(0xd5) FAST_OP(0xd6) FAST_OP(0xd7)
            FAST_OP(0xd8) FAST_OP(0xd9) FAST_OP(0xda) FAST_OP(0xdb) FAST_OP(0xdc) FAST_OP(0xdd) FAST_OP(0xde) FAST_OP(0xdf)
            FAST_OP(0xe0) FAST_OP(0xe1) FAST_OP(0xe2) FAST_OP(0xe3) FAST_OP(0xe4) FAST_OP(0xe5) FAST_OP(0xe6) FAST_OP(0xe7)
            FAST_OP(0xe8) FAST_OP(0xe9) FAST_OP(0xea) FAST_OP(0xeb) FAST_OP(0xec) FAST_OP(0xed) FAST_OP(0xee) FAST_OP(0xef)
            FAST_OP(0xf0) FAST_OP(0xf1) FAST_OP(0xf2) FAST_OP(0xf3) FAST_OP(0xf4) FAST_OP(0xf5) FAST_OP(0xf6) FAST_OP(0xf7)
            FAST_OP(0xf8) FAST_OP(0xf9) FAST_OP(0xfa) FAST_OP(0xfb) FAST_OP(0xfc) FAST_OP(0xfd) FAST_OP(0xfe) FAST_OP(0xff)
#undef FAST_OP
            default: return false; // uint8_t op is covered by the 256 cases
        }
        cycles += used;
    }
    return false;
}

unsigned I4004::step()
{
    if ( m_bankDelay <= 0 && romBank1 != m_pendingRomBank1 && model4040 == m_model )
        romBank1 = m_pendingRomBank1;
    // A 4040 interrupt forces a JMS to 003H of the current ROM bank, saving the SRC address and
    // the index register bank for BBS. None is taken while one is being served, or in the three
    // cycles after DB0 or DB1. Once one can be taken, one more instruction runs first: the
    // interrupt flip-flop is set during it. It also ends a HLT, which executes NOPs until then.
    bool takeable = interruptRequest && interruptEnable && !interruptAcknowledged && m_bankDelay <= 0 &&
                    model4040 == m_model;
    if ( takeable && m_interruptArmed )
    {
        m_interruptArmed = false;
        interruptRequest = false;
        interruptAcknowledged = true;
        halted = false;
        m_savedSrc = src;
        m_savedRegisterBank1 = registerBank1;
        if ( m_tracer )
            m_tracer->Trace( "interrupt at %03X\n", pc() );
        push( 3 );
        cycles += 2;
        return 2;
    }
    m_interruptArmed = takeable;
    if ( halted )
    {
        cycles++;
        return 1;
    }
    uint16_t address = pc();
    if ( m_trace && m_tracer )
        trace_state();
    uint8_t op = fetch();
    unsigned used = execute( address, op );
    cycles += used;
    if ( m_bankDelay > 0 )
        m_bankDelay -= (int) used;
    return used;
} //step

uint64_t I4004::emulate( uint64_t maxcycles )
{
    uint64_t start = cycles;
    while ( !halted && !ended && cycles - start < maxcycles )
        step();
    return cycles - start;
} //emulate

const char * I4004::render_operation( uint16_t address ) const
{
    static char text[ 32 ];
    uint16_t full = full_address( address );
    uint8_t op = rom[ full ], opa = op & 0xf;
    uint8_t second = rom[ ( full & 0x1000 ) | ( ( full + 1 ) & 0xfff ) ];
    uint16_t page = ( address + 2 ) & 0xf00;
    switch ( op >> 4 )
    {
        case 0x0: snprintf( text, sizeof text, "%s", ( model4040 == m_model ) ? group4040[ opa ] : "NOP" ); break;
        case 0x1: snprintf( text, sizeof text, "JCN %X,%03X", opa, page | second ); break;
        case 0x2: snprintf( text, sizeof text, ( opa & 1 ) ? "SRC P%u" : "FIM P%u,%02X", opa >> 1, second ); break;
        case 0x3: snprintf( text, sizeof text, ( opa & 1 ) ? "JIN P%u" : "FIN P%u", opa >> 1 ); break;
        case 0x4: snprintf( text, sizeof text, "JUN %03X", ( opa << 8 ) | second ); break;
        case 0x5: snprintf( text, sizeof text, "JMS %03X", ( opa << 8 ) | second ); break;
        case 0x6: snprintf( text, sizeof text, "INC R%u", opa ); break;
        case 0x7: snprintf( text, sizeof text, "ISZ R%u,%03X", opa, page | second ); break;
        case 0x8: snprintf( text, sizeof text, "ADD R%u", opa ); break;
        case 0x9: snprintf( text, sizeof text, "SUB R%u", opa ); break;
        case 0xa: snprintf( text, sizeof text, "LD R%u", opa ); break;
        case 0xb: snprintf( text, sizeof text, "XCH R%u", opa ); break;
        case 0xc: snprintf( text, sizeof text, "BBL %u", opa ); break;
        case 0xd: snprintf( text, sizeof text, "LDM %u", opa ); break;
        case 0xe: snprintf( text, sizeof text, "%s", ioGroup[ opa ] ); break;
        default: snprintf( text, sizeof text, "%s", accumulatorGroup[ opa ] ); break;
    }
    return text;
} //render_operation

void I4004::trace_state() const
{
    if ( !m_tracer )
        return;
    uint16_t address = pc();
    char symbol[ 64 ] = "";
    if ( m_symbolLookup )
    {
        uint16_t offset = 0;
        const char * name = m_symbolLookup( full_address( address ), offset );
        if ( name )
            snprintf( symbol, sizeof symbol, offset ? "%s+%u" : "%s", name, offset );
    }
    char regs[ 40 ];
    for ( unsigned i = 0; i < 16; i++ )
        regs[ i ] = "0123456789ABCDEF"[ reg( i ) ];
    regs[ 16 ] = 0;
    m_tracer->Trace( "%s%04X %-16s acc %X c %u r %s src %02X cm %u sp %u %s\n",
                     romBank1 ? "1:" : "", address, render_operation( address ), acc, carry ? 1 : 0, regs, src, cm, sp, symbol );
} //trace_state
