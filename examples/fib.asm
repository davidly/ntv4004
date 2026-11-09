; FIB FOR NTV4004: PRINT THE FIRST 70 FIBONACCI NUMBERS. EACH IS 16 BCD
; DIGITS IN A 4002 RAM REGISTER, LEAST SIGNIFICANT IN CHARACTER 0, AND
; THE SUMS USE ADM AND DAA, THE 4004'S DECIMAL ARITHMETIC.
        FIM 14,0F0H     ; R14R15 SELECTS ROM PORT 15, THE CONSOLE
        FIM 0,00H       ; A = 1 IN RAM REGISTER 0
        SRC 0
        LDM 1
        WRM
        FIM 0,10H       ; B = 1 IN RAM REGISTER 1
        SRC 0
        WRM
        FIM 8,256-35    ; R8R9 COUNTS 35 PAIRS OF NUMBERS UP TO 256
MAIN:   LDM 0
        XCH 4
        JMS PRNUM       ; PRINT A
        FIM 0,00H
        FIM 2,10H
        JMS ADDTO       ; A = A + B
        LDM 1
        XCH 4
        JMS PRNUM       ; PRINT B
        FIM 0,10H
        FIM 2,00H
        JMS ADDTO       ; B = B + A
        ISZ 9,MAIN
        INC 8
        LD 8
        JCN 0CH,MAIN
DONE:   JUN DONE

; ADD RAM REGISTER R2 TO RAM REGISTER R0, 16 BCD DIGITS.
ADDTO:  LDM 0
        XCH 1
        LDM 0
        XCH 3
        CLC
ADLOOP: SRC 2
        RDM
        SRC 0
        ADM             ; DIGIT + DIGIT + CARRY
        DAA             ; DECIMAL ADJUST; CARRY OUT TO THE NEXT DIGIT
        WRM
        INC 3
        ISZ 1,ADLOOP
        BBL 0

; PRINT RAM REGISTER R4 IN DECIMAL WITHOUT LEADING ZEROS, THEN A NEWLINE.
PRNUM:  LDM 15
        XCH 5           ; R5 = THE DIGIT, 15 DOWN TO 0
        LDM 0
        XCH 6           ; R6 = 0 UNTIL A DIGIT IS PRINTED
PRLOOP: SRC 4
        RDM
        XCH 7           ; R7 = THE DIGIT
        LD 7
        JCN 0CH,PRDIG
        LD 6
        JCN 0CH,PRDIG
        LD 5
        JCN 0CH,PRSKIP  ; A LEADING ZERO, NOT THE LAST DIGIT
PRDIG:  LDM 1
        XCH 6
        SRC 14
        LDM 3           ; DIGITS ARE 30H TO 39H
        WRR
        LD 7
        WRR
PRSKIP: LD 5
        DAC             ; CARRY 0 AFTER THE LAST DIGIT
        XCH 5
        JCN 2,PRLOOP
        SRC 14
        LDM 0
        WRR
        LDM 0DH         ; CARRIAGE RETURN; NTV4004 PRINTS A NEWLINE
        WRR
        BBL 0
        END
