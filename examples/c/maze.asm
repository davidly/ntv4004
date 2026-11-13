; MAZE: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0EH
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; SEED = SEED;
        FIM 4,0
        FIM 6,025H
        FIM 0,010H
        JMS QSTAC
; WALK(1);
        FIM 4,0
        FIM 6,1
        JMS QTST
        JMS QBOOL
        FIM 0,070H
        JMS QSTAC
        FIM 6,4
        FIM 0,060H
        JMS QSTAC
        JUN WALK
L0001:
; PUTS("MAZE");
        FIM 0,S0001 AND 0FFH
        JMS QS1
; SHOW(0);
        FIM 4,0
        FIM 6,0
        JMS QTST
        JMS QBOOL
        FIM 0,1
        JMS QSTAC
        FIM 6,6
        FIM 0,0F0H
        JMS QSTAC
        JUN F0004
L0002:
; WALK(0);
        FIM 4,0
        FIM 6,0
        JMS QTST
        JMS QBOOL
        FIM 0,070H
        JMS QSTAC
        FIM 6,8
        FIM 0,060H
        JMS QSTAC
        JUN WALK
L0003:
; PUTS("SOLUTION");
        FIM 0,S0002 AND 0FFH
        JMS QS1
; SHOW(1);
        FIM 4,0
        FIM 6,1
        JMS QTST
        JMS QBOOL
        FIM 0,1
        JMS QSTAC
        FIM 6,0AH
        FIM 0,0F0H
        JMS QSTAC
        JUN F0004
L0004:
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
WALK:
; WALK
; UNSIGNED CHAR DEPTH, CELL, NEXT, DIRECTION, TRIES, I;
; DEPTH = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,080H
        JMS QSTAC
; STACK(0) = 0;
        FIM 4,0
        FIM 6,028H
        FIM 8,0
        FIM 0AH,0
        JMS QSTIC
; FOR (I = 0; I < CELLS; I++) VISITED(I) = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0D0H
        JMS QSTAC
        JUN L0006
L0005:
        FIM 0,0D0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,064H
        JMS QADD
        FIM 8,0
        FIM 0AH,0
        JMS QSBIT
        FIM 0,0D0H
        JMS QINCC
L0006:
        FIM 0AH,019H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0005
