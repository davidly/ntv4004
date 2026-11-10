; QUEENS: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0FH
        XCH 0DH
        JMS QCLR
; THE SAVE STACK
        FIM 4,0
        FIM 6,014H
        FIM 0,0
        JMS QSTA
MAIN:
; MAIN
; PLACE(0);
        FIM 4,0
        FIM 6,0
        FIM 0,060H
        JMS QSTN0
        FIM 6,4
        FIM 0,050H
        JMS QSTAC
        JUN PLACE
L0001:
; PRINTF("%D SOLUTIONS?N", SOLUTIONS);
        FIM 0,010H
        JMS QLDA
        JMS QPRTD
        FIM 0,S0001 AND 0FFH
        JMS QS1
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
F0002:
; SHOW
; SMALL ROW, COL;
; FOR (ROW = 0; ROW < N; ROW++) (
        FIM 4,0
        FIM 6,0
        FIM 0,040H
        JMS QSTN0
        JUN L0003
L0002:
; FOR (COL = 0; COL < N; COL++)
        FIM 4,0
        FIM 6,0
        FIM 0,040H
        JMS QSTN1
        JUN L0007
L0006:
; PUTCHAR(QUEEN(ROW) == COL ? 'Q' : '.');
        FIM 0,040H
        JMS QLDN0
        FIM 8,0
        FIM 0AH,0AH
        JMS QADD
        JMS QLDIN
        FIM 0,040H
        JMS QLBN1
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0010
        FIM 4,0
        FIM 6,051H
        JUN L0011
L0010:
        FIM 4,0
        FIM 6,02EH
L0011:
        JMS QPUTC
        FIM 0,040H
        JMS QLDN1
        JMS QINC
        FIM 0,040H
        JMS QSTN1
L0007:
        FIM 0AH,8
        CLC
        LD 7
        SUB 0BH
        JCN 0AH,L0006
; PUTCHAR('?N');
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
        FIM 0,040H
        JMS QLDN0
        JMS QINC
        FIM 0,040H
        JMS QSTN0
L0003:
        FIM 0AH,8
        CLC
        LD 7
        SUB 0BH
        JCN 0AH,L0002
        FIM 0,030H
        JUN QRETF
PLACE:
; PLACE
; SMALL COL;
; IF (ROW == N) (
        FIM 0,060H
        JMS QLDN0
        FIM 0AH,8
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0012
; IF (++SOLUTIONS == 1)
        FIM 0,010H
        JMS QINCV
        FIM 8,0
        FIM 0AH,1
        JMS QEQ
        JCN 4,L0013
; SHOW();
        FIM 6,6
        FIM 0,030H
        JMS QSTAC
        JUN F0002
L0014:
L0013:
; RETURN;
        FIM 0,050H
        JUN QRETF
L0012:
; FOR (COL = 0; COL < N; COL++)
        FIM 4,0
        FIM 6,0
        FIM 0,060H
        JMS QSTN1
        JUN L0016
L0015:
; IF (!COLUMN(COL) && !RISING(ROW + COL) && !FALLING(ROW - COL + N - 1))
        FIM 0,060H
        JMS QLDN1
        JMS QLBIT
        JCN 4,$+4
        JUN L0019
        FIM 0,060H
        JMS QLDN0
        FIM 0,060H
        JMS QLBN1
        JMS QADD
        FIM 8,0
        FIM 0AH,8
        JMS QADD
        JMS QLBIT
        JCN 4,$+4
        JUN L0019
        FIM 0,060H
        JMS QLDN0
        FIM 0,060H
        JMS QLBN1
        JMS QSUB
        FIM 8,0
        FIM 0AH,8
        JMS QADD
        JMS QDEC
        FIM 8,0
        FIM 0AH,018H
        JMS QADD
        JMS QLBIT
        JCN 4,$+4
        JUN L0019
; QUEEN(ROW) = COL;
        FIM 0,060H
        JMS QLDN0
        FIM 8,0
        FIM 0AH,0AH
        JMS QADD
        FIM 0,060H
        JMS QLBN1
        JMS QSTIN
; COLUMN(COL) = RISING(ROW + COL) = FALLING(ROW - COL + N - 1) = 1;
        FIM 0,060H
        JMS QLDN0
        FIM 0,060H
        JMS QLBN1
        JMS QSUB
        FIM 8,0
        FIM 0AH,8
        JMS QADD
        JMS QDEC
        FIM 8,0
        FIM 0AH,018H
        JMS QADD
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
        FIM 0,070H
        JMS QSTA
        FIM 0,060H
        JMS QLDN0
        FIM 0,060H
        JMS QLBN1
        JMS QADD
        FIM 8,0
        FIM 0AH,8
        JMS QADD
        FIM 0,070H
        JMS QLDB
        JMS QSBIT
        FIM 0,070H
        JMS QSTA
        FIM 0,060H
        JMS QLDN1
        FIM 0,070H
        JMS QLDB
        JMS QSBIT
; PLACE(ROW + 1);
        FIM 0,050H
        LDM 0EH
        XCH 0DH
        JMS QSAVE
        FIM 0,060H
        JMS QLDN0
        JMS QINC
        FIM 0,060H
        JMS QSTN0
        FIM 6,8
        FIM 0,050H
        JMS QSTAC
        JUN PLACE
L0020:
        FIM 0,050H
        FIM 2,0F8H
        LDM 0EH
        XCH 0DH
        JMS QRSTR
; COLUMN(COL) = RISING(ROW + COL) = FALLING(ROW - COL + N - 1) = 0;
        FIM 0,060H
        JMS QLDN0
        FIM 0,060H
        JMS QLBN1
        JMS QSUB
        FIM 8,0
        FIM 0AH,8
        JMS QADD
        JMS QDEC
        FIM 8,0
        FIM 0AH,018H
        JMS QADD
        FIM 8,0
        FIM 0AH,0
        JMS QSBIT
        FIM 0,070H
        JMS QSTA
        FIM 0,060H
        JMS QLDN0
        FIM 0,060H
        JMS QLBN1
        JMS QADD
        FIM 8,0
        FIM 0AH,8
        JMS QADD
        FIM 0,070H
        JMS QLDB
        JMS QSBIT
        FIM 0,070H
        JMS QSTA
        FIM 0,060H
        JMS QLDN1
        FIM 0,070H
        JMS QLDB
        JMS QSBIT
L0019:
        FIM 0,060H
        JMS QLDN1
        JMS QINC
        FIM 0,060H
        JMS QSTN1
L0016:
        FIM 0AH,8
        CLC
        LD 7
        SUB 0BH
        JCN 2,$+4
        JUN L0015
        FIM 0,050H
        JUN QRETF
        ORG 01CBH
; A == B OR A != B, RETURNING 1 OR 0 IN THE ACCUMULATOR.
QEQ:    CLC
        LD 4
        SUB 8
        JCN 0CH,QEF
        CLC
        LD 5
        SUB 9
        JCN 0CH,QEF
        CLC
        LD 6
        SUB 10
        JCN 0CH,QEF
        CLC
        LD 7
        SUB 11
        JCN 0CH,QEF
        BBL 1
QEF:    BBL 0
QNE:    CLC
        LD 4
        SUB 8
        JCN 0CH,QNT
        CLC
        LD 5
        SUB 9
        JCN 0CH,QNT
        CLC
        LD 6
        SUB 10
        JCN 0CH,QNT
        CLC
        LD 7
        SUB 11
        JCN 0CH,QNT
        BBL 0
QNT:    BBL 1
        ORG 01F7H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0200H
; _BOOL ARRAYS: A IS A BIT ADDRESS, 4 TIMES THE NIBBLE PLUS THE BIT. ROW B
; OF THE TABLE, AT THE START OF THE PAGE, GIVES FOR EACH NIBBLE V THE BYTE
; (V OR 2**B) * 16 + (V AND NOT 2**B).
QBITT:
        DB 010H,010H,032H,032H,054H,054H,076H,076H
        DB 098H,098H,0BAH,0BAH,0DCH,0DCH,0FEH,0FEH
        DB 020H,031H,020H,031H,064H,075H,064H,075H
        DB 0A8H,0B9H,0A8H,0B9H,0ECH,0FDH,0ECH,0FDH
        DB 040H,051H,062H,073H,040H,051H,062H,073H
        DB 0C8H,0D9H,0EAH,0FBH,0C8H,0D9H,0EAH,0FBH
        DB 080H,091H,0A2H,0B3H,0C4H,0D5H,0E6H,0F7H
        DB 080H,091H,0A2H,0B3H,0C4H,0D5H,0E6H,0F7H
; SELECT THE NIBBLE, SHIFTING A RIGHT TWICE: THE FIRST SHIFT LEAVES BIT 0 IN
; THE CARRY, AND THE SECOND GIVES THE BANK, REGISTER AND CHARACTER, AND BIT 1.
; THEN R0 = THE BIT, R1 = THE NIBBLE, R12 = IT WITH THE BIT SET, R13 CLEAR.
QBADR:  CLC
        LD 4
        RAR
        XCH 4
        LD 5
        RAR
        XCH 5
        LD 6
        RAR
        XCH 6
        LD 7
        RAR
        XCH 7
        TCC
        XCH 0
        LD 4
        RAR
        LD 5
        RAR
        DCL
        LD 6
        RAR
        XCH 2
        LD 7
        RAR
        XCH 3
        TCC
        RAL
        ADD 0
        XCH 0
        SRC 2
        RDM
        XCH 1
        FIN 12
        BBL 0
; THE BIT AT A, IN THE ACCUMULATOR.
QLBIT:  JMS QBADR
        LD 12
        CLC
        SUB 1
        JCN 4,QLB1
        BBL 0
QLB1:   BBL 1
; SET THE BIT AT A TO WHETHER B IS NONZERO; A = 0 OR 1.
QSBIT:  JMS QBADR
        LD 8
        JCN 0CH,QSB1
        LD 9
        JCN 0CH,QSB1
        LD 10
        JCN 0CH,QSB1
        LD 11
        JCN 0CH,QSB1
        LD 13
        WRM
        FIM 4,0
        FIM 6,0
        BBL 0
QSB1:   LD 12
        WRM
        FIM 4,0
        FIM 6,1
        BBL 0
        ORG 0288H
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
        ORG 0300H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0014
        JUN L0020
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0312H
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
        ORG 0370H
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
        DB 020H,073H,06FH,06CH,075H,074H,069H,06FH,06EH,073H,0AH,0
        ORG 0390H
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
        ORG 03A5H
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
        ORG 03B9H
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
        ORG 03CCH
; STORE B'S LOW NIBBLE AT MAIN-MEMORY ADDRESS A; A = THAT NIBBLE.
QSTIN:  LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        LD 11
        WRM
        LD 11
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 03DEH
; A = A - B. SUB TAKES ONE MORE WHEN THE CARRY IS 1, AND SETS IT WHEN
; NOTHING IS BORROWED, SO CMC PASSES EACH BORROW ON.
QSUB:   CLC
        LD 7
        SUB 11
        XCH 7
        CMC
        LD 6
        SUB 10
        XCH 6
        CMC
        LD 5
        SUB 9
        XCH 5
        CMC
        LD 4
        SUB 8
        XCH 4
        BBL 0
        ORG 03EFH
; A = THE __NIBBLE AT MAIN-MEMORY ADDRESS A.
QLDIN:  LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        RDM
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0400H
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
        ORG 0410H
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
        ORG 041EH
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
        ORG 042AH
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
        ORG 0436H
; B = THE STATUS REGISTER AT R0R1.
QLDB:   LD 1
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
        BBL 0
        ORG 0442H
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
        ORG 044EH
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
        ORG 045AH
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
        ORG 0466H
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
        ORG 0472H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0478H
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        END
