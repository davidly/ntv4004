; SIEVE FOR NTV4004: THE BYTE ODD-NUMBER SIEVE, SIZE 8190, TEN PASSES,
; PRINTING 1899 PRIMES. A PORT OF THE 8008 AND 8080 SIEVE BENCHMARKS.
; FLAG K IS ONE BIT OF THE 4002 RAM: BANK K SHR 10, CHARACTER (K SHR 2)
; AND 0FFH, BIT K AND 3. ALL EIGHT BANKS HOLD 8192 FLAGS; FLAG 8191 IS 0.
; NUMBERS ARE KEPT IN THOSE FIELDS: THE BIT TIMES 4 IN A REGISTER, SO
; ADDING TWO BIT FIELDS CARRIES INTO THE CHARACTER, THE CHARACTER IN A
; REGISTER PAIR FOR SRC, AND THE BANK. THE SCAN ROTATES EACH CHARACTER'S
; FLAGS OUT THROUGH THE CARRY; THE 4004 HAS NO AND, SO A FIN TABLE CLEARS
; A BIT WHEN MARKING.
; R0R1 FIN INDEX: K BIT TIMES 4, CHARACTER  R2R3 FIN RESULT: SET, CLEARED
; R4R5 I CHARACTER   R10 I BIT X4   R11 I BANK
; R6R7 K CHARACTER   R0 K BIT X4   R13 K BANK
; R8R9 P CHARACTER   R14 P BIT X4   R15 P BANK, WHERE P = 2I+3
; THE PRIME COUNT IS BINARY: ITS LOW NIBBLE IN R12, ITS HIGHER ONES IN
; BANK 0, RAM REGISTER 0, STATUS 0 AND 1
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
        XCH 12
        FIM 0,00H
        SRC 0
        LDM 0
        WR0
        WR1
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
        FIM 0,00H       ; THE COUNT, IN R8R9R10
        SRC 0
        RD1
        XCH 8
        RD0
        XCH 9
        LD 12
        XCH 10
        FIM 14,0F0H     ; R14R15 SELECTS ROM PORT 15, THE CONSOLE
        SRC 14
        LDM 0
        XCH 6           ; R6 = 0 UNTIL A DIGIT IS PRINTED
        FIM 0,03H       ; THOUSANDS: 1000 = 3E8H, IN R1R2R3
        FIM 2,0E8H
        JMS DECIM
        FIM 0,00H       ; HUNDREDS
        FIM 2,64H
        JMS DECIM
        FIM 2,0AH       ; TENS
        JMS DECIM
        LDM 1
        XCH 6
        LD 10           ; ONES
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

; PRINT ONE DECIMAL COLUMN OF R8R9R10, WITH PLACE VALUE R1R2R3: SUBTRACT
; AT MOST NINE TIMES. R13 TO R15 ARE FREE AFTER SELECTING THE PORT.
DECIM:  LDM 0
        XCH 11
DLOOP:  CLC
        LD 10
        SUB 3
        XCH 13
        CMC
        LD 9
        SUB 2
        XCH 14
        CMC
        LD 8
        SUB 1
        JCN 0AH,DPRINT
        XCH 8
        LD 14
        XCH 9
        LD 13
        XCH 10
        INC 11
        JUN DLOOP
DPRINT: LD 11
        JUN PDIG

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
; THE CLEARING LOOPS NEED NO CLC: EVERY WAY IN, AND BACK, HAS CARRY 0.
        ORG 100H
        DB 00H,10H,02H,12H,04H,14H,06H,16H
        DB 08H,18H,0AH,1AH,0CH,1CH,0EH,1EH
SCAN:   SRC 4           ; I'S CHARACTER: ROTATE ITS FLAGS OUT, BIT 0 FIRST
        RDM
        JCN 4,NEXTC     ; NO FLAG IS SET
        RAR
        JCN 2,P0
T1:     RAR
        JCN 2,P1
T2:     RAR
        JCN 2,P2
T3:     RAR
        JCN 2,P3
NEXTC:  ISZ 5,SCAN      ; THE NEXT CHARACTER
        ISZ 4,SCAN
        JUN NBANK
P0:     JUN PRM0        ; FLAG I IS SET, AT BIT 0 TO 3
P1:     JUN PRM1
P2:     JUN PRM2
P3:     JUN PRM3
        ORG 140H
        DB 00H,01H,10H,11H,04H,05H,14H,15H
        DB 08H,09H,18H,19H,0CH,0DH,1CH,1DH
KLOOP:  LD 13           ; CLEAR FLAG K
        DCL
        SRC 6
        RDM
        XCH 1
        FIN 2
        LD 3
        WRM
        LD 0            ; K = K + P
        ADD 14
        XCH 0
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
; P < 1024: ITS BANK FIELD IS ZERO. ONLY A CHARACTER OVERFLOW CHANGES
; THE BANK, SO THE COMMON MARKING STEP NEEDS NO BANK ADD OR DCL.
KFAST:  SRC 6
        RDM
        XCH 1
        FIN 2
        LD 3
        WRM
        LD 0            ; K = K + P
        ADD 14
        XCH 0
        LD 7
        ADD 9
        XCH 7
        LD 6
        ADD 8
        XCH 6
        JCN 0AH,KFAST
        INC 13
        LD 13
        RAL
        JCN 2,KFDON
        LD 13
        DCL
        JUN KFAST
