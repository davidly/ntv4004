; TTT FOR NTV4004: THE TIC-TAC-TOE BENCHMARK. ALPHA-BETA MINIMAX OVER
; EVERY GAME AFTER X'S FIRST MOVE AT 0, 1 AND 4, AS IN THE 8008 AND 8080
; TTT BENCHMARKS. EVERY FIRST MOVE SCORES A TIE; ONE ITERATION VISITS
; 6493 NODES. SCORES ARE 2 TO 9: X WINS 6, TIE 5, O WINS 4.
; THE 4004'S STACK HAS ONLY THREE LEVELS, SO THE SEARCH KEEPS A FRAME PER
; DEPTH D IN THE STATUS CHARACTERS OF 4002 RAM REGISTER D: 0 THE MOVE
; BEING TRIED, 1 THE VALUE, 2 ALPHA, 3 BETA. EVEN DEPTHS MINIMIZE (O TO
; MOVE), ODD DEPTHS MAXIMIZE (X TO MOVE).
; RAM REGISTER 15 IS THE BOARD: 0 BLANK, 1 O, 2 X, CELL N IN CHARACTER
; 7+N, SO THAT ISZ ENDS THE SEARCH FOR MOVES AFTER CELL 8, CHARACTER 15,
; WITHOUT A COMPARISON. THE NODE COUNT IS BINARY: LOW NIBBLES
; IN R15 AND R7, HIGH NIBBLES IN RAM REGISTER 14'S STATUS 2 AND 3.
; R7 CAN HOLD A COUNT DIGIT BECAUSE SRC 6'S LOW NIBBLE DOES NOT AFFECT
; WHICH STATUS REGISTER RD0-RD3/WR0-WR3 ADDRESS.
; R4R5 SELECTS BOARD CHARACTER R5 (R4 = 15), SO R5 IS ALSO THE MOVE
; BEING TRIED   R6R7 SELECTS FRAME R6 = D
; R9 THE VALUE   R10 ALPHA   R11 BETA   R12 A SCORE
; R13 THE FIRST MOVE'S NUMBER   R14 THE LAST PIECE PLACED
; R0-R3 ARE WORK REGISTERS.
; R7 AND R15 MUST BE PRESERVED THROUGHOUT THE SEARCH.
        ORG 0
        FIM 4,0F0H
        LDM 0
        XCH 13
        FIM 14,0
        LDM 0
        XCH 7
RLOOP:  FIM 0,ROOTM     ; R3 = THE FIRST MOVE
        LD 13
        XCH 1
        FIN 2
        LD 3            ; X MOVES THERE
        XCH 5
        SRC 4
        LDM 2
        WRM
        LDM 0           ; DEPTH 0, ALPHA 2, BETA 9
        XCH 6
        FIM 10,29H
        JUN ENTER
ROOTDN: FIM 0,ROOTM     ; UNDO THE FIRST MOVE
        LD 13
        XCH 1
        FIN 2
        LD 3
        XCH 5
        SRC 4
        LDM 0
        WRM
        INC 13
        CLC
        LDM 3
        SUB 13
        JCN 0CH,RLOOP
        LD 15           ; SAVE THE TWO CACHED LOW BINARY COUNT NIBBLES
        XCH 11
        LD 7
        XCH 10
        FIM 14,0F0H     ; R14R15 SELECTS ROM PORT 15, THE CONSOLE
        SRC 14
        FIM 0,MOVESM
        JMS PRINT
        FIM 0,0E0H      ; LOAD THE BINARY COUNT INTO R8-R11
        SRC 0
        RD3
        XCH 8
        RD2
        XCH 9
        SRC 14
        LDM 0
        XCH 6           ; SUPPRESS LEADING ZERO DIGITS
        FIM 0,03H
        FIM 2,0E8H      ; THOUSANDS: 1000 = 03E8H
        JMS DECIM
        FIM 0,00H
        FIM 2,64H       ; HUNDREDS
        JMS DECIM
        FIM 2,0AH       ; TENS
        JMS DECIM
        LDM 1
        XCH 6
        LD 11           ; ONES
        JMS PDIG
        FIM 0,ITERM
        JMS PRINT
DONE:   JUN DONE

; PRINT ONE DECIMAL COLUMN OF R8-R11, WITH PLACE VALUE R0-R3.
; SUBTRACT AT MOST NINE TIMES. R14-R15 ARE FREE AFTER SELECTING THE PORT.
DECIM:  LDM 0
        XCH 12
