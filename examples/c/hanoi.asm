; HANOI: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0FH
        XCH 0DH
        JMS QCLR
; THE SAVE STACK
        FIM 4,0
        FIM 6,0
        FIM 0,0
        JMS QSTA
MAIN:
; MAIN
; SHOWING = 1;
        FIM 4,0
        FIM 6,1
        JMS QTST
        JMS QBOOL
        FIM 0,020H
        JMS QSTAC
; HANOI(3, 0, 2, 1);
        FIM 4,0
        FIM 6,3
        FIM 0,050H
        JMS QSTN0
        FIM 4,0
        FIM 6,0
        FIM 0,050H
        JMS QSTN1
        FIM 4,0
        FIM 6,2
        FIM 0,050H
        JMS QSTN2
        FIM 4,0
        FIM 6,1
        FIM 0,050H
        JMS QSTN3
        FIM 6,4
        FIM 0,040H
        JMS QSTAC
        JUN HANOI
L0001:
; PRINTF("3 DISCS: %D MOVES?N", MOVES);
        FIM 0,S0001 AND 0FFH
        JMS QS1
        FIM 0,010H
        JMS QLDA
        JMS QPRTD
        FIM 0,S0002 AND 0FFH
        JMS QS1
; SHOWING = 0;
        FIM 4,0
        FIM 6,0
        JMS QTST
        JMS QBOOL
        FIM 0,020H
        JMS QSTAC
; MOVES = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,010H
        JMS QSTA
; HANOI(10, 0, 2, 1);
        FIM 4,0
        FIM 6,0AH
        FIM 0,050H
        JMS QSTN0
        FIM 4,0
        FIM 6,0
        FIM 0,050H
        JMS QSTN1
        FIM 4,0
        FIM 6,2
        FIM 0,050H
        JMS QSTN2
        FIM 4,0
        FIM 6,1
        FIM 0,050H
        JMS QSTN3
        FIM 6,6
        FIM 0,040H
        JMS QSTAC
        JUN HANOI
L0002:
; PRINTF("10 DISCS: %D MOVES?N", MOVES);
        FIM 0,S0003 AND 0FFH
        JMS QS1
        FIM 0,010H
        JMS QLDA
        JMS QPRTD
        FIM 0,S0002 AND 0FFH
        JMS QS1
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
HANOI:
; HANOI
; IF (DISCS == 0)
        FIM 0,050H
        JMS QLDN0
        LD 7
        JCN 0CH,L0003
; RETURN;
        FIM 0,040H
        JUN QRETF
L0003:
; HANOI(DISCS - 1, FROM, SPARE, TO);
        FIM 0,040H
        LDM 0EH
        XCH 0DH
        JMS QSAVE
        JMS QDEC
        FIM 0,060H
        JMS QSTA
        FIM 0,050H
        JMS QLDN1
        FIM 0,070H
        JMS QSTA
        FIM 0,050H
        JMS QLDN3
        FIM 0,080H
        JMS QSTA
        FIM 0,050H
        JMS QLDN2
        FIM 0,090H
        JMS QSTA
        FIM 0,060H
        JMS QLDA
        FIM 0,050H
        JMS QSTN0
        FIM 0,070H
        JMS QLDA
        FIM 0,050H
        JMS QSTN1
        FIM 0,080H
        JMS QLDA
        FIM 0,050H
        JMS QSTN2
        FIM 0,090H
        JMS QLDA
        FIM 0,050H
        JMS QSTN3
        FIM 6,8
        FIM 0,040H
        JMS QSTAC
        JUN HANOI
L0004:
        FIM 0,040H
        FIM 2,0F8H
        LDM 0EH
        XCH 0DH
        JMS QRSTR
; MOVES++;
        FIM 0,010H
        JMS QINCV
; IF (SHOWING)
        FIM 0,020H
        JMS QLDA
        LD 7
        JCN 4,L0005
