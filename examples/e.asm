; E FOR NTV4004: 192 DIGITS OF E FROM THE FACTORIAL-SERIES SPIGOT USED BY
; THE 8008 AND 8080 E BENCHMARKS, WITH DIGITS = 200, THEN DONE.
; A(N), N = 0 TO 199, IS 8 BITS: THE HIGH NIBBLE IN 4002 RAM BANK 0 AND
; THE LOW NIBBLE IN BANK 1, BOTH AT CHARACTER N, SO N IS THE SRC ADDRESS.
; EACH OUTER STEP LOWERS HIGH AND, FOR N = HIGH DOWN TO 1, SETS
; A(N) = X MOD N AND X = 10 * A(N - 1) + X / N; THEN IT PRINTS X.
; R2R3 N   R10R11 ~N, ITS ONE'S COMPLEMENT   R4R5R6 X, 12 BITS
; R8R9 X MOD N   R12R13 A(N)   R14R15 HIGH   R0R1 THE FIN ADDRESS
; R7 IS A WORK REGISTER.
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
OSTEP:  LD 14           ; N = HIGH, AND ~N
        XCH 2
        LD 2
        CMA
        XCH 10
        LD 15
        XCH 3
        LD 3
        CMA
        XCH 11
        FIM 4,00H       ; X = 0
        LDM 0
        XCH 6
        LDM 0           ; THE LOOP STARTS AND ENDS IN BANK 0
        DCL
; FOR N = HIGH DOWN TO 2. N = 1 IS DONE AFTER THE LOOP: X / 1 IS X, AND
; THEN 10 * A(0) ADDS NOTHING, SO IT ONLY SETS A(1) = 0.
INNER:  JMS DIVIDE      ; X = X / N, R8R9 = X MOD N
        SRC 2           ; A(N) = X MOD N: THE HIGH NIBBLE IN BANK 0, THEN THE LOW
        LD 8
        WRM
        LDM 1
        DCL
        LD 9
        WRM
        LD 3            ; N = N - 1, SO ~N = ~N + 1
        DAC
        XCH 3
        JCN 2,NLOW
        LD 2
        DAC
        XCH 2
NLOW:   ISZ 11,NNEXT
        INC 10
NNEXT:  SRC 2           ; R12R13 = A(N): THE LOW NIBBLE, STILL IN BANK 1, THEN THE HIGH
        RDM
        XCH 13
        LDM 0
        DCL
        RDM
        XCH 12
; X = X + 10 * A(N), LOOKING UP EACH NIBBLE'S PRODUCT IN THE 16-BYTE TABLE TEN.
; TEN AND BOTH FIN INSTRUCTIONS MUST SHARE A ROM PAGE; TEN STARTS AT F0H.
TIMES10: LDM 15
        XCH 0
        LD 13
        XCH 1
        FIN 8           ; R8R9 = 10 * THE LOW NIBBLE
        LD 12
        XCH 1
        FIN 12          ; R12R13 = 10 * THE HIGH NIBBLE, WORTH 16 TIMES MORE
        CLC
        LD 6
        ADD 9
        XCH 6
        LD 5
        ADD 8
        XCH 5
        TCC
        ADD 4
        XCH 4
        LD 5            ; X < 4096, SO THE CARRY IS 0
        ADD 13
        XCH 5
        LD 4
        ADD 12
        XCH 4
T10END: LD 2            ; UNTIL N = 1
        JCN 0CH,INNER
        LD 3
        DAC
        JCN 0CH,INNER
        SRC 2           ; A(1) = 0
        LDM 0
        WRM
        LDM 1
        DCL
        LDM 0
        WRM
        JMS PRINTX
        CLC             ; UNTIL HIGH = 9
        LDM 9
        SUB 15
        JCN 0CH,OUTER
        LD 14
        JCN 0CH,OUTER
        JUN FINISH

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

        ORG 0F0H
TEN:    DB 0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150


; X = X / N, R8R9 = X MOD N, FOR N >= 2 WITH ~N IN R10R11. FOR N >= 2,
; 0 <= A(N) < N AND THE PREVIOUS QUOTIENT <= 9 GIVE X < 10*N, SO THE
; QUOTIENT IS AT MOST 9: TEN SUBTRACTIONS, UNROLLED, AND THE TENTH ALWAYS
; FAILS. EACH FAILURE ADDS N BACK TO THE LOW BYTE FOR THE REMAINDER; ITS
; CARRY IS 0, AS THE JCN THAT REACHES IT REQUIRES. THIS IS A SPIGOT
; HELPER, NOT A GENERAL DIVIDE (THE QUOTIENT IS ONE NIBBLE).
        ORG 100H
DIVIDE: STC             ; X - N IS X + ~N + 1; A SUCCESS LEAVES THE CARRY 1
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q0
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q1
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q2
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q3
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q4
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q5
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q6
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q7
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
        JCN 0AH,Q8
        LD 6
        ADD 11
        XCH 6
        LD 5
        ADD 10
        XCH 5
        LDM 15
        ADD 4
        XCH 4
Q9:     LD 6            ; QUOTIENT 9: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 9
        XCH 6
        BBL 0
Q8:     LD 6            ; QUOTIENT 8: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 8
        XCH 6
        BBL 0
Q7:     LD 6            ; QUOTIENT 7: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 7
        XCH 6
        BBL 0
Q6:     LD 6            ; QUOTIENT 6: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 6
        XCH 6
        BBL 0
Q5:     LD 6            ; QUOTIENT 5: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 5
        XCH 6
        BBL 0
Q4:     LD 6            ; QUOTIENT 4: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 4
        XCH 6
        BBL 0
Q3:     LD 6            ; QUOTIENT 3: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 3
        XCH 6
        BBL 0
Q2:     LD 6            ; QUOTIENT 2: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 2
        XCH 6
        BBL 0
Q1:     LD 6            ; QUOTIENT 1: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 1
        XCH 6
        BBL 0
Q0:     LD 6            ; QUOTIENT 0: UNDO THE FAILED SUBTRACTION FOR THE REMAINDER
        ADD 3
        XCH 9
        LD 5
        ADD 2
        XCH 8
        FIM 4,00H
        LDM 0
        XCH 6
        BBL 0

        END
