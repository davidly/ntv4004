// Intel 4004 and 4040 instruction set, following the MCS-40 User's Manual
// (November 1974). One instruction cycle is 8 clock periods; one-word
// instructions take one cycle, and two-word instructions and FIN take two.

#include <stdio.h>
#include <string.h>
#include <assert.h>
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
    interruptRequest = interruptAcknowledged = m_interruptArmed = false;
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
                    interruptAcknowledged = false;
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
        {
            stack[ sp ] = (uint16_t) ( ( opa << 8 ) | fetch() );
            return 2;
        }
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

// The untraced 4004: the CPU's state lives in locals for the whole batch, so
// the compiler can keep it in registers. Stores to RAM are uint8_t stores,
// which C++ lets alias anything, so with the state in members every one would
// force the PC, cycle count and the rest to be reloaded. The state is written
// back around the host's I/O callbacks and at the end. Each of the 256 cases
// has its own constant opcode. There is no instruction cache: ROM is read afresh.
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable: 4127) // each opcode's case tests its constant operand
#endif
bool I4004::run_fast4004( uint64_t cycleLimit )
{
    assert( model4004 == m_model && !m_trace && !romBank1 && !registerBank1 );
    unsigned a = acc, s = sp, chosenSrc = src, bank = cm; // full-width locals avoid partial-register writes
    unsigned R[ 16 ];
    bool c = carry;
    unsigned stk[ 4 ];  // stk[ s ] is stale: pc holds the program counter
    for ( unsigned i = 0; i < 16; i++ )
        R[ i ] = r[ i ];
    for ( unsigned i = 0; i < 4; i++ )
        stk[ i ] = stack[ i ];
    unsigned pc = stack[ sp ] & 0xfff;
    uint64_t cyc = cycles;

#define SAVE() { acc = (uint8_t) a; carry = c; for ( unsigned i = 0; i < 16; i++ ) r[ i ] = (uint8_t) R[ i ]; \
                 for ( unsigned i = 0; i < 4; i++ ) stack[ i ] = (uint16_t) stk[ i ]; \
                 sp = (uint8_t) s; stack[ s ] = (uint16_t) pc; src = (uint8_t) chosenSrc; cm = (uint8_t) bank; cycles = cyc; }
#define ADD4(value, carryIn) { unsigned sum = a + ( (value) & 15u ) + ( (carryIn) ? 1u : 0u ); \
                               a = sum & 15; c = sum > 15; }