; PRINTF("DISC %D FROM %C TO %C?N", DISCS, 'A' + FROM, 'A' + TO);
        FIM 0,S0004 AND 0FFH
        JMS QS1
        FIM 0,050H
        JMS QLDN0
        JMS QPRTD
        FIM 0,S0005 AND 0FFH
        JMS QS1
        FIM 4,0
        FIM 6,041H
        FIM 0,050H
        JMS QLBN1
        JMS QADD
        JMS QPUTC
        FIM 0,S0006 AND 0FFH
        JMS QS1
        FIM 4,0
        FIM 6,041H
        FIM 0,050H
        JMS QLBN2
        JMS QADD
        JMS QPUTC
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
L0005:
; HANOI(DISCS - 1, SPARE, TO, FROM);
        FIM 0,040H
        LDM 0EH
        XCH 0DH
        JMS QSAVE
        FIM 0,050H
        JMS QLDN0
        JMS QDEC
        FIM 0,060H
        JMS QSTA
        FIM 0,050H
        JMS QLDN3
        FIM 0,070H
        JMS QSTA
        FIM 0,050H
        JMS QLDN2
        FIM 0,080H
        JMS QSTA
        FIM 0,050H
        JMS QLDN1
        FIM 0,090H
        JMS QSTA
        FIM 0,060H
        JMS QLDA
        FIM 0,050H
        JMS QSTN0
        FIM 0,070H
        JMS QLDA
        FIM 0,050H
        JMS QSTN1
        FIM 0,080H
        JMS QLDA
        FIM 0,050H
        JMS QSTN2
        FIM 0,090H
        JMS QLDA
        FIM 0,050H
        JMS QSTN3
        FIM 6,0AH
        FIM 0,040H
        JMS QSTAC
        JUN HANOI
L0006:
        FIM 0,040H
        FIM 2,0F8H
        LDM 0EH
        XCH 0DH
        JMS QRSTR
        FIM 0,040H
        JUN QRETF
        ORG 0194H
; PRINT A IN DECIMAL, SIGNED (QPRTD) OR UNSIGNED (QPRTU). QPDIG PRINTS THE
; NUMBER OF TIMES B GOES INTO A, AND LEAVES THE REST, UNLESS IT IS A
; LEADING ZERO (R2 = 0).
QPRTD:  LD 4
        RAL
        JCN 0AH,QPRTU
        FIM 14,0F0H
        SRC 14
        LDM 2
        WRR
        LDM 13
        WRR
        JMS QNEG
QPRTU:  LDM 0
        XCH 2
        FIM 8,27H
        FIM 10,10H
        JMS QPDIG
        FIM 8,03H
        FIM 10,0E8H
        JMS QPDIG
        FIM 8,00H
        FIM 10,64H
        JMS QPDIG
        FIM 8,00H
        FIM 10,0AH
        JMS QPDIG
        FIM 14,0F0H
        SRC 14
        LDM 3
        WRR
        LD 7
        WRR
        BBL 0
QPDIG:  LDM 0
        XCH 3
QPDL:   CLC
        LD 7
        SUB 11
        XCH 15
        CMC
        LD 6
        SUB 10
        XCH 14
        CMC
        LD 5
        SUB 9
        XCH 13
        CMC
        LD 4
        SUB 8
        XCH 12
        JCN 0AH,QPDO
        LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        INC 3
        JUN QPDL
QPDO:   LD 3
        JCN 0CH,QPDP
        LD 2
        JCN 4,QPDX
QPDP:   LDM 1
        XCH 2
        FIM 14,0F0H
        SRC 14
        LDM 3
        WRR
        LD 3
        WRR
QPDX:   BBL 0
        ORG 01F2H
