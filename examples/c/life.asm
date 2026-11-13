; LIFE: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0EH
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; ?BOOL ADVANCE;
; UNSIGNED CHAR KEY;
; INITIALIZE();
        FIM 6,4
        FIM 0,0B0H
        JMS QSTAC
        JUN INITI
L0001:
; PRINTF("?033(2J?033(?25L");
        FIM 0,S0001 AND 0FFH
        JMS QS1
; DRAW();
        FIM 6,6
        FIM 0,0F0H
        JMS QSTAC
        JUN DRAW
L0002:
; WHILE (GENERATION < GENERATIONS) (
        JUN L0004
L0003:
; ADVANCE = !PAUSED;
        FIM 0,010H
        JMS QLDA
        JMS QNOTZ
        JMS QBOOL
        JMS QTST
        JMS QBOOL
        FIM 0,050H
        JMS QSTAC
; IF (??ROM?IN(14)) (
        FIM 0EH,0E0H
        SRC 0EH
        RDR
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        LD 7
        JCN 4,L0007
; KEY = GETCHAR();
        JMS QGETC
        FIM 0,060H
        JMS QSTAC
; IF (KEY == 'Q' ?? KEY == 'Q') BREAK;
        FIM 0AH,071H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0010
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0009
L0010:
        FIM 0AH,051H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0008
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0008
L0009:
        JUN L0006
L0008:
; IF (KEY == ' ') (
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0011
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0011
; PAUSED = !PAUSED;
        FIM 0,010H
        JMS QLDA
        JMS QNOTZ
        JMS QBOOL
        JMS QTST
        JMS QBOOL
        FIM 0,010H
        JMS QSTAC
; ADVANCE = !PAUSED;
        JMS QNOTZ
        JMS QBOOL
        JMS QTST
        JMS QBOOL
        FIM 0,050H
        JMS QSTAC
; STATUS();
        FIM 6,8
        FIM 0,0A0H
        JMS QSTAC
        JUN F0003
L0012:
L0011:
; IF (KEY == 'N' ?? KEY == 'N') (
        FIM 0,060H
        JMS QLDA
        FIM 0AH,06EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0015
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0014
L0015:
        FIM 0AH,04EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0013
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0013
L0014:
; PAUSED = 1;
        FIM 4,0
        FIM 6,1
        JMS QTST
        JMS QBOOL
        FIM 0,010H
        JMS QSTAC
; ADVANCE = 1;
        FIM 4,0
        FIM 6,1
        JMS QTST
        JMS QBOOL
        FIM 0,050H
        JMS QSTAC
L0013:
; IF (KEY == 'R' ?? KEY == 'R') (
        FIM 0,060H
        JMS QLDA
        FIM 0AH,072H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0018
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0017
L0018:
        FIM 0AH,052H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0016
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0016
L0017:
; INITIALIZE();
        FIM 6,0AH
        FIM 0,0B0H
        JMS QSTAC
        JUN INITI
L0019:
; DRAW();
        FIM 6,0CH
        FIM 0,0F0H
        JMS QSTAC
        JUN DRAW
L0020:
; CONTINUE;
        JUN L0005
L0016:
L0007:
; IF (ADVANCE) EVOLVE();
        FIM 0,050H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 4,L0021
        FIM 6,0EH
        FIM 0,041H
        JMS QSTAC
        JUN EVOLV
L0022:
L0021:
L0005:
L0004:
        FIM 0,020H
        JMS QLDA
        FIM 8,0
        FIM 0AH,078H
        JMS QULT
        JCN 4,$+4
        JUN L0003
L0006:
; CURSOR(HEIGHT+5, 1);
        FIM 4,0
        FIM 6,015H
        FIM 0,080H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,090H
        JMS QSTA
        FIM 6,010H
        FIM 0,070H
        JMS QSTAC
        JUN CURSO
L0023:
; PRINTF("?033(?25HDONE.?033(K?N");
        FIM 0,S0002 AND 0FFH
        JMS QS1
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
CURSO:
; CURSOR
; PRINTF("?033(%U;%UH", ROW, COL);
        FIM 0,S0003 AND 0FFH
        JMS QS1
        FIM 0,080H
        JMS QLDA
        JMS QPRTU
        FIM 4,0
        FIM 6,03BH
        JMS QPUTC
        FIM 0,090H
        JMS QLDA
        JMS QPRTU
        FIM 4,0
        FIM 6,048H
        JMS QPUTC
        FIM 0,070H
        JUN QRETF
F0003:
; STATUS
; PRINTF("?033(2;1HGENERATION %U  LIVE %U  ", GENERATION, POPULATION);
        FIM 0,S0004 AND 0FFH
        JMS QS1
        FIM 0,020H
        JMS QLDA
        JMS QPRTU
        FIM 0,S0005 AND 0FFH
        JMS QS1
        FIM 0,030H
        JMS QLDA
        JMS QPRTU
        FIM 0,S0006 AND 0FFH
        JMS QS1
; IF (PAUSED) PRINTF("PAUSED");
        FIM 0,010H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 4,L0025
        FIM 0,S0007 AND 0FFH
        JMS QS1
        JUN L0024
L0025:
; ELSE PRINTF("RUNNING");
        FIM 0,S0008 AND 0FFH
        JMS QS1
L0024:
; PRINTF("?033(K");
        FIM 0,S0009 AND 0FFH
        JMS QS1
        FIM 0,0A0H
        JUN QRETF
INITI:
; INITIALIZE
; UNSIGNED I;
; FOR (I = 0; I < CELLS; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,0C0H
        JMS QSTA
        JUN L0027
L0026:
; CURRENT(I) = 0;
        FIM 0,0C0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,0
        JMS QSBIT
; FUTURE(I) = 0;
        FIM 0,0C0H
        JMS QLDA
        FIM 8,2
        FIM 0AH,064H
        JMS QADD
        FIM 8,0
        FIM 0AH,0
        JMS QSBIT
        FIM 0,0C0H
        JMS QINCV
L0027:
        FIM 8,2
        FIM 0AH,064H
        JMS QULT
        JCN 0CH,L0026
; CURRENT(2*STRIDE+3) = 1;
        FIM 4,0
        FIM 6,047H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(3*STRIDE+4) = 1;
        FIM 4,0
        FIM 6,06AH
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(4*STRIDE+2) = 1;
        FIM 4,0
        FIM 6,08AH
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(4*STRIDE+3) = 1;
        FIM 4,0
        FIM 6,08BH
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(4*STRIDE+4) = 1;
        FIM 4,0
        FIM 6,08CH
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(3*STRIDE+12) = 1;
        FIM 4,0
        FIM 6,072H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(3*STRIDE+13) = 1;
        FIM 4,0
        FIM 6,073H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(3*STRIDE+14) = 1;
        FIM 4,0
        FIM 6,074H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(3*STRIDE+25) = 1;
        FIM 4,0
        FIM 6,07FH
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(3*STRIDE+26) = 1;
        FIM 4,0
        FIM 6,080H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(4*STRIDE+25) = 1;
        FIM 4,0
        FIM 6,0A1H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(4*STRIDE+26) = 1;
        FIM 4,0
        FIM 6,0A2H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(9*STRIDE+16) = 1;
        FIM 4,1
        FIM 6,042H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(9*STRIDE+17) = 1;
        FIM 4,1
        FIM 6,043H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(10*STRIDE+15) = 1;
        FIM 4,1
        FIM 6,063H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(10*STRIDE+16) = 1;
        FIM 4,1
        FIM 6,064H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; CURRENT(11*STRIDE+16) = 1;
        FIM 4,1
        FIM 6,086H
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
; GENERATION = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,020H
        JMS QSTA
; POPULATION = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,030H
        JMS QSTA
; FOR (I = 0; I < CELLS; I++) POPULATION += CURRENT(I);
        FIM 4,0
        FIM 6,0
        FIM 0,0C0H
        JMS QSTA
        JUN L0031
L0030:
        FIM 0,0C0H
        JMS QLDA
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,030H
        JMS QLDA
        JMS QADD
        FIM 0,030H
        JMS QSTA
        FIM 0,0C0H
        JMS QINCV
L0031:
        FIM 8,2
        FIM 0AH,064H
        JMS QULT
        JCN 0CH,L0030
        FIM 0,0B0H
        JUN QRETF
HORIZ:
; HORIZONTAL
; UNSIGNED CHAR COL;
; PUTCHAR('+');
        FIM 4,0
        FIM 6,02BH
        JMS QPUTC
; FOR (COL = 0; COL < WIDTH*2; COL++) PUTCHAR('-');
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JMS QSTAC
        JUN L0035
L0034:
        FIM 4,0
        FIM 6,02DH
        JMS QPUTC
        FIM 0,0E0H
        JMS QINCC
L0035:
        FIM 0AH,040H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0034
; PUTCHAR('+');
        FIM 4,0
        FIM 6,02BH
        JMS QPUTC
        FIM 0,0D0H
        JUN QRETF
DRAW:
; DRAW
; UNSIGNED CHAR ROW, COL;
; UNSIGNED CELL;
; PRINTF("?033(HSPACE: PAUSE  N: STEP  R: RESET  Q: QUIT");
        FIM 0,S0010 AND 0FFH
        JMS QS1
; CURSOR(3, 1);
        FIM 4,0
        FIM 6,3
        FIM 0,080H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,090H
        JMS QSTA
        FIM 6,012H
        FIM 0,070H
        JMS QSTAC
        JUN CURSO
L0038:
; HORIZONTAL();
        FIM 6,014H
        FIM 0,0D0H
        JMS QSTAC
        JUN HORIZ
L0039:
; FOR (ROW = 0; ROW < HEIGHT; ROW++) (
        FIM 4,0
        FIM 6,0
        FIM 0,1
        JMS QSTAC
        JUN L0041
L0040:
; CURSOR(ROW+4, 1);
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,4
        JMS QADD
        FIM 0,080H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,090H
        JMS QSTA
        FIM 6,016H
        FIM 0,070H
        JMS QSTAC
        JUN CURSO
L0044:
; PUTCHAR('?');
        FIM 4,0
        FIM 6,07CH
        JMS QPUTC
; CELL = (ROW+1)*STRIDE+1;
        FIM 0,1
        JMS QLDA
        JMS QINC
        FIM 0,031H
        JMS QSTA
        LD 5
        XCH 4
        LD 6
        XCH 5
        LD 7
        XCH 6
        LDM 0
        XCH 7
        FIM 0,031H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        JMS QINC
        FIM 0,021H
        JMS QSTA
; FOR (COL = 0; COL < WIDTH; COL++) (
        FIM 4,0
        FIM 6,0
        FIM 0,011H
        JMS QSTAC
        JUN L0046
L0045:
; IF (CURRENT(CELL++)) PRINTF("()");
        FIM 0,021H
        JMS QLDA
        FIM 0,031H
        JMS QSTA
        FIM 0,021H
        JMS QINCV
        FIM 0,031H
        JMS QLDA
        JMS QLBIT
        JCN 4,L0050
        FIM 0,S0011 AND 0FFH
        JMS QS1
        JUN L0049
L0050:
; ELSE PRINTF("  ");
        FIM 0,S0006 AND 0FFH
        JMS QS1
L0049:
        FIM 0,011H
        JMS QINCC
L0046:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0045
; PUTCHAR('?');
        FIM 4,0
        FIM 6,07CH
        JMS QPUTC
        FIM 0,1
        JMS QINCC
L0041:
        FIM 0AH,010H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0040
; CURSOR(HEIGHT+4, 1);
        FIM 4,0
        FIM 6,014H
        FIM 0,080H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,090H
        JMS QSTA
        FIM 6,018H
        FIM 0,070H
        JMS QSTAC
        JUN CURSO
L0051:
; HORIZONTAL();
        FIM 6,01AH
        FIM 0,0D0H
        JMS QSTAC
        JUN HORIZ
L0052:
; STATUS();
        FIM 6,01CH
        FIM 0,0A0H
        JMS QSTAC
        JUN F0003
L0053:
        FIM 0,0F0H
        JUN QRETF
EVOLV:
; EVOLVE
; UNSIGNED CELL;
; UNSIGNED CHAR ROW, COL, NEIGHBORS;
; ?BOOL ADJACENT;
; POPULATION = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,030H
        JMS QSTA
; FOR (ROW = 0; ROW < HEIGHT; ROW++) (
        FIM 4,0
        FIM 6,0
        FIM 0,061H
        JMS QSTAC
        JUN L0055
L0054:
; CELL = (ROW+1)*STRIDE+1;
        FIM 0,061H
        JMS QLDA
        JMS QINC
        FIM 0,0A1H
        JMS QSTA
        LD 5
        XCH 4
        LD 6
        XCH 5
        LD 7
        XCH 6
        LDM 0
        XCH 7
        FIM 0,0A1H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        JMS QINC
        FIM 0,051H
        JMS QSTA
; FOR (COL = 0; COL < WIDTH; COL++) (
        FIM 4,0
        FIM 6,0
        FIM 0,071H
        JMS QSTAC
        JUN L0059
L0058:
; NEIGHBORS = CURRENT(CELL-STRIDE-1)+CURRENT(CELL-STRIDE)+CURRENT(CELL-S
        FIM 0,051H
        JMS QLDA
        FIM 8,0
        FIM 0AH,022H
        JMS QSUB
        JMS QDEC
        JMS QLBIT
        JMS QBOOL
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 8,0
        FIM 0AH,022H
        JMS QSUB
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        JMS QADD
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 8,0
        FIM 0AH,022H
        JMS QSUB
        JMS QINC
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        JMS QADD
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        JMS QDEC
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        JMS QADD
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        JMS QINC
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        JMS QADD
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 8,0
        FIM 0AH,022H
        JMS QADD
        JMS QDEC
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        JMS QADD
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 8,0
        FIM 0AH,022H
        JMS QADD
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        JMS QADD
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 8,0
        FIM 0AH,022H
        JMS QADD
        JMS QINC
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        JMS QADD
        FIM 0,081H
        JMS QSTAC
; FUTURE(CELL) = NEIGHBORS == 3 ?? (CURRENT(CELL) && NEIGHBORS == 2);
        FIM 0AH,3
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0065
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0064
L0065:
        FIM 0,051H
        JMS QLDA
        JMS QLBIT
        JCN 4,L0062
        FIM 0,081H
        JMS QLDA
        FIM 0AH,2
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0062
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0062
L0064:
        LDM 1
        JUN L0063
L0062:
        LDM 0
L0063:
        JMS QBOOL
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 8,2
        FIM 0AH,064H
        JMS QADD
        FIM 0,0A1H
        JMS QLDB
        JMS QSBIT
; POPULATION += FUTURE(CELL);
        FIM 0,051H
        JMS QLDA
        FIM 8,2
        FIM 0AH,064H
        JMS QADD
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,030H
        JMS QLDA
        JMS QADD
        FIM 0,030H
        JMS QSTA
; CELL++;
        FIM 0,051H
        JMS QINCV
        FIM 0,071H
        JMS QINCC
L0059:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0058
        FIM 0,061H
        JMS QINCC
L0055:
        FIM 0AH,010H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0054
; FOR (ROW = 0; ROW < HEIGHT; ROW++) (
        FIM 4,0
        FIM 6,0
        FIM 0,061H
        JMS QSTAC
        JUN L0067
L0066:
; CELL = (ROW+1)*STRIDE+1;
        FIM 0,061H
        JMS QLDA
        JMS QINC
        FIM 0,0A1H
        JMS QSTA
        LD 5
        XCH 4
        LD 6
        XCH 5
        LD 7
        XCH 6
        LDM 0
        XCH 7
        FIM 0,0A1H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        JMS QINC
        FIM 0,051H
        JMS QSTA
; ADJACENT = 0;
        FIM 4,0
        FIM 6,0
        JMS QTST
        JMS QBOOL
        FIM 0,091H
        JMS QSTAC
; FOR (COL = 0; COL < WIDTH; COL++) (
        FIM 4,0
        FIM 6,0
        FIM 0,071H
        JMS QSTAC
        JUN L0071
L0070:
; IF (CURRENT(CELL) != FUTURE(CELL)) (
        FIM 0,051H
        JMS QLDA
        JMS QLBIT
        JMS QBOOL
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 8,2
        FIM 0AH,064H
        JMS QADD
        JMS QLBIT
        JMS QBOOL
        JMS QXAB
        FIM 0,0A1H
        JMS QLDA
        CLC
        LD 7
        SUB 0BH
        JCN 4,L0075
; IF (!ADJACENT) CURSOR(ROW+4, COL*2+2);
        FIM 0,091H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 0CH,L0076
        FIM 0,061H
        JMS QLDA
        FIM 8,0
        FIM 0AH,4
        JMS QADD
        FIM 0,080H
        JMS QSTA
        FIM 0,071H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,2
        JMS QADD
        FIM 0,090H
        JMS QSTA
        FIM 6,01EH
        FIM 0,070H
        JMS QSTAC
        JUN CURSO
L0077:
L0076:
; IF (FUTURE(CELL)) PRINTF("()");
        FIM 0,051H
        JMS QLDA
        FIM 8,2
        FIM 0AH,064H
        JMS QADD
        JMS QLBIT
        JCN 4,L0079
        FIM 0,S0011 AND 0FFH
        JMS QS1
        JUN L0078
L0079:
; ELSE PRINTF("  ");
        FIM 0,S0006 AND 0FFH
        JMS QS1
L0078:
; ADJACENT = 1;
        FIM 4,0
        FIM 6,1
        JMS QTST
        JMS QBOOL
        FIM 0,091H
        JMS QSTAC
        JUN L0074
L0075:
; ) ELSE ADJACENT = 0;
        FIM 4,0
        FIM 6,0
        JMS QTST
        JMS QBOOL
        FIM 0,091H
        JMS QSTAC
L0074:
; CURRENT(CELL) = FUTURE(CELL);
        FIM 0,051H
        JMS QLDA
        FIM 8,2
        FIM 0AH,064H
        JMS QADD
        JMS QLBIT
        JMS QBOOL
        FIM 0,0A1H
        JMS QSTA
        FIM 0,051H
        JMS QLDA
        FIM 0,0A1H
        JMS QLDB
        JMS QSBIT
; CELL++;
        FIM 0,051H
        JMS QINCV
        FIM 0,071H
        JMS QINCC
L0071:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0070
        FIM 0,061H
        JMS QINCC
L0067:
        FIM 0AH,010H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0066
; GENERATION++;
        FIM 0,020H
        JMS QINCV
; STATUS();
        FIM 6,020H
        FIM 0,0A0H
        JMS QSTAC
        JUN F0003
L0080:
        FIM 0,041H
        JUN QRETF
        ORG 0641H
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
        DB 01BH,05BH,032H,04AH,01BH,05BH,03FH,032H,035H,06CH,0
S0002:
        DB 01BH,05BH,03FH,032H,035H,068H,044H,06FH,06EH,065H,02EH,01BH
        DB 05BH,04BH,0AH,0
S0003:
        DB 01BH,05BH,0
S0004:
        DB 01BH,05BH,032H,03BH,031H,048H,047H,065H,06EH,065H,072H,061H
        DB 074H,069H,06FH,06EH,020H,0
S0005:
        DB 020H,020H,04CH,069H,076H,065H,020H,0
S0006:
        DB 020H,020H,0
S0007:
        DB 050H,041H,055H,053H,045H,044H,0
S0008:
        DB 052H,055H,04EH,04EH,049H,04EH,047H,0
S0009:
        DB 01BH,05BH,04BH,0
S0010:
        DB 01BH,05BH,048H,053H,070H,061H,063H,065H,03AH,020H,070H,061H
        DB 075H,073H,065H,020H,020H,06EH,03AH,020H,073H,074H,065H,070H
        DB 020H,020H,072H,03AH,020H,072H,065H,073H,065H,074H,020H,020H
        DB 071H,03AH,020H,071H,075H,069H,074H,0
S0011:
        DB 05BH,05DH,0
        ORG 06D2H
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
        ORG 06EEH
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
        ORG 0700H
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
        ORG 0788H
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
        ORG 07E6H
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
        ORG 07FBH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0800H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0002
        JUN L0012
        JUN L0019
        JUN L0020
        JUN L0022
        JUN L0023
        JUN L0038
        JUN L0039
        JUN L0044
        JUN L0051
        JUN L0052
        JUN L0053
        JUN L0077
        JUN L0080
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 082AH
; COMPARE A WITH B, RETURNING 1 OR 0 IN THE ACCUMULATOR. THE SIGNED
; COMPARISONS FLIP THE SIGN BITS AND COMPARE UNSIGNED.
QSLT:   JMS QFLIP
QULT:   JMS QCMP
        JCN 2,QCF
QCT:    BBL 1
QSGE:   JMS QFLIP
QUGE:   JMS QCMP
        JCN 2,QCT
QCF:    BBL 0
QSGT:   JMS QFLIP
QUGT:   JMS QCMPR
        JCN 2,QCF
        BBL 1
QSLE:   JMS QFLIP
QULE:   JMS QCMPR
        JCN 2,QCT
        BBL 0
QFLIP:  CLC
        LDM 8
        ADD 4
        XCH 4
        CLC
        LDM 8
        ADD 8
        XCH 8
        BBL 0
; THE CARRY IS 1 IF A >= B (QCMP) OR B >= A (QCMPR).
QCMP:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        CMC
        LD 5
        SUB 9
        CMC
        LD 4
        SUB 8
        BBL 0
QCMPR:  CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        CMC
        LD 9
        SUB 5
        CMC
        LD 8
        SUB 4
        BBL 0
        ORG 0869H
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
        ORG 087DH
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
        ORG 0890H
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
        ORG 08A0H
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
        ORG 08AEH
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
        ORG 08BCH
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
        ORG 08C9H
; A = A CHARACTER FROM THE CONSOLE.
QGETC:  FIM 14,0F0H
        SRC 14
        RDR
        XCH 6
        RDR
        XCH 7
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        BBL 0
        ORG 08D5H
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
        ORG 08E1H
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
        ORG 08EDH
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 08F5H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0900H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0906H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        END
