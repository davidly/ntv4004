#pragma once
#include <stdint.h>
#include "trace.hxx"

// Intel 4004 and 4040 CPU. The host supplies ROM, the ROM I/O ports and the
// TEST pin; the CPU owns the 4002 RAM it addresses through SRC and DCL.

extern uint8_t rom[ 8192 ];                                 // two 4K banks; the 4004 uses bank 0
extern uint8_t i4004_rom_input( uint8_t port );            // RDR: port is the ROM chip (SRC high nibble)
extern void i4004_rom_output( uint8_t port, uint8_t value ); // WRR
extern void i4004_ram_output( uint8_t bank, uint8_t chip, uint8_t value ); // WMP

struct I4004
{
    enum Model { model4004, model4040 };

    uint8_t acc;           // 4-bit accumulator
    bool carry;            // carry/link
    uint8_t r[ 16 ];       // index registers R0-R15
    uint8_t r1[ 8 ];       // 4040 register bank 1, R0*-R7*
    uint16_t stack[ 8 ];   // the selected entry is the program counter
    uint8_t sp;
    uint8_t src;           // last SRC address
    uint8_t cm;            // command lines from DCL: the RAM bank
    bool test;             // TEST pin; JCN condition 1 jumps when it is 0
    bool registerBank1, romBank1, interruptEnable;
    bool interruptRequest;      // the 4040's INTERRUPT input, latched until the interrupt is taken
    bool interruptAcknowledged; // set when an interrupt is taken; BBS clears it, and none is taken while set
    bool halted, ended;
    uint64_t cycles;       // instruction cycles (8 clock periods each)

    uint8_t ram[ 8 ][ 16 ][ 16 ];    // bank, chip * 4 + register, main character
    uint8_t status[ 8 ][ 16 ][ 4 ];  // bank, chip * 4 + register, status character

    void set_tracer( CTrace * tracer ) { m_tracer = tracer; } // caller owns the tracer
    void trace_instructions( bool trace ) { m_trace = trace; }
    void set_symbol_lookup( const char * (*lookup)( uint16_t, uint16_t & ) ) { m_symbolLookup = lookup; }
    const char * render_operation( uint16_t address ) const;
    void trace_state() const;

    void power_on( Model model, uint16_t address = 0 );
    Model model() const { return m_model; }
    uint16_t pc() const { return stack[ sp ]; }
    uint8_t reg( unsigned n ) const { return ( n < 8 && registerBank1 ) ? r1[ n ] : r[ n ]; }
    void set_reg( unsigned n, uint8_t value ) { ( ( n < 8 && registerBank1 ) ? r1[ n ] : r[ n ] ) = value & 0xf; }
    void end_emulation() { ended = true; }
    uint64_t emulate( uint64_t maxcycles ); // runs whole instructions until halted, ended, or maxcycles
    // Untraced 4004 batch, stopping before a self-jump. Returns true for that stop.
    // It implements the instructions again, with the CPU's state in locals;
    // step(), the reference, serves the 4040, tracing, timers and speed limiting.
    bool run_fast4004( uint64_t cycleLimit );
    unsigned step();                        // one instruction; returns its instruction cycles

private:
    Model m_model = model4004;
    CTrace * m_tracer = 0;
    bool m_trace = false;
    const char * (*m_symbolLookup)( uint16_t, uint16_t & ) = 0;
    int m_bankDelay = 0;        // DB0/DB1 take effect on the third instruction cycle after them
    bool m_pendingRomBank1 = false;
    uint8_t m_savedSrc = 0;     // SRC and register bank saved by an interrupt, restored by BBS
    bool m_savedRegisterBank1 = false;
    bool m_interruptArmed = false; // an interrupt could be taken at the last instruction: take it at this one

    uint8_t fetch();
    uint16_t full_address( uint16_t address ) const { return ( romBank1 ? 0x1000 : 0 ) | ( address & 0xfff ); }
    uint8_t pair( unsigned p ) const { return (uint8_t) ( ( reg( 2 * p ) << 4 ) | reg( 2 * p + 1 ) ); }
    void set_pair( unsigned p, uint8_t value ) { set_reg( 2 * p, value >> 4 ); set_reg( 2 * p + 1, value & 0xf ); }
    uint8_t & ram_character() { return ram[ cm ][ src >> 4 ][ src & 0xf ]; }
    void push( uint16_t address );
    void pop();
    void add( uint8_t value, bool carryIn );
    unsigned execute( uint16_t address, uint8_t op );
};
