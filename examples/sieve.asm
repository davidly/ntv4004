; SIEVE FOR NTV4004: THE BYTE ODD-NUMBER SIEVE, SIZE 8190, TEN PASSES,
; PRINTING 1899 PRIMES. A PORT OF THE 8008 AND 8080 SIEVE BENCHMARKS.
; FLAG K IS ONE BIT OF THE 4002 RAM: BANK K SHR 10, CHARACTER (K SHR 2)
; AND 0FFH, BIT K AND 3. ALL EIGHT BANKS HOLD 8192 FLAGS; FLAG 8191 IS 0.
; NUMBERS ARE KEPT IN THOSE FIELDS: THE BIT TIMES 4 IN A REGISTER, SO
; ADDING TWO BIT FIELDS CARRIES INTO THE CHARACTER, THE CHARACTER IN A
; REGISTER PAIR FOR SRC, AND THE BANK. THE 4004 HAS NO AND, SO A FIN
; TABLE TESTS AND CLEARS A BIT.
; R0R1 FIN INDEX: BIT TIMES 4, CHARACTER  R2R3 FIN RESULT: SET, CLEARED
; R4R5 I CHARACTER   R10 I BIT X4   R11 I BANK
; R6R7 K CHARACTER   R12 K BIT X4   R13 K BANK
; R8R9 P CHARACTER   R14 P BIT X4   R15 P BANK, WHERE P = 2I+3
; BANK 0, RAM REGISTER 0, STATUS 0-3: THE PRIME COUNT IN BCD
; BANK 0, RAM REGISTER 1, STATUS 0: PASSES TO RUN
LOOPS   EQU 10
        ORG 0
        LDM 0
        DCL
        FIM 0,10H
        SRC 0
        LDM LOOPS
        WR0
PASS:   LDM 0           ; THE COUNT IS ZERO
        DCL
        FIM 0,00H
        SRC 0
        WR0
        WR1
        WR2
        WR3
        LDM 8           ; FILL BANKS 0-7 (R11 = 8-15) WITH 1 FLAGS
        XCH 11
FILLB:  LD 11
        DCL
        FIM 4,00H
FILLC:  SRC 4
        LDM 15
        WRM
        ISZ 5,FILLC
        ISZ 4,FILLC
        ISZ 11,FILLB
        LDM 7           ; FLAG 8191 IS NOT IN THE SIEVE
        DCL
        FIM 4,0FFH
        SRC 4
        WRM
        FIM 4,00H       ; I = 0: BANK 0, CHARACTER 0, BIT 0
        LDM 0
        XCH 10
        LDM 0
        XCH 11
        LDM 0
        DCL
        JUN SCAN
NBANK: INC 11          ; THE NEXT BANK OF FLAGS
        CLC
        LD 11
        RAL
        JCN 2,DONEP     ; BANK 8: THE PASS IS DONE
        LD 11
        DCL
        JUN SCAN
DONEP:  LDM 0
        DCL
        FIM 0,10H
        SRC 0
        RD0
        DAC
        WR0
        JCN 0CH,PASS
        FIM 0,00H       ; PRINT THE COUNT WITHOUT LEADING ZEROS
        SRC 0
        RD3
        XCH 2
        RD2
        XCH 3
        RD1
        XCH 4
        RD0
        XCH 5
        FIM 14,0F0H     ; R14R15 SELECTS ROM PORT 15, THE CONSOLE
        SRC 14
        LDM 0
        XCH 6           ; R6 = 0 UNTIL A DIGIT IS PRINTED
        LD 2
        JMS PDIG
        LD 3
        JMS PDIG
        LD 4
        JMS PDIG
        LDM 1
        XCH 6
        LD 5
        JMS PDIG
        FIM 0,MSG
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

; PRINT THE DIGIT IN THE ACCUMULATOR UNLESS IT IS A LEADING ZERO.
PDIG:   XCH 7
        LD 7
        JCN 0CH,PDIG1
        LD 6
        JCN 4,PDIGX
PDIG1:  LDM 1
        XCH 6
        LDM 3
        WRR
        LD 7
        WRR