KFDON:  JUN COUNT
        ORG 1C0H
        DB 00H,01H,02H,03H,04H,05H,06H,07H
        DB 10H,11H,12H,13H,14H,15H,16H,17H

; P < 64: ONLY A LOW-CHARACTER OVERFLOW NEEDS THE HIGH CHARACTER UPDATED.
        ORG 1D0H
KSMAL:  SRC 6
        RDM
        XCH 1
        FIN 2
        LD 3
        WRM
        LD 0            ; K = K + P
        ADD 14
        XCH 0
        LD 7
        ADD 9
        XCH 7
        JCN 0AH,KSMAL
        LD 6
        IAC
        XCH 6
        JCN 0AH,KSMAL
        INC 13
        LD 13
        RAL
        JCN 2,KSDON
        LD 13
        DCL
        JUN KSMAL
KSDON:  JUN COUNT

; FLAG I IS SET: P = I + I + 3 IS PRIME. CLEAR ITS ODD MULTIPLES FROM
; K = I + P, AND COUNT IT. I'S BIT B FIXES P'S AND K'S BIT FIELDS AND THE
; CARRIES INTO THEIR CHARACTERS, SO EACH BIT HAS ITS OWN ENTRY:
;   B   2B+3 = P'S BIT, CARRY   B + P'S BIT = K'S BIT, CARRY
;   0          3, 0                   3, 0
;   1          1, 1                   2, 0
;   2          3, 1                   1, 1
;   3          1, 2                   0, 1
        ORG 200H
PRM0:   LDM 0           ; I'S BIT FIELD, FOR RESUMING THE SCAN
        XCH 10
        LDM 12
        XCH 14
        CLC             ; P'S CHARACTER AND BANK: 2I + 0
        LD 5
        ADD 5
        XCH 9
        LD 4
        ADD 4
        XCH 8
        LD 11
        ADD 11
        XCH 15
        LDM 12
        XCH 0
        CLC             ; K = I + P
        LD 5
        ADD 9
        XCH 7
        LD 4
        ADD 8
        XCH 6
        LD 11
        ADD 15
        XCH 13
        JUN KCHK
PRM1:   LDM 4           ; I'S BIT FIELD, FOR RESUMING THE SCAN
        XCH 10
        LDM 4
        XCH 14
        STC             ; P'S CHARACTER AND BANK: 2I + 1
        LD 5
        ADD 5
        XCH 9
        LD 4
        ADD 4
        XCH 8
        LD 11
        ADD 11
        XCH 15
        LDM 8
        XCH 0
        CLC             ; K = I + P
        LD 5
        ADD 9
        XCH 7
        LD 4
        ADD 8
        XCH 6
        LD 11
        ADD 15
        XCH 13
        JUN KCHK
PRM2:   LDM 8           ; I'S BIT FIELD, FOR RESUMING THE SCAN
        XCH 10
        LDM 12
        XCH 14
        STC             ; P'S CHARACTER AND BANK: 2I + 1
        LD 5
        ADD 5
        XCH 9
        LD 4
        ADD 4
        XCH 8
        LD 11
        ADD 11
        XCH 15
        LDM 4
        XCH 0
        STC             ; K = I + P
        LD 5
        ADD 9
        XCH 7
        LD 4
        ADD 8
        XCH 6
        LD 11
        ADD 15
        XCH 13
        JUN KCHK
PRM3:   LDM 12          ; I'S BIT FIELD, FOR RESUMING THE SCAN
        XCH 10
        LDM 4
        XCH 14
        STC             ; P'S CHARACTER AND BANK: 2I + 2
        LD 5
        ADD 5
        XCH 9
        LD 4
        ADD 4
        XCH 8
        LD 11
        ADD 11
        XCH 15
        ISZ 9,PK3     ; THE SECOND CARRY
        ISZ 8,PK3
        INC 15
PK3:    LDM 0
        XCH 0
        STC             ; K = I + P
        LD 5
        ADD 9
        XCH 7
        LD 4
        ADD 8
        XCH 6
        LD 11
        ADD 15
        XCH 13
KCHK:   JCN 2,COUNT
        LD 13
        RAL
        JCN 2,COUNT     ; K IS PAST THE SIEVE
        LD 15
        JCN 0CH,KLARGE
        LD 13
        DCL
        LD 8
        JCN 0CH,KMID
        JUN KSMAL
KMID:   JUN KFAST
KLARGE: JUN KLOOP
COUNT:  ISZ 12,CDONE     ; COUNT = COUNT + 1, CARRYING INTO RAM ONE TIME IN 16
        LDM 0
        DCL
        FIM 0,00H
        SRC 0
        RD0
        IAC
        WR0
        JCN 0AH,CDONE
        RD1
        IAC
        WR1
CDONE:  LD 11           ; RESUME THE SCAN AFTER I'S BIT, READING THE CHARACTER
        DCL             ; AGAIN: MARKING MAY HAVE CLEARED ITS LATER FLAGS
        SRC 4
        LD 10
        JCN 4,RES0
        CLC
        LDM 4
        SUB 10
        JCN 4,RES1
        CLC
        LDM 8
        SUB 10
        JCN 4,RES2
        JUN NEXTC       ; AFTER BIT 3, THE NEXT CHARACTER
RES0:   RDM
        RAR
        JUN T1
RES1:   RDM
        RAR
        RAR
        JUN T2
RES2:   RDM
        RAR
        RAR
        RAR
        JUN T3
        END
