; E: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0EH
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; UNSIGNED CHAR N;
; UNSIGNED X;
; UNSIGNED CHAR A( DIGITS?TO?FIND );
; UNSIGNED CHAR N;
; X = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,030H
        JMS QSTA
; N = DIGITS?TO?FIND;
        FIM 4,0
        FIM 6,0C8H
        FIM 0,020H
        JMS QSTAC
; FOR (N = N - 1; N > 0; --N) (
        JMS QDEC
        FIM 0,040H
        JMS QSTAC
        JUN L0002
L0001:
; A(N) = 1;
        FIM 0,040H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,1
        JMS QSTIC
        FIM 0,040H
        JMS QDECC
L0002:
        LD 7
        JCN 0CH,L0001
        LD 6
        JCN 0CH,L0001
; A(1) = 2, A(0) = 0;
        FIM 4,0
        FIM 6,2
        FIM 8,0
        FIM 0AH,2
        JMS QSTIC
        FIM 4,0
        FIM 6,0
        FIM 8,0
        FIM 0AH,0
        JMS QSTIC
; WHILE (N > 9) (
        JUN L0006
L0005:
; N = N--;
        FIM 0,020H
        JMS QLDA
        FIM 0,050H
        JMS QSTA
        FIM 0,020H
        JMS QDECC
        FIM 0,050H
        JMS QLDA
        FIM 0,040H
        JMS QSTAC
; WHILE (--N) (
        JUN L0010
L0009:
; A(N) = X % N;
        FIM 0,030H
        JMS QLDA
        FIM 0,040H
        JMS QLDB
        JMS QUMOD
        FIM 0,050H
        JMS QSTA
        FIM 0,040H
        JMS QLDA
        JMS QSHL1
        FIM 0,050H
        JMS QLDB
        JMS QSTIC
; X = 10 * A(N-1) + X/N;
        FIM 0,040H
        JMS QLDA
        JMS QDEC
        JMS QSHL1
        JMS QLDIC
        FIM 0,050H
        JMS QSTA
        JMS QSHL1
        JMS QSHL1
        FIM 0,050H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        FIM 0,050H
        JMS QSTA
        FIM 0,030H
        JMS QLDA
        FIM 0,040H
        JMS QLDB
        JMS QUDIV
        JMS QXAB
        FIM 0,050H
        JMS QLDA
        JMS QADD
        FIM 0,030H
        JMS QSTA
L0010:
        FIM 0,040H
        JMS QDECC
        LD 7
        JCN 0CH,L0009
        LD 6
        JCN 0CH,L0009
; PRINTF("%U", X);
        FIM 0,030H
        JMS QLDA
        JMS QPRTU
L0006:
        FIM 0,020H
        JMS QLDA
        FIM 0AH,9
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,L0005
; PRINTF( "?NDONE?N" );
        FIM 0,S0001 AND 0FFH
        JMS QS1
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
        ORG 0D4H
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
        DB 0AH,064H,06FH,06EH,065H,0AH,0
        ORG 0EFH
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
        ORG 0100H
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
        ORG 015EH
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
        ORG 01B3H
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
        ORG 01E4H
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
        ORG 01F9H
; DECREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QDECC:  JMS QLDA
        JMS QDEC
        JUN QSTAC
        ORG 0200H
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
        ORG 0214H
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
        ORG 0227H
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
        ORG 0239H
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
        ORG 0247H
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
        ORG 0255H
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
        ORG 0262H
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
        ORG 026EH
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
        ORG 027AH
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
        ORG 0285H
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        END