DLOOP:  CLC
        LD 11
        SUB 3
        XCH 13
        CMC
        LD 10
        SUB 2
        XCH 14
        CMC
        LD 9
        SUB 1
        XCH 15
        CMC
        LD 8
        SUB 0
        JCN 0AH,DPRINT
        XCH 8
        LD 15
        XCH 9
        LD 14
        XCH 10
        LD 13
        XCH 11
        INC 12
        JUN DLOOP
DPRINT: LD 12
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

; PRINT THE ZERO-TERMINATED MESSAGE AT R0R1 ON THIS PAGE.
PRINT:  FIN 2
        LD 2
        JCN 0CH,PSHOW
        LD 3
        JCN 4,PDONE
PSHOW:  LD 2
        WRR
        LD 3
        WRR
        ISZ 1,PRINT
        INC 0
        JUN PRINT
PDONE:  BBL 0
        ORG 0D0H
ROOTM:  DB 7,8,11        ; CELLS 0, 1 AND 4
MOVESM: DB 6DH,6FH,76H,65H,73H,3AH,20H,0
ITERM:  DB 0DH,69H,74H,65H,72H,61H,74H,69H,6FH,6EH,73H,3AH,20H,31H,0DH,0

; ENTER A NODE AT DEPTH R6 AFTER THE MOVE TO CHARACTER R5, WITH ALPHA AND
; BETA IN R10 AND R11.
        ORG 100H
FOUND:  LD 6            ; THE PIECE IS 1 + (DEPTH AND 1): X (2) ON ODD DEPTHS
        RAR
        TCC
        IAC
        XCH 14          ; KEPT FOR THE CHILD'S WIN CHECK
        LD 14
PLACE:  WRM
        SRC 6           ; SAVE THIS FRAME
        LD 5
        WR0
        LD 9
        WR1
        LD 10
        WR2
        LD 11
        WR3
        INC 6           ; ENTER THE CHILD, WHOSE MOVE IS R5
ENTER:  ISZ 15,COUNTED  ; BINARY NODE COUNT: R15, R7, STATUS 2 AND STATUS 3
        ISZ 7,COUNTED
        FIM 0,0E0H
        SRC 0
        RD2
        IAC
        WR2
        JCN 0AH,COUNTED
        RD3
        IAC
        WR3
COUNTED: CLC            ; ONLY DEPTHS 4 AND UP CAN HAVE A WINNER
        LDM 3
        SUB 6
        JCN 2,START
; DISPATCH THE LAST MOVE, BY PIECE R14, TO ITS DIRECT LINE CHECKS, WHICH JUMP
; TO WON OR NOWIN. NO SENTINEL OR PAIR-TABLE LOOP IS NEEDED; EACH CELL
; HAS ONLY TWO TO FOUR LINES. WTAB AND ITS JUMPS SHARE THIS PAGE, AS FIN
; AND JIN USE THEIR OWN PAGE.
WINNER: FIM 0,WTAB AND 0F0H ; R1 = THE CHARACTER, 7 TO 15
        LD 5
        XCH 1
        FIN 0
        JIN 0
WON:    LDM 6           ; THE LAST MOVER WON: X AT EVEN DEPTHS, O AT ODD ONES
        XCH 12
        LD 6
        RAR
        JCN 0AH,RETURN
        LDM 4
        XCH 12
        JUN RETURN
NOWIN:  CLC             ; DEPTH 8 IS A FULL BOARD: A TIE
        LDM 8
        SUB 6
        JCN 0CH,START
        LDM 5
        XCH 12
        JUN RETURN
START:  LDM 7           ; TRY THE MOVES FROM CELL 0
        XCH 5
        LDM 9           ; MINIMIZE FROM 9 OR MAXIMIZE FROM 2
        XCH 9
        LD 6
        RAR
        JCN 0AH,NEXT
        LDM 2
        XCH 9
NEXT:   SRC 4           ; FIND THE NEXT BLANK CELL
        RDM
        JCN 4,FOUND
        ISZ 5,NEXT      ; AFTER CHARACTER 15 THERE ARE NO MORE
NOMORE: LD 9
        XCH 12

; RETURN SCORE R12 TO THE PARENT.
RETURN: LD 6
        JCN 4,TOROOT
        DAC
        XCH 6
        SRC 6           ; RESTORE THE PARENT'S FRAME
        RD0
        XCH 5
        RD1
        XCH 9
        RD2
        XCH 10
        RD3
        XCH 11
        SRC 4           ; UNDO ITS MOVE
        LDM 0
        WRM
        LD 6
        RAR
        JCN 2,RMAX
        CLC             ; MINIMIZE: O WINNING ENDS THE SEARCH
        LDM 4
        SUB 12
        JCN 4,RETURN
        STC             ; SCORE < VALUE? (CARRY 1 MAKES SUB TAKE ONE MORE)
        LD 9
        SUB 12
        JCN 0AH,RNEXT
        LD 12
        XCH 9
        CLC             ; VALUE <= ALPHA RETURNS IT
        LD 10
        SUB 9
        JCN 2,RETURN
        STC             ; VALUE < BETA LOWERS BETA
        LD 11
        SUB 9
        JCN 0AH,RNEXT
        LD 9
        XCH 11
        JUN RNEXT