#define CHARACTER ram[ bank ][ chosenSrc >> 4 ][ chosenSrc & 15 ]
#define PAIR(p) ( (uint8_t) ( ( R[ 2*(p) ] << 4 ) | R[ 2*(p)+1 ] ) )

    if ( halted || ended )
        return false;
    while ( cyc < cycleLimit )
    {
        unsigned address = pc;
        uint8_t op = rom[ address ];
        pc = ( pc + 1 ) & 0xfff;
        switch ( op )
        {
#define ROW(hi, BODY) \
    case hi*16+0: { const unsigned opa = 0; BODY } break;   case hi*16+1: { const unsigned opa = 1; BODY } break; \
    case hi*16+2: { const unsigned opa = 2; BODY } break;   case hi*16+3: { const unsigned opa = 3; BODY } break; \
    case hi*16+4: { const unsigned opa = 4; BODY } break;   case hi*16+5: { const unsigned opa = 5; BODY } break; \
    case hi*16+6: { const unsigned opa = 6; BODY } break;   case hi*16+7: { const unsigned opa = 7; BODY } break; \
    case hi*16+8: { const unsigned opa = 8; BODY } break;   case hi*16+9: { const unsigned opa = 9; BODY } break; \
    case hi*16+10: { const unsigned opa = 10; BODY } break; case hi*16+11: { const unsigned opa = 11; BODY } break; \
    case hi*16+12: { const unsigned opa = 12; BODY } break; case hi*16+13: { const unsigned opa = 13; BODY } break; \
    case hi*16+14: { const unsigned opa = 14; BODY } break; case hi*16+15: { const unsigned opa = 15; BODY } break;

            ROW( 0x0, (void) opa; cyc += 1; )                                     // NOP: the 4004 decodes the row as NOP
            ROW( 0x1,                                                            // JCN
                uint8_t target = rom[ pc ];
                pc = ( pc + 1 ) & 0xfff;
                bool jump = ( ( opa & 4 ) && 0 == a ) || ( ( opa & 2 ) && c ) || ( ( opa & 1 ) && !test );
                if ( ( opa & 8 ) ? !jump : jump ) // the page is that of the next instruction
                    pc = ( pc & 0xf00 ) | target;
                cyc += 2; )
            ROW( 0x2,
                if ( opa & 1 ) { chosenSrc = PAIR( opa >> 1 ); cyc += 1; }      // SRC
                else                                                             // FIM
                {
                    uint8_t v = rom[ pc ];
                    pc = ( pc + 1 ) & 0xfff;
                    R[ opa ] = v >> 4;
                    R[ opa | 1 ] = v & 15;
                    cyc += 2;
                } )
            ROW( 0x3,                         // FIN and JIN use the page of the next instruction
                if ( opa & 1 ) { pc = ( pc & 0xf00 ) | PAIR( opa >> 1 ); cyc += 1; } // JIN
                else                                                                 // FIN
                {
                    uint8_t v = rom[ ( pc & 0xf00 ) | PAIR( 0 ) ];
                    R[ opa ] = v >> 4;
                    R[ opa | 1 ] = v & 15;
                    cyc += 2;
                } )
            ROW( 0x4,                                                            // JUN
                unsigned target = ( opa << 8 ) | rom[ pc ];
                pc = target;
                if ( target == address ) // stop before counting a self-jump, as the host's reference loop does
                {
                    SAVE();
                    return true;
                }
                cyc += 2; )
            ROW( 0x5,                                                            // JMS
                unsigned target = ( opa << 8 ) | rom[ pc ];
                stk[ s ] = ( pc + 1 ) & 0xfff; // three return levels: the deepest is lost on overflow
                s = ( s + 1 ) & 3;
                pc = target;
                cyc += 2; )
            ROW( 0x6, R[ opa ] = ( R[ opa ] + 1 ) & 15; cyc += 1; )             // INC
            ROW( 0x7,                                                            // ISZ
                uint8_t target = rom[ pc ];
                pc = ( pc + 1 ) & 0xfff;
                R[ opa ] = ( R[ opa ] + 1 ) & 15;
                if ( R[ opa ] )
                    pc = ( pc & 0xf00 ) | target;
                cyc += 2; )
            ROW( 0x8, ADD4( R[ opa ], c ); cyc += 1; )                          // ADD
            ROW( 0x9, ADD4( ~R[ opa ], !c ); cyc += 1; )                        // SUB: carry is set when there is no borrow
            ROW( 0xa, a = R[ opa ]; cyc += 1; )                                 // LD
            ROW( 0xb, unsigned t = a; a = R[ opa ]; R[ opa ] = t; cyc += 1; )    // XCH
            ROW( 0xc, stk[ s ] = pc; s = ( s + 3 ) & 3; pc = stk[ s ]; a = opa; cyc += 1; ) // BBL; the stack keeps the callee's PC
            ROW( 0xd, a = opa; cyc += 1; )                                      // LDM
            ROW( 0xe,
                cyc += 1;
                switch ( opa )
                {
                    case 0x0: CHARACTER = (uint8_t) a; break;                                               // WRM
                    case 0x1: SAVE(); i4004_ram_output( (uint8_t) bank, (uint8_t) ( chosenSrc >> 6 ), (uint8_t) a ); break;        // WMP
                    case 0x2: SAVE(); i4004_rom_output( (uint8_t) ( chosenSrc >> 4 ), (uint8_t) a ); break;              // WRR
                    case 0x3: break;                                                              // WPM: no 4008/4009
                    case 0x4: case 0x5: case 0x6: case 0x7: status[ bank ][ chosenSrc >> 4 ][ opa - 4 ] = (uint8_t) a; break; // WR0-WR3
                    case 0x8: ADD4( ~CHARACTER, !c ); break;                                      // SBM
                    case 0x9: a = CHARACTER; break;                                               // RDM
                    case 0xa:                                                                     // RDR
                        SAVE();
                        a = i4004_rom_input( (uint8_t) ( chosenSrc >> 4 ) ) & 15;
                        if ( ended ) // the host saw the end of its input
                        {
                            acc = (uint8_t) a;
                            return false;
                        }
                        break;
                    case 0xb: ADD4( CHARACTER, c ); break;                                        // ADM
                    default: a = status[ bank ][ chosenSrc >> 4 ][ opa - 12 ]; break;            // RD0-RD3
                } )
            ROW( 0xf,                                                            // the accumulator group
                cyc += 1;
                switch ( opa )
                {
                    case 0x0: a = 0; c = false; break;                                            // CLB
                    case 0x1: c = false; break;                                                   // CLC
                    case 0x2: ADD4( 1, false ); break;                                            // IAC
                    case 0x3: c = !c; break;                                                      // CMC
                    case 0x4: a = ~a & 15; break;                                                 // CMA
                    case 0x5: { bool out = a & 8; a = ( ( a << 1 ) | ( c ? 1 : 0 ) ) & 15; c = out; break; } // RAL
                    case 0x6: { bool out = a & 1; a = ( a >> 1 ) | ( c ? 8 : 0 ); c = out; break; } // RAR
                    case 0x7: a = c ? 1 : 0; c = false; break;                                    // TCC
                    case 0x8: ADD4( 15, false ); break;                                           // DAC
                    case 0x9: a = c ? 10 : 9; c = false; break;                                   // TCS
                    case 0xa: c = true; break;                                                    // STC
                    case 0xb:                                                                     // DAA
                        if ( c || a > 9 )
                        {
                            unsigned sum = a + 6u;
                            a = sum & 15;
                            if ( sum > 15 )
                                c = true; // otherwise carry is unaffected
                        }
                        break;
                    case 0xc: a = kbp[ a ]; break;                                                // KBP
                    case 0xd: bank = a & 7; break;                                                // DCL
                    default: break;                                                               // unassigned
                } )
#undef ROW
        }
    }
    SAVE();
    return false;
#undef SAVE
#undef ADD4
#undef CHARACTER
#undef PAIR
}
#ifdef _MSC_VER
#pragma warning(pop)
#endif

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