; A = A + B.
QADD:   CLC
        LD 7
        ADD 11
        XCH 7
        LD 6
        ADD 10
        XCH 6
        LD 5
        ADD 9
        XCH 5
        LD 4
        ADD 8
        XCH 4
        BBL 0
        ORG 0200H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0002
        JUN L0004
        JUN L0006
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0214H
; THE SAVE STACK, FOR RECURSION: ITS POINTER IS IN STATUS REGISTER 0 OF
; BANK 0 (BANK, REGISTER, CHARACTER IN STATUS CHARACTERS 1 TO 3), AND EACH
; SAVED STATUS REGISTER TAKES 4 CHARACTERS OF MAIN MEMORY.
; QSAVE PUSHES 16 - R13 STATUS REGISTERS FROM R0R1 UP; QRSTR POPS THEM
; BACK, GIVEN R2R3 = -4 TIMES THEIR NUMBER. NEITHER CHANGES A.
QSAVE:  JMS QLSP
QSVL:   LD 1
        DCL
        SRC 0
        RD0
        XCH 8
        RD1
        XCH 9
        RD2
        XCH 10
        RD3
        XCH 11
        LD 12
        DCL
        SRC 14
        LD 8
        WRM
        INC 15
        SRC 14
        LD 9
        WRM
        INC 15
        SRC 14
        LD 10
        WRM
        INC 15
        SRC 14
        LD 11
        WRM
        ISZ 15,QSV1
        ISZ 14,QSV1
        INC 12
QSV1:   ISZ 0,QSV2
        INC 1
QSV2:   ISZ 13,QSVL
        JUN QSSP
QRSTR:  JMS QLSP
        CLC
        LD 15
        ADD 3
        XCH 15
        LD 14
        ADD 2
        XCH 14
        LDM 15
        ADD 12
        XCH 12
        JMS QSSP
QRSL:   LD 12
        DCL
        SRC 14
        RDM
        XCH 8
        INC 15
        SRC 14
        RDM
        XCH 9
        INC 15
        SRC 14
        RDM
        XCH 10
        INC 15
        SRC 14
        RDM
        XCH 11
        ISZ 15,QRS1
        ISZ 14,QRS1
        INC 12
QRS1:   LD 1
        DCL
        SRC 0
        LD 8
        WR0
        LD 9
        WR1
        LD 10
        WR2
        LD 11
        WR3
        ISZ 0,QRS2
        INC 1
QRS2:   ISZ 13,QRSL
        BBL 0
QLSP:   FIM 8,00H
        LDM 0
        DCL
        SRC 8
        RD1
        XCH 12
        RD2
        XCH 14
        RD3
        XCH 15
        BBL 0
QSSP:   FIM 8,00H
        LDM 0
        DCL
        SRC 8
        LD 12
        WR1
        LD 14
        WR2
        LD 15
        WR3
        BBL 0
        ORG 028BH
; PRINT THE STRING AT R0R1 ON THIS PAGE.
QS1:   FIM 14,0F0H
        SRC 14
QSL1:  FIN 2
        LD 2
        JCN 0CH,QSC1
        LD 3
        JCN 4,QSX1
QSC1:  LD 2
        WRR
        LD 3
        WRR
        ISZ 1,QSL1
        INC 0
        JUN QSL1
QSX1:  BBL 0
S0001:
        DB 033H,020H,064H,069H,073H,063H,073H,03AH,020H,0
S0002:
        DB 020H,06DH,06FH,076H,065H,073H,0AH,0
S0003:
        DB 031H,030H,020H,064H,069H,073H,063H,073H,03AH,020H,0
S0004:
        DB 064H,069H,073H,063H,020H,0
S0005:
        DB 020H,066H,072H,06FH,06DH,020H,0
S0006:
        DB 020H,074H,06FH,020H,0
        ORG 02CEH
; A != 0 OR A == 0, RETURNING 1 OR 0 IN THE ACCUMULATOR.
QTST:   LD 4
        JCN 0CH,QTT
        LD 5
        JCN 0CH,QTT
        LD 6
        JCN 0CH,QTT
        LD 7
        JCN 0CH,QTT
        BBL 0
QTT:    BBL 1
QNOTZ:  LD 4
        JCN 0CH,QZF
        LD 5
        JCN 0CH,QZF
        LD 6
        JCN 0CH,QZF
        LD 7
        JCN 0CH,QZF
        BBL 1
QZF:    BBL 0
        ORG 02EAH
; CLEAR 16 - R13 BANKS OF RAM, MAIN AND STATUS CHARACTERS, FROM BANK 0.
QCLR:   LDM 0
        XCH 12
QCLB:   LD 12
        DCL
        FIM 0,00H
