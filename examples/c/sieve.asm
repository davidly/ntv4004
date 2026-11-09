; SIEVE: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 8
        XCH 0DH
        JMS QCLR
        JUN MAIN
MAIN:
; MAIN
; INT I,K;
; INT PRIME,COUNT,ITER;
; FOR (ITER = 1; ITER <= 10; ITER++) (    /* DO PROGRAM 10 TIMES */
        FIM 4,0
        FIM 6,1
        FIM 0,060H
        JMS QSTA
        JUN L0002
L0001:
; COUNT = 0;                      /* INITIALIZE PRIME COUNTER */
        FIM 4,0
        FIM 6,0
        FIM 0,050H
        JMS QSTA
; FOR (I = 0; I <= SIZE; I++)     /* SET ALL FLAGS TRUE */
        FIM 4,0
        FIM 6,0
        FIM 0,020H
        JMS QSTA
        JUN L0006
L0005:
; FLAGS(I) = TRUE;
        FIM 0,020H
        JMS QLDA
        FIM 8,0
        FIM 0AH,1
        JMS QSBIT
L0007:
        FIM 0,020H
        JMS QINCV
L0006:
        FIM 8,01FH
        FIM 0AH,0FEH
        JMS QSLE
        JCN 0CH,L0005
L0008:
; FOR (I = 0; I <= SIZE; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,020H
        JMS QSTA
        JUN L0010
L0009:
; IF (FLAGS(I)) (         /* FOUND A PRIME */
        FIM 0,020H
        JMS QLDA
        JMS QLBIT
        JCN 4,L0013
; PRIME = I + I + 3;      /* TWICE INDEX + 3 */
        FIM 0,020H
        JMS QLDA
        FIM 0,020H
        JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,3
        JMS QADD
        FIM 0,040H
        JMS QSTA
; FOR (K = I + PRIME; K <= SIZE; K += PRIME)
        FIM 0,020H
        JMS QLDA
        FIM 0,040H
        JMS QLDB
        JMS QADD
        FIM 0,030H
        JMS QSTA
        JUN L0015
L0014:
; FLAGS(K) = FALSE;       /* KILL ALL MULTIPLES */
        FIM 0,030H
        JMS QLDA
        FIM 8,0
        FIM 0AH,0
        JMS QSBIT
L0016:
        FIM 0,030H
        JMS QLDA
        FIM 0,040H
        JMS QLDB
        JMS QADD
        FIM 0,030H
        JMS QSTA
L0015:
        FIM 8,01FH
        FIM 0AH,0FEH
        JMS QSLE
        JCN 0CH,L0014
L0017:
; COUNT++;                /* PRIMES FOUND */
        FIM 0,050H
        JMS QINCV
L0013:
L0011:
        FIM 0,020H
        JMS QINCV
L0010:
        FIM 8,01FH
        FIM 0AH,0FEH
        JMS QSLE
        JCN 0CH,L0009
L0012:
L0003:
        FIM 0,060H
        JMS QINCV
L0002:
        FIM 8,0
        FIM 0AH,0AH
        JMS QSLE
        JCN 0CH,L0001
L0004:
; PRINTF("%D PRIMES.?N",COUNT);           /*PRIMES FOUND IN 10TH PASS */
        FIM 0,050H
        JMS QLDA
        JMS QPRTD
        FIM 0,S0001 AND 0FFH
        JMS QS1
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
        JUN QEXIT
        ORG 0BCH
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
        ORG 0FBH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0100H
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
        ORG 0188H
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
        ORG 01E6H
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
        ORG 0200H
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
        DB 020H,070H,072H,069H,06DH,065H,073H,02EH,0AH,0
        ORG 021EH
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
        ORG 0232H
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
        ORG 0242H
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
        ORG 0250H
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
        ORG 025CH
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
        ORG 0268H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        END
