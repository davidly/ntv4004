; TRAFFIC: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0FH
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; INT CROSSINGS, FLASH;
; LAMPS(GREEN, DONT?WALK);
        FIM 4,0
        FIM 6,1
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,2
        FIM 0,0B0H
        JMS QSTA
        FIM 6,4
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0001:
; PUTS("ROAD GREEN; PRESS A KEY TO CROSS");
        FIM 0,S0001 AND 0FFH
        JMS QS1
; FOR (CROSSINGS = 0; CROSSINGS < CROSSINGS; CROSSINGS++) (
        FIM 4,0
        FIM 6,0
        FIM 0,030H
        JMS QSTA
        JUN L0003
L0002:
; WHILE (!PRESSED)
        JUN L0007
L0006:
; WAIT(1);
        FIM 4,0
        FIM 6,1
        FIM 0,060H
        JMS QSTA
        FIM 6,6
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0010:
L0007:
        FIM 0,010H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 4,L0006
; PRESSED = 0;
        FIM 4,0
        FIM 6,0
        JMS QTST
        JMS QBOOL
        FIM 0,010H
        JMS QSTAC
; WAIT(50);               /* THE ROAD KEEPS GREEN FOR 5 SECONDS */
        FIM 4,0
        FIM 6,032H
        FIM 0,060H
        JMS QSTA
        FIM 6,8
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0011:
; LAMPS(AMBER, DONT?WALK);
        FIM 4,0
        FIM 6,2
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,2
        FIM 0,0B0H
        JMS QSTA
        FIM 6,0AH
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0012:
; PUTS("ROAD AMBER");
        FIM 0,S0002 AND 0FFH
        JMS QS1
; WAIT(30);
        FIM 4,0
        FIM 6,01EH
        FIM 0,060H
        JMS QSTA
        FIM 6,0CH
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0013:
; LAMPS(RED, DONT?WALK);
        FIM 4,0
        FIM 6,4
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,2
        FIM 0,0B0H
        JMS QSTA
        FIM 6,0EH
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0014:
; WAIT(20);
        FIM 4,0
        FIM 6,014H
        FIM 0,060H
        JMS QSTA
        FIM 6,010H
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0015:
; LAMPS(RED, WALK);
        FIM 4,0
        FIM 6,4
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,0B0H
        JMS QSTA
        FIM 6,012H
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0016:
; PUTS("WALK");
        FIM 0,S0003 AND 0FFH
        JMS QS1
; WAIT(60);
        FIM 4,0
        FIM 6,03CH
        FIM 0,060H
        JMS QSTA
        FIM 6,014H
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0017:
; FOR (FLASH = 0; FLASH < 4; FLASH++) (   /* THE WALK LAMP FLASHES */
        FIM 4,0
        FIM 6,0
        FIM 0,040H
        JMS QSTA
        JUN L0019
L0018:
; LAMPS(RED, 0);
        FIM 4,0
        FIM 6,4
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,0
        FIM 0,0B0H
        JMS QSTA
        FIM 6,016H
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0022:
; WAIT(5);
        FIM 4,0
        FIM 6,5
        FIM 0,060H
        JMS QSTA
        FIM 6,018H
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0023:
; LAMPS(RED, WALK);
        FIM 4,0
        FIM 6,4
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,1
        FIM 0,0B0H
        JMS QSTA
        FIM 6,01AH
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0024:
; WAIT(5);
        FIM 4,0
        FIM 6,5
        FIM 0,060H
        JMS QSTA
        FIM 6,01CH
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0025:
        FIM 0,040H
        JMS QINCV
L0019:
        FIM 8,0
        FIM 0AH,4
        JMS QSLT
        JCN 4,$+4
        JUN L0018
; LAMPS(RED, DONT?WALK);
        FIM 4,0
        FIM 6,4
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,2
        FIM 0,0B0H
        JMS QSTA
        FIM 6,01EH
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0026:
; WAIT(20);
        FIM 4,0
        FIM 6,014H
        FIM 0,060H
        JMS QSTA
        FIM 6,020H
        FIM 0,050H
        JMS QSTAC
        JUN L0030
L0027:
; LAMPS(GREEN, DONT?WALK);
        FIM 4,0
        FIM 6,1
        FIM 0,0A0H
        JMS QSTA
        FIM 4,0
        FIM 6,2
        FIM 0,0B0H
        JMS QSTA
        FIM 6,022H
        FIM 0,090H
        JMS QSTAC
        JUN F0003
L0028:
; PUTS("ROAD GREEN");
        FIM 0,S0004 AND 0FFH
        JMS QS1
        FIM 0,030H
        JMS QINCV
L0003:
        FIM 8,0
        FIM 0AH,2
        JMS QSLT
        JCN 4,$+4
        JUN L0007
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
WAIT:
; WAIT
; INT I;
; WHILE (TENTHS--)
        JUN L0030
L0029:
; FOR (I = 0; I < PER?TENTH; I++)
        FIM 4,0
        FIM 6,0
        FIM 0,070H
        JMS QSTA
        JUN L0034
L0033:
; IF (!PRESSED && ??ROM?IN(READY)) (
        FIM 0,010H
        LD 1
        DCL
        SRC 0
        RD3
        JCN 0CH,L0037
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
        JCN 4,L0037
; GETCHAR();
        JMS QGETC
; PRESSED = 1;
        FIM 4,0
        FIM 6,1
        JMS QTST
        JMS QBOOL
        FIM 0,010H
        JMS QSTAC
L0037:
        FIM 0,070H
        JMS QINCV
L0034:
        FIM 8,0
        FIM 0AH,056H
        JMS QSLT
        JCN 0CH,L0033
L0030:
        FIM 0,060H
        JMS QLDA
        FIM 0,080H
        JMS QSTA
        FIM 0,060H
        JMS QDECV
        FIM 0,080H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0029
        FIM 0,050H
        JUN QRETF
F0003:
; LAMPS
; ??ROM?OUT(0, ROAD);
        FIM 0,0A0H
        JMS QLDA
        FIM 0EH,0
        SRC 0EH
        LD 7
        WRR
; ??ROM?OUT(1, CROSSING);
        FIM 0,0B0H
        JMS QLDA
        FIM 0EH,010H
        SRC 0EH
        LD 7
        WRR
        FIM 0,090H
        JUN QRETF
        ORG 020AH
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
        DB 072H,06FH,061H,064H,020H,067H,072H,065H,065H,06EH,03BH,020H
        DB 070H,072H,065H,073H,073H,020H,061H,020H,06BH,065H,079H,020H
        DB 074H,06FH,020H,063H,072H,06FH,073H,073H,0AH,0
S0002:
        DB 072H,06FH,061H,064H,020H,061H,06DH,062H,065H,072H,0AH,0
S0003:
        DB 077H,061H,06CH,06BH,0AH,0
S0004:
        DB 072H,06FH,061H,064H,020H,067H,072H,065H,065H,06EH,0AH,0
        ORG 025EH
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
        ORG 029DH
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
        ORG 02B9H
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
        ORG 02CEH
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
        ORG 02E2H
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
        ORG 02F5H
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 02FDH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0300H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0010
        JUN L0011
        JUN L0012
        JUN L0013
        JUN L0014
        JUN L0015
        JUN L0016
        JUN L0017
        JUN L0022
        JUN L0023
        JUN L0024
        JUN L0025
        JUN L0026
        JUN L0027
        JUN L0028
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 032CH
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
        ORG 033CH
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
        ORG 0348H
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
        ORG 0354H
; DECREMENT THE INT AT R0R1, LEAVING IT IN A.
QDECV:  JMS QLDA
        JMS QDEC
        JUN QSTA
        ORG 035AH
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        END
