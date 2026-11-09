// Intel 4004 and 4040 instruction set, following the MCS-40 User's Manual
// (November 1974). One instruction cycle is 8 clock periods; one-word
// instructions take one cycle, and two-word instructions and FIN take two.

#include <stdio.h>
#include <string.h>
#include "i4004.hxx"

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
    halted = ended = false;
    cycles = 0;
    m_bankDelay = 0;
    m_savedSrc = 0;
    m_savedRegisterBank1 = false;
    stack[ 0 ] = address & 0xfff;
    romBank1 = m_pendingRomBank1 = ( address & 0x1000 ) && model4040 == model;
} //power_on

uint8_t I4004::fetch()
{
    uint16_t & pc = stack[ sp ];
    uint8_t value = rom[ full_address( pc ) ];
    pc = ( pc + 1 ) & 0xfff;
    return value;
} //fetch

void I4004::push( uint16_t address )
{
    // 4004: three return levels plus the PC; 4040: seven. The deepest is lost on overflow.
    unsigned levels = ( model4040 == m_model ) ? 8 : 4;
    sp = (uint8_t) ( ( sp + 1 ) % levels );
    stack[ sp ] = address & 0xfff;
} //push

void I4004::pop()
{
    unsigned levels = ( model4040 == m_model ) ? 8 : 4;
    sp = (uint8_t) ( ( sp + levels - 1 ) % levels );
} //pop

void I4004::add( uint8_t value, bool carryIn )
{
    unsigned sum = acc + ( value & 0xf ) + ( carryIn ? 1 : 0 );
    acc = sum & 0xf;
    carry = sum > 0xf;
} //add

unsigned I4004::execute( uint16_t address, uint8_t op )
{
    uint8_t opa = op & 0xf;
    switch ( op >> 4 )
    {
        case 0x0:
            if ( model4004 == m_model || 0 == opa )
                return 1; // NOP; the 4004 decodes the whole row as NOP
            switch ( opa )
            {
                case 0x1: halted = true; return 1;                             // HLT
                case 0x2:                                                       // BBS
                    pop();
                    src = m_savedSrc;
                    registerBank1 = m_savedRegisterBank1;
                    return 1;
                case 0x3: acc = (uint8_t) ( ( romBank1 ? 8 : 0 ) | cm ); return 1; // LCR
                case 0x4: acc |= reg( 4 ); return 1;                           // OR4
                case 0x5: acc |= reg( 5 ); return 1;                           // OR5
                case 0x6: acc &= reg( 6 ); return 1;                           // AN6
                case 0x7: acc &= reg( 7 ); return 1;                           // AN7
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
            uint8_t target = fetch();
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
                src = pair( opa >> 1 );
                return 1;
            }
            set_pair( opa >> 1, fetch() ); // FIM
            return 2;
        case 0x3:
        {
            // FIN and JIN address the page holding the next instruction: the
            // next page when they sit at the last byte of a page.
            uint16_t page = ( address + 1 ) & 0xf00;
            if ( opa & 1 ) // JIN
            {
                stack[ sp ] = page | pair( opa >> 1 );
                return 1;
            }
            set_pair( opa >> 1, rom[ full_address( page | pair( 0 ) ) ] ); // FIN
            return 2;
        }
        case 0x4: // JUN
            stack[ sp ] = (uint16_t) ( ( opa << 8 ) | fetch() );
            return 2;
        case 0x5: // JMS
        {
            uint16_t target = (uint16_t) ( ( opa << 8 ) | fetch() );
            push( target );
            return 2;
        }
        case 0x6: set_reg( opa, reg( opa ) + 1 ); return 1; // INC
        case 0x7: // ISZ
        {
            uint8_t target = fetch();
            set_reg( opa, reg( opa ) + 1 );
            if ( 0 != reg( opa ) )
                stack[ sp ] = ( stack[ sp ] & 0xf00 ) | target;
            return 2;
        }
        case 0x8: add( reg( opa ), carry ); return 1;              // ADD
        case 0x9: add( ~reg( opa ), !carry ); return 1;            // SUB: carry is set when there is no borrow
        case 0xa: acc = reg( opa ); return 1;                      // LD
        case 0xb: { uint8_t t = acc; acc = reg( opa ); set_reg( opa, t ); return 1; } // XCH
        case 0xc: pop(); acc = opa; return 1;                      // BBL
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

unsigned I4004::step()
{
    if ( m_bankDelay <= 0 && romBank1 != m_pendingRomBank1 && model4040 == m_model )
        romBank1 = m_pendingRomBank1;
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
