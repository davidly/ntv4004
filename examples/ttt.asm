; TTT FOR NTV4004: THE TIC-TAC-TOE BENCHMARK. ALPHA-BETA MINIMAX OVER
; EVERY GAME AFTER X'S FIRST MOVE AT 0, 1 AND 4, AS IN THE 8008 AND 8080
; TTT BENCHMARKS. EVERY FIRST MOVE SCORES A TIE; ONE ITERATION VISITS
; 6493 NODES. SCORES ARE 2 TO 9: X WINS 6, TIE 5, O WINS 4.
; THE 4004'S STACK HAS ONLY THREE LEVELS, SO THE SEARCH KEEPS A FRAME PER
; DEPTH D IN THE STATUS CHARACTERS OF 4002 RAM REGISTER D: 0 THE MOVE
; BEING TRIED, 1 THE VALUE, 2 ALPHA, 3 BETA. EVEN DEPTHS MINIMIZE (O TO
; MOVE), ODD DEPTHS MAXIMIZE (X TO MOVE).
; RAM REGISTER 15 IS THE BOARD: 0 BLANK, 1 X, 2 O, WITH A BLANK CELL 9
; THAT ENDS THE SEARCH FOR MOVES. RAM REGISTER 14'S STATUS CHARACTERS
; COUNT THE NODES IN BCD.
; R4R5 SELECTS BOARD CELL R5 (R4 = 15)   R6R7 SELECTS FRAME R6 = D
; R8 THE MOVE   R9 THE VALUE   R10 ALPHA   R11 BETA   R12 A SCORE
; R13 THE FIRST MOVE'S NUMBER   R0-R3 AND R14 ARE WORK REGISTERS.
        ORG 0
        FIM 4,0F0H
        LDM 0
        XCH 13
RLOOP:  FIM 0,ROOTM     ; R3 = THE FIRST MOVE
        LD 13
        XCH 1
        FIN 2
        LD 3            ; X MOVES THERE
        XCH 5
        SRC 4
        LDM 1
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
        FIM 14,0F0H     ; R14R15 SELECTS ROM PORT 15, THE CONSOLE
        SRC 14
        FIM 0,MOVESM
        JMS PRINT
        FIM 0,0E0H      ; THE COUNT, WITHOUT LEADING ZEROS
        SRC 0
        RD3
        XCH 8
        RD2
        XCH 9
        RD1
        XCH 10
        RD0
        XCH 11
        SRC 14
        LDM 0
        XCH 6           ; R6 = 0 UNTIL A DIGIT IS PRINTED
        LD 8
        JMS PDIG
        LD 9
        JMS PDIG
        LD 10
        JMS PDIG
        LDM 1
        XCH 6
        LD 11
        JMS PDIG
        FIM 0,ITERM
        JMS PRINT
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
ROOTM:  DB 0,1,4
MOVESM: DB 6DH,6FH,76H,65H,73H,3AH,20H,0
ITERM:  DB 0DH,69H,74H,65H,72H,61H,74H,69H,6FH,6EH,73H,3AH,20H,31H,0DH,0

; ENTER A NODE AT DEPTH R6 AFTER THE MOVE TO CELL R5, WITH ALPHA AND BETA
; IN R10 AND R11.
        ORG 100H
ENTER:  FIM 0,0E0H      ; COUNT THE NODE IN BCD
        SRC 0
        RD0
        IAC
        DAA
        WR0
        JCN 0AH,COUNTED
        RD1
        IAC
        DAA
        WR1
        JCN 0AH,COUNTED
        RD2
        IAC
        DAA
        WR2
        JCN 0AH,COUNTED
        RD3
        IAC
        DAA
        WR3
COUNTED: CLC            ; ONLY DEPTHS 4 AND UP CAN HAVE A WINNER
        LDM 3
        SUB 6
        JCN 2,START
        JMS WINNER
        JCN 4,NOWIN
        LDM 6           ; THE LAST MOVER WON: X AT EVEN DEPTHS, O AT ODD ONES
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
START:  LDM 0           ; TRY THE MOVES FROM CELL 0
        XCH 8
        LDM 9           ; MINIMIZE FROM 9 OR MAXIMIZE FROM 2
        XCH 9
        LD 6
        RAR
        JCN 0AH,NEXT
        LDM 2
        XCH 9
NEXT:   LD 8            ; FIND THE NEXT BLANK CELL; CELL 9 IS ALWAYS BLANK
        XCH 5
        SRC 4
        RDM
        JCN 4,FOUND
        INC 8
        JUN NEXT
FOUND:  CLC
        LDM 9
        SUB 8
        JCN 4,NOMORE
        LD 6            ; X (1) MOVES AT ODD DEPTHS, O (2) AT EVEN ONES
        RAR
        TCC
        JCN 0CH,PLACE
        LDM 2
PLACE:  WRM
        SRC 6           ; SAVE THIS FRAME
        LD 8
        WR0
        LD 9
        WR1
        LD 10
        WR2
        LD 11
        WR3
        INC 6           ; ENTER THE CHILD, WHOSE MOVE IS R5
        JUN ENTER
NOMORE: LD 9
        XCH 12

; RETURN SCORE R12 TO THE PARENT.
RETURN: LD 6
        JCN 4,TOROOT
        LD 6
        DAC
        XCH 6
        SRC 6           ; RESTORE THE PARENT'S FRAME
        RD0
        XCH 8
        RD1
        XCH 9
        RD2
        XCH 10
        RD3
        XCH 11
        LD 8            ; UNDO ITS MOVE
        XCH 5
        SRC 4
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
RNEXT:  INC 8
        JUN NEXT
TOROOT: JUN ROOTDN

; RETURN 1 IF THE PIECE ON CELL R5 COMPLETES A LINE THROUGH IT, OR 0.
        ORG 200H
WINNER: SRC 4           ; R14 = THE PIECE
        RDM
        XCH 14
        FIM 0,OFFS AND 0FFH ; R0R1 = THE START OF THE CELL'S LINES
        LD 5
        XCH 1
        FIN 0
WLOOP:  FIN 2           ; R2, R3 = THE LINE'S OTHER CELLS
        LD 2
        IAC
        JCN 4,WNO       ; 0FFH ENDS THE LIST
        LD 2
        XCH 5
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 0CH,WNEXT
        LD 3
        XCH 5
        SRC 4
        RDM
        CLC
        SUB 14
        JCN 4,WYES
WNEXT:  ISZ 1,WLOOP
        INC 0
        JUN WLOOP
WYES:   BBL 1
WNO:    BBL 0
        ORG 280H
OFFS:   DB L0 AND 0FFH,L1 AND 0FFH,L2 AND 0FFH,L3 AND 0FFH,L4 AND 0FFH
        DB L5 AND 0FFH,L6 AND 0FFH,L7 AND 0FFH,L8 AND 0FFH
L0:     DB 12H,36H,48H,0FFH
L1:     DB 02H,47H,0FFH
L2:     DB 01H,58H,46H,0FFH
L3:     DB 06H,45H,0FFH
L4:     DB 08H,26H,17H,35H,0FFH
L5:     DB 34H,28H,0FFH
L6:     DB 03H,78H,24H,0FFH
L7:     DB 14H,68H,0FFH
L8:     DB 04H,25H,67H,0FFH
        END