; VISITED(0) = 1;
        FIM 4,0
        FIM 6,064H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; WHILE (1) (
L0009:
; CELL = STACK(DEPTH);
        FIM 0,080H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,028H
        JMS QADD
        JMS QLDIC
        FIM 0,090H
        JMS QSTAC
; IF (!GENERATING && CELL == CELLS-1) BREAK;
        FIM 0,070H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 0CH,L0013
        FIM 0AH,018H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0013
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0013
        JUN L0012
L0013:
; DIRECTION = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0B0H
        JMS QSTAC
; IF (GENERATING) (
        FIM 0,070H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 0CH,$+4
        JUN L0014
; SEED = SEED*5+1;
        FIM 0,010H
        JMS QLDA
        JMS QSHL1
        JMS QSHL1
        FIM 0,010H
        JMS QLDB
        JMS QADD
        JMS QINC
        FIM 0,010H
        JMS QSTAC
; DIRECTION = SEED >> 6;
        LD 6
        XCH 7
        LD 5
        XCH 6
        LD 4
        XCH 5
        LD 5
        RAL
        TCC
        CMA
        IAC
        XCH 4
        JMS QSHR1
        JMS QSHR1
        FIM 0,0B0H
        JMS QSTAC
L0014:
; FOR (TRIES = 0; TRIES < 4; TRIES++) (
        FIM 4,0
        FIM 6,0
        FIM 0,0C0H
        JMS QSTAC
        JUN L0016
L0015:
; NEXT = NEIGHBOR(CELL, DIRECTION);
        FIM 0,090H
        JMS QLDA
        FIM 0,040H
        JMS QSTAC
        FIM 0,0B0H
        JMS QLDA
        FIM 0,050H
        JMS QSTAC
; IF (DIRECTION == 0 && CELL >= SIDE) RETURN CELL-SIDE;
        LD 7
        JCN 0CH,L0020
        LD 6
        JCN 0CH,L0020
        FIM 0,040H
        JMS QLDA
        FIM 0AH,5
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0020
        FIM 8,0
        FIM 0AH,5
        JMS QSUB
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        JUN L0019
L0020:
; IF (DIRECTION == 1 && CELL%SIDE != SIDE-1) RETURN CELL+1;
        FIM 0,050H
        JMS QLDA
        FIM 0AH,1
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0021
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0021
        FIM 0,040H
        JMS QLDA
        FIM 8,0
        FIM 0AH,5
        JMS QUMOD
        FIM 8,0
        FIM 0AH,4
        JMS QNE
        JCN 4,L0021
        FIM 0,040H
        JMS QLDA
        JMS QINC
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        JUN L0019
L0021:
; IF (DIRECTION == 2 && CELL < CELLS-SIDE) RETURN CELL+SIDE;
        FIM 0,050H
        JMS QLDA
        FIM 0AH,2
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0022
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0022
        FIM 0,040H
        JMS QLDA
        FIM 0AH,014H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,L0022
        FIM 8,0
        FIM 0AH,5
        JMS QADD
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        JUN L0019
L0022:
; IF (DIRECTION == 3 && CELL%SIDE != 0) RETURN CELL-1;
        FIM 0,050H
        JMS QLDA
        FIM 0AH,3
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0023
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0023
        FIM 0,040H
        JMS QLDA
        FIM 8,0
        FIM 0AH,5
        JMS QUMOD
        JMS QTST
        JCN 4,L0023
        FIM 0,040H
        JMS QLDA
        JMS QDEC
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        JUN L0019
L0023:
; RETURN 255;
        FIM 4,0
        FIM 6,0FFH
        LDM 0
        XCH 4
        LDM 0
        XCH 5
L0019:
        FIM 0,0A0H
        JMS QSTAC
; IF (NEXT < CELLS && !VISITED(NEXT) &&
        FIM 0AH,019H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,$+4
        JUN L0024
        FIM 8,0
        FIM 0AH,064H
        JMS QADD
        JMS QLBIT
        JCN 4,$+4
        JUN L0024
        FIM 0,070H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 4,$+4
        JUN L0025
        FIM 0,090H
        JMS QLDA
        JMS QLDIN
        FIM 0,0E0H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,0B0H
        JMS QLDB
        JMS QSHL
        JMS QXAB
        FIM 0,0E0H
        JMS QLDA
        JMS QAND
        LD 7
        JCN 4,L0024
L0025:
; IF (GENERATING) (
        FIM 0,070H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 4,L0026
; PASSAGE(CELL) ?= 1 << DIRECTION;
        FIM 0,090H
        JMS QLDA
        JMS QLDIN
        FIM 0,0E0H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,0B0H
        JMS QLDB
        JMS QSHL
        JMS QXAB
        FIM 0,0E0H
        JMS QLDA
        JMS QOR
        FIM 0,0E0H
        JMS QSTA
        FIM 0,090H
        JMS QLDA
        FIM 0,0E0H
        JMS QLDB
        JMS QSTIN
; PASSAGE(NEXT) ?= 1 << ((DIRECTION+2)&3);
        FIM 0,0A0H
        JMS QLDA
        JMS QLDIN
        FIM 0,0E0H
        JMS QSTA
        FIM 0,0B0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,2
        JMS QADD
        FIM 8,0
        FIM 0AH,3
        JMS QAND
        JMS QXAB
        FIM 4,0
        FIM 6,1
        JMS QSHL
        JMS QXAB
        FIM 0,0E0H
        JMS QLDA
        JMS QOR
        FIM 0,0E0H
        JMS QSTA
        FIM 0,0A0H
        JMS QLDA
        FIM 0,0E0H
        JMS QLDB
        JMS QSTIN
L0026:
; STACK(++DEPTH) = NEXT;
        FIM 0,080H
        JMS QINCC
        JMS QSHL1
        FIM 8,0
        FIM 0AH,028H
        JMS QADD
        FIM 0,0A0H
        JMS QLDB
        JMS QSTIC
; VISITED(NEXT) = 1;
        FIM 0,0A0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,064H
        JMS QADD
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; BREAK;
        JUN L0018
L0024:
; DIRECTION = (DIRECTION+1)&3;
        FIM 0,0B0H
        JMS QLDA
        JMS QINC
        FIM 8,0
        FIM 0AH,3
        JMS QAND
        FIM 0,0B0H
        JMS QSTAC
        FIM 0,0C0H
        JMS QINCC
L0016:
        FIM 0AH,4
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0015
L0018:
; IF (TRIES == 4) (
        FIM 0,0C0H
        JMS QLDA
        FIM 0AH,4
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0027
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0027
; IF (DEPTH == 0) BREAK;
        FIM 0,080H
        JMS QLDA
        LD 7
        JCN 0CH,L0028
        LD 6
        JCN 0CH,L0028
        JUN L0012
L0028:
; DEPTH--;
        FIM 0,080H
        JMS QDECC
L0027:
        JUN L0009
L0012:
; IF (!GENERATING)
        FIM 0,070H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 4,$+4
        JUN L0029
; FOR (I = 0; I <= DEPTH; I++) PATH(STACK(I)) = 1;
        FIM 4,0
        FIM 6,0
        FIM 0,0D0H
        JMS QSTAC
        JUN L0031
L0030:
        FIM 0,0D0H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,028H
        JMS QADD
        JMS QLDIC
        FIM 8,0
        FIM 0AH,080H
        JMS QADD
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
        FIM 0,0D0H
        JMS QINCC
L0031:
        FIM 0,080H
        JMS QLDB
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,$+4
        JUN L0030
L0029:
        FIM 0,060H
        JUN QRETF
F0004:
; SHOW
; UNSIGNED CHAR ROW, COL, CELL;
; PUTS("# #########");
        FIM 0,S0003 AND 0FFH
        JMS QS1
; FOR (ROW = 0; ROW < SIDE; ROW++) (
        FIM 4,0
        FIM 6,0
        FIM 0,011H
        JMS QSTAC
        JUN L0035
L0034:
; PUTCHAR('#');
        FIM 4,0
        FIM 6,023H
        JMS QPUTC
; FOR (COL = 0; COL < SIDE; COL++) (
        FIM 4,0
        FIM 6,0
        FIM 0,021H
        JMS QSTAC
        JUN L0039
L0038:
; CELL = ROW*SIDE+COL;
        FIM 0,011H
        JMS QLDA
        JMS QSHL1
        JMS QSHL1
        FIM 0,011H
        JMS QLDB
        JMS QADD
        FIM 0,021H
        JMS QLDB
        JMS QADD
        FIM 0,031H
        JMS QSTAC
; PUTCHAR(SOLVED && PATH(CELL) ? '.' : ' ');
        FIM 0,1
        LD 1
        DCL
        SRC 0
        RD3
        JCN 4,L0042
        FIM 8,0
        FIM 0AH,080H
        JMS QADD
        JMS QLBIT
        JCN 4,L0042
        FIM 4,0
        FIM 6,02EH
        JUN L0043
L0042:
        FIM 4,0
        FIM 6,020H
L0043:
        JMS QPUTC
; PUTCHAR(PASSAGE(CELL)&2 ? ' ' : '#');
        FIM 0,031H
        JMS QLDA
        JMS QLDIN
        FIM 8,0
        FIM 0AH,2
        JMS QAND
        LD 7
        JCN 4,L0044
        FIM 4,0
        FIM 6,020H
        JUN L0045
L0044:
        FIM 4,0
        FIM 6,023H
L0045:
        JMS QPUTC
        FIM 0,021H
        JMS QINCC
L0039:
        FIM 0AH,5
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0038
; PUTCHAR('?N');
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
; IF (ROW < SIDE-1) (
        FIM 0,011H
        JMS QLDA
        FIM 0AH,4
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,$+4
        JUN L0046
; PUTCHAR('#');
        FIM 4,0
        FIM 6,023H
        JMS QPUTC
; FOR (COL = 0; COL < SIDE; COL++) (
        FIM 4,0
        FIM 6,0
        FIM 0,021H
        JMS QSTAC
        JUN L0048
L0047:
; CELL = ROW*SIDE+COL;
        FIM 0,011H
        JMS QLDA
        JMS QSHL1
        JMS QSHL1
        FIM 0,011H
        JMS QLDB
        JMS QADD
        FIM 0,021H
        JMS QLDB
        JMS QADD
        FIM 0,031H
        JMS QSTAC
; PUTCHAR(PASSAGE(CELL)&4 ? ' ' : '#');
        JMS QLDIN
        FIM 8,0
        FIM 0AH,4
        JMS QAND
        LD 7
        JCN 4,L0051
        FIM 4,0
        FIM 6,020H
        JUN L0052
L0051:
        FIM 4,0
        FIM 6,023H
L0052:
        JMS QPUTC
; PUTCHAR('#');
        FIM 4,0
        FIM 6,023H
        JMS QPUTC
        FIM 0,021H
        JMS QINCC
L0048:
        FIM 0AH,5
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0047
; PUTCHAR('?N');
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
L0046:
        FIM 0,011H
        JMS QINCC
L0035:
        FIM 0AH,5
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0034
; PUTS("######### #");
        FIM 0,S0004 AND 0FFH
        JMS QS1
        FIM 0,0F0H
        JUN QRETF
        ORG 0433H
; A = A / B UNSIGNED, WITH THE REMAINDER IN R12-R15: 16 TIMES, SHIFT A INTO
; THE REMAINDER, AND SUBTRACT B, SETTING A QUOTIENT BIT, IF IT FITS. A'S
; LEADING ZERO NIBBLES ARE SKIPPED: THEIR QUOTIENT BITS ARE 0.
QUDIV:  FIM 12,0
        FIM 14,0
        LDM 0
        XCH 3
QDSK:   LD 4
        JCN 0CH,QDLP
        LD 5
        XCH 4
        LD 6
        XCH 5
        LD 7
        XCH 6
        LDM 0
        XCH 7
        CLC
        LDM 4
        ADD 3
        XCH 3
        JCN 0AH,QDSK
        BBL 0
QDLP:   CLC
        LD 7
        RAL
        XCH 7
        LD 6
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        LD 15
        RAL
        XCH 15
        LD 14
        RAL
        XCH 14
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        JCN 2,QDSUB
        CLC
        LD 15
        SUB 11
        CMC
        LD 14
        SUB 10
        CMC
        LD 13
        SUB 9
        CMC
        LD 12
        SUB 8
        JCN 0AH,QDNO
QDSUB:  CLC
        LD 15
        SUB 11
        XCH 15
        CMC
        LD 14
        SUB 10
        XCH 14
        CMC
        LD 13
        SUB 9
        XCH 13
        CMC
        LD 12
        SUB 8
        XCH 12
        INC 7
QDNO:   ISZ 3,QDLP
        BBL 0
        ORG 0488H
; A = A & B, A | B OR A ^ B, A BIT AT A TIME: R1 = THE SUM OF THE TWO BITS,
; WHOSE BIT 1 IS THE AND, BIT 0 THE EXCLUSIVE OR, AND SUM + 1'S BIT 1 THE OR.
QAND:   LDM 0
        JUN QLOG
QOR:    LDM 1
        JUN QLOG
QXOR:   LDM 2
QLOG:   XCH 2
        LDM 0
        XCH 3
QLGL:   CLC
        LD 7
        RAL
        XCH 7
        LD 6
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        TCC
        XCH 1
        CLC
        LD 11
        RAL
        XCH 11
        LD 10
        RAL
        XCH 10
        LD 9
        RAL
        XCH 9
        LD 8
        RAL
        XCH 8
        TCC
        ADD 1
        XCH 1
        LD 2
        JCN 4,QLGA
        RAR
        JCN 2,QLGO
        LD 1
        RAR
        JUN QLGS
QLGO:   LD 1
        IAC
        RAR
        RAR
        JUN QLGS
QLGA:   LD 1
        RAR
        RAR
QLGS:   LD 15
        RAL
        XCH 15
        LD 14
        RAL
        XCH 14
        LD 13
        RAL
        XCH 13
        LD 12
        RAL
        XCH 12
        ISZ 3,QLGL
        LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        BBL 0
        ORG 04DBH
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
        ORG 04F7H
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0500H
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
        ORG 0588H
; A = A << B, OR A >> B SIGNED OR UNSIGNED.
QSHL:   JMS QBIG
        JCN 4,QSLL
        FIM 4,0
        FIM 6,0
        BBL 0
QSLL:   LD 11
        JCN 4,QSLX
        DAC
        XCH 11
        JMS QSHL1
        JUN QSLL
QSLX:   BBL 0
QUSHR:  JMS QBIG
        JCN 4,QURL
        FIM 4,0
        FIM 6,0
        BBL 0
QURL:   LD 11
        JCN 4,QSLX
        DAC
        XCH 11
        JMS QUSR1
        JUN QURL
QSHR:   JMS QBIG
        JCN 4,QSRL
        LDM 15
        XCH 11
QSRL:   LD 11
        JCN 4,QSLX
        DAC
        XCH 11
        JMS QSHR1
        JUN QSRL
; 1 IF B > 15.
QBIG:   LD 8
        JCN 0CH,QBIG1
        LD 9
        JCN 0CH,QBIG1
        LD 10
        JCN 0CH,QBIG1
        BBL 0
QBIG1:  BBL 1
        ORG 05C7H
; STORE B, OR ITS LOW BYTE, AT MAIN-MEMORY ADDRESS A; THEN A = B.
QSTIC:  LDM 0
        XCH 8
        LDM 0
        XCH 9
        LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        LD 10
        WRM
        INC 1
        SRC 0
        LD 11
        WRM
        JUN QMOVB
QSTI:   LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        LD 8
        WRM
        INC 1
        SRC 0
        LD 9
        WRM
        INC 1
        SRC 0
        LD 10
        WRM
        INC 1
        SRC 0
        LD 11
        WRM
QMOVB:  LD 8
        XCH 4
        LD 9
        XCH 5
        LD 10
        XCH 6
        LD 11
        XCH 7
        BBL 0
        ORG 05F8H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0600H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0002
        JUN L0003
        JUN L0004
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0614H
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
        DB 04DH,041H,05AH,045H,0AH,0
S0002:
        DB 053H,04FH,04CH,055H,054H,049H,04FH,04EH,0AH,0
S0003:
        DB 023H,020H,023H,023H,023H,023H,023H,023H,023H,023H,023H,0AH
        DB 0
S0004:
        DB 023H,023H,023H,023H,023H,023H,023H,023H,023H,020H,023H,0AH
        DB 0
        ORG 0652H
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
        ORG 067EH
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
        ORG 0693H
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
        ORG 06A7H
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
        ORG 06BAH
; A = THE CHAR AT MAIN-MEMORY ADDRESS A.
QLDIC:  LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        RDM
        XCH 6
        INC 1
        SRC 0
        RDM
        XCH 7
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        BBL 0
        ORG 06CCH
; A = A >> 1, SIGNED (QSHR1) OR UNSIGNED (QUSR1).
QSHR1:  LD 4
        RAL
        JUN QSHRC
QUSR1:  CLC
QSHRC:  LD 4
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
        BBL 0
        ORG 06DEH
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
        ORG 06F0H
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
        ORG 0700H
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
        ORG 0711H
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
        ORG 0721H
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
        ORG 072FH
; A = A << 1.
QSHL1:  CLC
        LD 7
        RAL
        XCH 7
        LD 6
        RAL
        XCH 6
        LD 5
        RAL
        XCH 5
        LD 4
        RAL
        XCH 4
        BBL 0
        ORG 073DH
; EXCHANGE A AND B.
QXAB:   LD 4
        XCH 8
        XCH 4
        LD 5
        XCH 9
        XCH 5
        LD 6
        XCH 10
        XCH 6
        LD 7
        XCH 11
        XCH 7
        BBL 0
        ORG 074AH
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
        ORG 0756H
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
        ORG 0762H
; A = A % B UNSIGNED.
QUMOD:  JMS QUDIV
QREMA:  LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        BBL 0
        ORG 076DH
; DECREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QDECC:  JMS QLDA
        JMS QDEC
        JUN QSTAC
        ORG 0773H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0779H
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        END