QCLC:   SRC 0
        LDM 0
        WRM
        ISZ 1,QCLC
        WR0
        WR1
        WR2
        WR3
        ISZ 0,QCLC
        INC 12
        ISZ 13,QCLB
        BBL 0
        ORG 0300H
; A = -A, OR A = A + 1.
QNEG:   LD 4
        CMA
        XCH 4
        LD 5
        CMA
        XCH 5
        LD 6
        CMA
        XCH 6
        LD 7
        CMA
        XCH 7
QINC:   ISZ 7,QINCX
        ISZ 6,QINCX
        ISZ 5,QINCX
        INC 4
QINCX:  BBL 0
        ORG 0314H
; A = A - 1. DAC SETS THE CARRY WHEN NOTHING IS BORROWED.
QDEC:   LD 7
        DAC
        XCH 7
        JCN 2,QDECX
        LD 6
        DAC
        XCH 6
        JCN 2,QDECX
        LD 5
        DAC
        XCH 5
        JCN 2,QDECX
        LD 4
        DAC
        XCH 4
QDECX:  BBL 0
        ORG 0327H
; STORE A, OR ITS LOW BYTE, IN THE STATUS REGISTER AT R0R1.
QSTAC:  LDM 0
        XCH 4
        LDM 0
        XCH 5
QSTA:   LD 1
        DCL
        SRC 0
        LD 4
        WR0
        LD 5
        WR1
        LD 6
        WR2
        LD 7
        WR3
        BBL 0
        ORG 0337H
; B = STATUS CHARACTER 1 OF THE REGISTER AT R0R1, A NIBBLE.
QLBN1:  LD 1
        DCL
        SRC 0
        RD1
        XCH 11
        LDM 0
        XCH 10
        LDM 0
        XCH 9
        LDM 0
        XCH 8
        BBL 0
        ORG 0343H
; B = STATUS CHARACTER 2 OF THE REGISTER AT R0R1, A NIBBLE.
QLBN2:  LD 1
        DCL
        SRC 0
        RD2
        XCH 11
        LDM 0
        XCH 10
        LDM 0
        XCH 9
        LDM 0
        XCH 8
        BBL 0
        ORG 034FH
; A = THE STATUS REGISTER AT R0R1 (REGISTER, BANK).
QLDA:   LD 1
        DCL
        SRC 0
        RD0
        XCH 4
        RD1
        XCH 5
        RD2
        XCH 6
        RD3
        XCH 7
        BBL 0
        ORG 035BH
; A = STATUS CHARACTER 0 OF THE REGISTER AT R0R1, A NIBBLE.
QLDN0:  LD 1
        DCL
        SRC 0
        RD0
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0367H
; A = STATUS CHARACTER 1 OF THE REGISTER AT R0R1, A NIBBLE.
QLDN1:  LD 1
        DCL
        SRC 0
        RD1
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0373H
; A = STATUS CHARACTER 2 OF THE REGISTER AT R0R1, A NIBBLE.
QLDN2:  LD 1
        DCL
        SRC 0
        RD2
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 037FH
; A = STATUS CHARACTER 3 OF THE REGISTER AT R0R1, A NIBBLE.
QLDN3:  LD 1
        DCL
        SRC 0
        RD3
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 038BH
; STORE A'S LOW NIBBLE IN STATUS CHARACTER 0 AT R0R1; A = THAT NIBBLE.
QSTN0:  LD 1
        DCL
        SRC 0
        LD 7
        WR0
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0397H
; STORE A'S LOW NIBBLE IN STATUS CHARACTER 1 AT R0R1; A = THAT NIBBLE.
QSTN1:  LD 1
        DCL
        SRC 0
        LD 7
        WR1
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 03A3H
; STORE A'S LOW NIBBLE IN STATUS CHARACTER 2 AT R0R1; A = THAT NIBBLE.
QSTN2:  LD 1
        DCL
        SRC 0
        LD 7
        WR2
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 03AFH
; STORE A'S LOW NIBBLE IN STATUS CHARACTER 3 AT R0R1; A = THAT NIBBLE.
QSTN3:  LD 1
        DCL
        SRC 0
        LD 7
        WR3
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 03BBH
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 03C3H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 03CBH
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 03D1H
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        END
