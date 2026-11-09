; E FOR NTV4004: 192 DIGITS OF E FROM THE FACTORIAL-SERIES SPIGOT USED BY
; THE 8008 AND 8080 E BENCHMARKS, WITH DIGITS = 200, THEN DONE.
; A(N), N = 0 TO 199, IS 8 BITS: THE HIGH NIBBLE IN 4002 RAM BANK 0 AND
; THE LOW NIBBLE IN BANK 1, BOTH AT CHARACTER N, SO N IS THE SRC ADDRESS.
; EACH OUTER STEP LOWERS HIGH AND, FOR N = HIGH DOWN TO 1, SETS
; A(N) = X MOD N AND X = 10 * A(N - 1) + X / N; THEN IT PRINTS X.
; R0R1 N   R2R3 X MOD N   R4R5R6 X, 12 BITS   R14R15 HIGH
; R7 TO R13 ARE WORK REGISTERS.
DIGITS  EQU 200
        ORG 0
        FIM 0,00H       ; A(N) = 1 FOR EVERY N
FILL:   SRC 0
        LDM 0
        DCL
        LDM 0
        WRM
        LDM 1
        DCL
        LDM 1
        WRM
        ISZ 1,FILL
        ISZ 0,FILL
        FIM 0,00H       ; A(0) = 0
        SRC 0
        LDM 0
        WRM
        FIM 0,01H       ; A(1) = 2
        SRC 0
        LDM 2
        WRM
        FIM 14,DIGITS
OUTER:  LD 15           ; HIGH = HIGH - 1
        DAC
        XCH 15
        JCN 2,OSTEP
        LD 14
        DAC
        XCH 14
OSTEP: LD 14           ; N = HIGH
        XCH 0
        LD 15
        XCH 1
        LDM 0           ; X = 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
INNER:  JMS DIVIDE      ; X = X / N, R2R3 = X MOD N
        SRC 0           ; A(N) = X MOD N
        LDM 0
        DCL
        LD 2
        WRM
        LDM 1
        DCL
        LD 3
        WRM
        LD 1            ; N = N - 1
        DAC
        XCH 1
        JCN 2,ISTEP
        LD 0
        DAC
        XCH 0
ISTEP: SRC 0           ; R12R13 = A(N)
        LDM 0
        DCL
        RDM
        XCH 12
        LDM 1
        DCL
        RDM
        XCH 13
        JMS TIMES10     ; X = X + 10 * A(N)
        LD 0
        JCN 0CH,INNER
        LD 1
        JCN 0CH,INNER   ; UNTIL N = 0
        JMS PRINTX
        CLC             ; UNTIL HIGH = 9
        LDM 9
        SUB 15
        JCN 0CH,OUTER
        LD 14
        JCN 0CH,OUTER
        JUN FINISH

; X = X + 10 * R12R13, AS 8 * A + 2 * A IN R11R12R13 AND R7R8R9.
TIMES10: LDM 0
        XCH 11
        CLC             ; R11R12R13 = 2 * A
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        LD 11
        RAL
        XCH 11
        LD 11           ; R7R8R9 = 2 * A
        XCH 7
        LD 12
        XCH 8
        LD 13
        XCH 9
        CLC             ; R11R12R13 = 4 * A
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        LD 11
        RAL
        XCH 11
        CLC             ; R11R12R13 = 8 * A
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        LD 11
        RAL
        XCH 11
        CLC             ; X = X + 8 * A
        LD 6
        ADD 13
        XCH 6
        LD 5
        ADD 12
        XCH 5
        LD 4
        ADD 11
        XCH 4
        CLC             ; X = X + 2 * A
        LD 6
        ADD 9
        XCH 6
        LD 5
        ADD 8
        XCH 5
        LD 4
        ADD 7
        XCH 4
        BBL 0

; PRINT X, WHICH IS LESS THAN 100, IN DECIMAL WITHOUT A LEADING ZERO.
PRINTX: FIM 8,0F0H      ; R8R9 SELECTS ROM PORT 15, THE CONSOLE
        SRC 8
        FIM 10,0AH      ; R10R11 = 10
        LDM 0
        XCH 7           ; R7 = THE TENS
TENS:   CLC             ; X - 10, IN R5 AND R6
        LD 6
        SUB 11
        XCH 13
        CMC
        LD 5
        SUB 10
        JCN 0AH,UNITS   ; A BORROW: X < 10
        XCH 5
        LD 13
        XCH 6
        INC 7
        JUN TENS
UNITS:  LD 7
        JCN 4,ONES
        LDM 3
        WRR
        LD 7
        WRR
ONES: LDM 3
        WRR
        LD 6
        WRR
        BBL 0

FINISH: FIM 8,0F0H
        SRC 8
        FIM 0,DONEM
MNEXT:  FIN 2
        LD 2
        JCN 0CH,MSHOW
        LD 3
        JCN 4,DONE
MSHOW:  LD 2
        WRR
        LD 3
        WRR
        ISZ 1,MNEXT
        INC 0
        JUN MNEXT
DONE:   JUN DONE
DONEM:  DB 0DH,64H,6FH,6EH,65H,2EH,0DH,0

; X = X / N, RESTORING DIVISION: 12 TIMES, SHIFT X LEFT INTO THE REMAINDER,
; SUBTRACT N IF IT FITS, AND SHIFT THE QUOTIENT BIT INTO X'S LOW END.
; THE REMAINDER CAN REACH 9 BITS BEFORE THE SUBTRACTION; R10 HOLDS BIT 8.
        ORG 100H
DIVIDE: LDM 0           ; REMAINDER = 0
        XCH 2
        LDM 0
        XCH 3
        LDM 4           ; R7 COUNTS 12 STEPS UP TO 16
        XCH 7
        CLC
DLOOP:  LD 6            ; SHIFT THE QUOTIENT BIT INTO X, X'S TOP INTO R2R3
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        LD 3
        RAL
        XCH 3
        LD 2
        RAL
        XCH 2
        LDM 0           ; R10 = BIT 8 OF THE REMAINDER
        RAL
        XCH 10
        CLC             ; R8R9 = REMAINDER - N
        LD 3
        SUB 1
        XCH 9
        CMC             ; SUB'S CARRY MEANS NO BORROW, BUT IT SUBTRACTS ONE MORE
        LD 2
        SUB 0
        XCH 8
        JCN 2,DSUB      ; NO BORROW: IT FITS
        LD 10
        JCN 4,DNO
DSUB:   LD 8
        XCH 2
        LD 9
        XCH 3
        STC             ; QUOTIENT BIT 1
        ISZ 7,DLOOP
        JUN DLAST
DNO:    CLC             ; QUOTIENT BIT 0
        ISZ 7,DLOOP
DLAST:  LD 6            ; SHIFT IN THE LAST QUOTIENT BIT
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        BBL 0
        END
