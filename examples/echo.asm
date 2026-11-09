; ECHO FOR NTV4004: COPY CONSOLE INPUT TO THE CONSOLE, CONVERTING
; LOWERCASE LETTERS TO UPPERCASE, UNTIL A PERIOD. ROM PORT 15 READS AND
; WRITES A CHARACTER AS TWO NIBBLES, HIGH FIRST.
        FIM 14,0F0H     ; R14R15 SELECTS ROM PORT 15
        SRC 14
LOOP:   RDR             ; R0R1 = THE NEXT CHARACTER
        XCH 0
        RDR
        XCH 1
        CLC
        LDM 6           ; 61H-6FH ARE LETTERS
        SUB 0
        JCN 4,SIX
        CLC
        LDM 7           ; SO ARE 70H-7AH
        SUB 0
        JCN 0CH,SHOW
        CLC
        LDM 0AH
        SUB 1           ; NO BORROW (CARRY 1) WHEN R1 <= 0AH
        JCN 0AH,SHOW    ; JUMP IF CARRY 0
        JUN UPPER
SIX:    LD 1
        JCN 4,SHOW      ; 60H IS NOT A LETTER
UPPER:  LD 0            ; LOWERCASE TO UPPERCASE: SUBTRACT 20H
        DAC
        DAC
        XCH 0
SHOW:   LD 0
        WRR
        LD 1
        WRR
        CLC             ; STOP AFTER A PERIOD, 2EH
        LDM 2
        SUB 0
        JCN 0CH,LOOP
        CLC
        LDM 0EH
        SUB 1
        JCN 0CH,LOOP
DONE:   JUN DONE
        END