PDIGX:  BBL 0
MSG:    DB 20H,70H,72H,69H,6DH,65H,73H,2EH,0DH,0

; THE BIT TABLE: AT 40H TIMES THE BIT, FOR EACH CHARACTER VALUE V, THE
; HIGH NIBBLE IS 1 IF THE BIT IS SET AND THE LOW NIBBLE IS V WITHOUT IT.
; THE SCAN AND CLEARING LOOPS FILL THE GAPS, SINCE FIN READS ITS OWN PAGE.
        ORG 100H
        DB 00H,10H,02H,12H,04H,14H,06H,16H
        DB 08H,18H,0AH,1AH,0CH,1CH,0EH,1EH
SCAN:   SRC 4           ; IS FLAG I SET?
        RDM
        XCH 1
        LD 10
        XCH 0
        FIN 2
        LD 2
        JCN 0CH,ISPRM
NEXTB:  CLC             ; I = I + 1
        LDM 4
        ADD 10
        XCH 10
        JCN 0AH,SCAN
        ISZ 5,SCAN
        ISZ 4,SCAN
        JUN NBANK
ISPRM:  JUN PRIME
        ORG 140H
        DB 00H,01H,10H,11H,04H,05H,14H,15H
        DB 08H,09H,18H,19H,0CH,0DH,1CH,1DH
KLOOP:  LD 13           ; CLEAR FLAG K
        DCL
        SRC 6
        RDM
        XCH 1
        LD 12
        XCH 0
        FIN 2
        LD 3
        WRM
        CLC             ; K = K + P
        LD 12
        ADD 14
        XCH 12
        LD 7
        ADD 9
        XCH 7
        LD 6
        ADD 8
        XCH 6
        LD 13
        ADD 15
        XCH 13
        JCN 2,KDONE     ; PAST BANK 15
        LD 13
        RAL
        JCN 0AH,KLOOP   ; BANK 8 OR MORE ENDS THE LOOP
KDONE:  JUN COUNT
        ORG 180H
        DB 00H,01H,02H,03H,10H,11H,12H,13H
        DB 08H,09H,0AH,0BH,18H,19H,1AH,1BH
        ORG 1C0H
        DB 00H,01H,02H,03H,04H,05H,06H,07H
        DB 10H,11H,12H,13H,14H,15H,16H,17H

; FLAG I IS SET: P = I + I + 3 IS PRIME. CLEAR ITS ODD MULTIPLES FROM
; K = I + P, AND COUNT IT.
        ORG 200H
PRIME:  CLC             ; P = 2I
        LD 10
        ADD 10
        XCH 14
        LD 5
        ADD 5
        XCH 9
        LD 4
        ADD 4
        XCH 8
        LD 11
        ADD 11
        XCH 15
        CLC             ; P = P + 3, WHICH IS 12 IN THE BIT FIELD
        LDM 12
        ADD 14
        XCH 14
        LDM 0
        ADD 9
        XCH 9
        LDM 0
        ADD 8
        XCH 8
        LDM 0
        ADD 15
        XCH 15
        CLC             ; K = I + P
        LD 10
        ADD 14
        XCH 12
        LD 5
        ADD 9
        XCH 7
        LD 4
        ADD 8
        XCH 6
        LD 11
        ADD 15
        XCH 13
        JCN 2,COUNT
        LD 13
        RAL
        JCN 2,COUNT     ; K IS PAST THE SIEVE
        JUN KLOOP
COUNT:  LDM 0           ; COUNT = COUNT + 1, IN BCD
        DCL
        FIM 0,00H
        SRC 0
        RD0
        IAC
        DAA
        WR0
        JCN 0AH,CDONE
        RD1
        IAC
        DAA
        WR1
        JCN 0AH,CDONE
        RD2
        IAC
        DAA
        WR2
        JCN 0AH,CDONE
        RD3
        IAC
        DAA
        WR3
CDONE:  LD 11           ; BACK TO THE SCAN'S BANK
        DCL
        JUN NEXTB
        END