RMAX:   CLC             ; MAXIMIZE: X WINNING ENDS THE SEARCH
        LDM 6
        SUB 12
        JCN 4,RETURN
        STC             ; SCORE > VALUE?
        LD 12
        SUB 9
        JCN 0AH,RNEXT
        LD 12
        XCH 9
        CLC             ; VALUE >= BETA RETURNS IT
        LD 9
        SUB 11
        JCN 2,RETURN
        STC             ; VALUE > ALPHA RAISES ALPHA
        LD 9
        SUB 10
        JCN 0AH,RNEXT
        LD 9
        XCH 10
RNEXT:  ISZ 5,NEXT
        JUN NOMORE
TOROOT: JUN ROOTDN
; THE LINE CHECKS FOR EACH LAST MOVE, BY ITS CHARACTER, 7 TO 15.
        ORG 1D7H
WTAB:   DB JT0 AND 0FFH,JT1 AND 0FFH,JT2 AND 0FFH,JT3 AND 0FFH
        DB JT4 AND 0FFH,JT5 AND 0FFH,JT6 AND 0FFH,JT7 AND 0FFH
        DB JT8 AND 0FFH
JT0:    JUN W0
JT1:    JUN W1
JT2:    JUN W2
JT3:    JUN W3
JT4:    JUN W4
JT5:    JUN W5
JT6:    JUN W6
JT7:    JUN W7
JT8:    JUN W8

        ORG 300H
; LAST MOVE: CELL 0
W0:     FIM 4,0F7H+1
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C01
        FIM 4,0F7H+2
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C01:     FIM 4,0F7H+3
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C02
        FIM 4,0F7H+6
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C02:     FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO3
        FIM 4,0F7H+8
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
        JUN NOWIN
; LAST MOVE: CELL 1
W1:     FIM 4,0F7H+0
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C11
        FIM 4,0F7H+2
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C11:     FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO3
        FIM 4,0F7H+7
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
        JUN NOWIN
; LAST MOVE: CELL 2
W2:     FIM 4,0F7H+0
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C21
        FIM 4,0F7H+1
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C21:     FIM 4,0F7H+5
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C22
        FIM 4,0F7H+8
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C22:     FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO3
        FIM 4,0F7H+6
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
        JUN NOWIN
; LAST MOVE: CELL 3
W3:     FIM 4,0F7H+0
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C31
        FIM 4,0F7H+6
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C31:     FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO3
        FIM 4,0F7H+5
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
        JUN NOWIN
; LAST MOVE: CELL 4
W4:     FIM 4,0F7H+0
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C41
        FIM 4,0F7H+8
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C41:     FIM 4,0F7H+2
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C42
        FIM 4,0F7H+6
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C42:     FIM 4,0F7H+1
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C43
        FIM 4,0F7H+7
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
C43:     FIM 4,0F7H+3
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO3
        FIM 4,0F7H+5
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES3
        JUN NOWIN
WNO3:   JUN NOWIN
WYES3:  JUN WON

        ORG 400H
; LAST MOVE: CELL 5
W5:     FIM 4,0F7H+3
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C51
        FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
C51:     FIM 4,0F7H+2
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO4
        FIM 4,0F7H+8
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
        JUN NOWIN
; LAST MOVE: CELL 6
W6:     FIM 4,0F7H+0
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C61
        FIM 4,0F7H+3
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
C61:     FIM 4,0F7H+7
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C62
        FIM 4,0F7H+8
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
C62:     FIM 4,0F7H+2
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO4
        FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
        JUN NOWIN
; LAST MOVE: CELL 7
W7:     FIM 4,0F7H+1
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C71
        FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
C71:     FIM 4,0F7H+6
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO4
        FIM 4,0F7H+8
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
        JUN NOWIN
; LAST MOVE: CELL 8
W8:     FIM 4,0F7H+0
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C81
        FIM 4,0F7H+4
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
C81:     FIM 4,0F7H+2
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,C82
        FIM 4,0F7H+5
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
C82:     FIM 4,0F7H+6
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNO4
        FIM 4,0F7H+7
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES4
        JUN NOWIN
WNO4:   JUN NOWIN
WYES4:  JUN WON
        END
