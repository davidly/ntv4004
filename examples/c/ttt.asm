; TTT: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0EH
        XCH 0DH
        JMS QCLR
; THE SAVE STACK
        FIM 4,0
        FIM 6,014H
        FIM 0,0
        JMS QSTA
; G?ITERATIONS = 1
        FIM 4,0
        FIM 6,1
        FIM 0,010H
        JMS QSTA
        JUN MAIN
MAIN:
; MAIN
; INT MOVES;
; MOVES = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,040H
        JMS QSTA
; G?IMOVES = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,020H
        JMS QSTA
; MOVES = FINDSOLUTION( 0 );
        FIM 4,0
        FIM 6,0
        FIM 0,011H
        JMS QSTAC
        FIM 6,4
        FIM 0,1
        JMS QSTAC
        JUN FINDS
L0001:
        FIM 0,040H
        JMS QSTA
; MOVES += FINDSOLUTION( 1 );
        FIM 4,0
        FIM 6,1
        FIM 0,011H
        JMS QSTAC
        FIM 6,6
        FIM 0,1
        JMS QSTAC
        JUN FINDS
L0002:
        JMS QXAB
        FIM 0,040H
        JMS QLDA
        JMS QADD
        FIM 0,040H
        JMS QSTA
; MOVES += FINDSOLUTION( 4 );
        FIM 4,0
        FIM 6,4
        FIM 0,011H
        JMS QSTAC
        FIM 6,8
        FIM 0,1
        JMS QSTAC
        JUN FINDS
L0003:
        JMS QXAB
        FIM 0,040H
        JMS QLDA
        JMS QADD
        FIM 0,040H
        JMS QSTA
; PRINTF( "MOVE COUNT:      %D?N", MOVES ); /* 6493 * G?ITERATIONS */
        FIM 0,S0001 AND 0FFH
        JMS QS1
        FIM 0,040H
        JMS QLDA
        JMS QPRTD
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
; PRINTF( "ITERATION COUNT: %D?N", G?ITERATIONS );
        FIM 0,S0002 AND 0FFH
        JMS QS1
        FIM 0,010H
        JMS QLDA
        JMS QPRTD
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
        JUN QEXIT
F0002:
; LOOKFORWINNER
; INT P;
; P = G?BOARD(0); /* FASTER AS INT THAN TTYPE ON 8086 AND Z80 */
        FIM 4,0
        FIM 6,0
        JMS QLDIC
        FIM 0,060H
        JMS QSTA
; IF ( PIECEBLANK != P )
        LD 7
        JCN 0CH,L0005
        LD 6
        JCN 4,L0004
L0005:
; IF ( P == G?BOARD(1) && P == G?BOARD(2) )
        FIM 0,2
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0006
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0006
        FIM 0,4
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0006
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0006
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0006:
; IF ( P == G?BOARD(3) && P == G?BOARD(6) )
        FIM 0,6
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0007
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0007
        FIM 0,0CH
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0007
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0007
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0007:
L0004:
; P = G?BOARD(3);
        FIM 4,0
        FIM 6,6
        JMS QLDIC
        FIM 0,060H
        JMS QSTA
; IF ( PIECEBLANK != P && P == G?BOARD(4) && P == G?BOARD(5) )
        LD 7
        JCN 4,$+4
        JUN L0009
        LD 6
        JCN 0CH,$+4
        JUN L0008
L0009:
        FIM 0,8
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0008
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0008
        FIM 0,0AH
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0008
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0008
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0008:
; P = G?BOARD(6);
        FIM 4,0
        FIM 6,0CH
        JMS QLDIC
        FIM 0,060H
        JMS QSTA
; IF ( PIECEBLANK != P && P == G?BOARD(7) && P == G?BOARD(8) )
        LD 7
        JCN 0CH,L0011
        LD 6
        JCN 4,L0010
L0011:
        FIM 0,0EH
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0010
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0010
        FIM 0,010H
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0010
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0010
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0010:
; P = G?BOARD(1);
        FIM 4,0
        FIM 6,2
        JMS QLDIC
        FIM 0,060H
        JMS QSTA
; IF ( PIECEBLANK != P && P == G?BOARD(4) && P == G?BOARD(7) )
        LD 7
        JCN 0CH,L0013
        LD 6
        JCN 4,L0012
L0013:
        FIM 0,8
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0012
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0012
        FIM 0,0EH
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0012
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0012
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0012:
; P = G?BOARD(2);
        FIM 4,0
        FIM 6,4
        JMS QLDIC
        FIM 0,060H
        JMS QSTA
; IF ( PIECEBLANK != P && P == G?BOARD(5) && P == G?BOARD(8) )
        LD 7
        JCN 0CH,L0015
        LD 6
        JCN 4,L0014
L0015:
        FIM 0,0AH
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0014
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0014
        FIM 0,010H
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0014
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0014
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0014:
; P = G?BOARD(4);
        FIM 4,0
        FIM 6,8
        JMS QLDIC
        FIM 0,060H
        JMS QSTA
; IF ( PIECEBLANK != P )
        LD 7
        JCN 0CH,L0017
        LD 6
        JCN 0CH,$+4
        JUN L0016
L0017:
; IF ( ( P == G?BOARD(0) ) && ( P == G?BOARD(8) ) )
        FIM 0,0
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0018
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0018
        FIM 0,010H
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0018
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0018
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0018:
; IF ( ( P == G?BOARD(2) ) && ( P == G?BOARD(6) ) )
        FIM 0,4
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0019
        CLC
        LD 6
        SUB 0AH
        NOP
        JCN 4,$+4
        JUN L0019
        FIM 0,0CH
        LDM 0
        JMS QLDBC
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0019
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0019
; RETURN P;
        FIM 0,050H
        JUN QRETF
L0019:
L0016:
; RETURN PIECEBLANK;
        FIM 4,0
        FIM 6,0
        FIM 0,050H
        JUN QRETF
        FIM 0,050H
        JUN QRETF
MINMA:
; MINMAX
; TTYPE PIECEMOVE, SCORE;   /* BETTER PERF WITH CHAR THAN INT. OUT OF RE
; INT P, VALUE;    /* BETTER PERF WITH THESE AS AN INT ON Z80, 8080, AND
; G?IMOVES++;
        FIM 0,020H
        JMS QINCV
; IF ( DEPTH >= 4 )
        FIM 0,0A0H
        JMS QLDA
        FIM 0AH,4
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0020
; P = LOOKFORWINNER();
        FIM 6,0AH
        FIM 0,050H
        JMS QSTAC
        JUN F0002
L0021:
        FIM 0,0E0H
        JMS QSTA
; IF ( PIECEBLANK != P )
        JMS QTST
        JCN 4,L0022
; IF ( PIECEX == P )
        FIM 4,0
        FIM 6,1
        FIM 0,0E0H
        JMS QLDB
        JMS QEQ
        JCN 4,L0023
; RETURN SCOREWIN;
        FIM 4,0
        FIM 6,6
        FIM 0,070H
        JUN QRETF
L0023:
; RETURN SCORELOSE;
        FIM 4,0
        FIM 6,4
        FIM 0,070H
        JUN QRETF
L0022:
; IF ( 8 == DEPTH )
        FIM 0,0A0H
        JMS QLDA
        FIM 0AH,8
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0024
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0024
; RETURN SCORETIE;
        FIM 4,0
        FIM 6,5
        FIM 0,070H
        JUN QRETF
L0024:
L0020:
; IF ( DEPTH & 1 )
        JMS QODD
        JCN 4,L0026
; VALUE = SCOREMIN;
        FIM 4,0
        FIM 6,2
        FIM 0,0F0H
        JMS QSTA
; PIECEMOVE = PIECEX;
        FIM 4,0
        FIM 6,1
        FIM 0,0C0H
        JMS QSTAC
        JUN L0025
L0026:
; VALUE = SCOREMAX;
        FIM 4,0
        FIM 6,9
        FIM 0,0F0H
        JMS QSTA
; PIECEMOVE = PIECEO;
        FIM 4,0
        FIM 6,2
        FIM 0,0C0H
        JMS QSTAC
L0025:
; FOR ( P = 0; P < 9; P++ )
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JMS QSTA
        JUN L0028
L0027:
; IF ( PIECEBLANK == G?BOARD( P ) )
        FIM 0,0E0H
        JMS QLDA
        JMS QSHL1
        JMS QLDIC
        LD 7
        JCN 4,$+4
        JUN L0031
        LD 6
        JCN 4,$+4
        JUN L0031
; G?BOARD(P) = PIECEMOVE;
        FIM 0,0E0H
        JMS QLDA
        JMS QSHL1
        FIM 0,0C0H
        JMS QLDB
        JMS QSTIC
; SCORE = MINMAX( ALPHA, BETA, DEPTH + 1, P );
        FIM 0,070H
        LDM 0CH
        XCH 0DH
        JMS QSAVE
        FIM 0,0C0H
        LDM 0CH
        XCH 0DH
        JMS QSAVE
        FIM 0,0A0H
        JMS QLDA
        JMS QINC
        FIM 0,0A0H
        JMS QSTAC
        FIM 6,0CH
        FIM 0,070H
        JMS QSTAC
        JUN MINMA
L0032:
        FIM 0,0C0H
        FIM 2,0F0H
        LDM 0CH
        XCH 0DH
        JMS QRSTR
        FIM 0,070H
        FIM 2,0F0H
        LDM 0CH
        XCH 0DH
        JMS QRSTR
        FIM 0,0D0H
        JMS QSTAC
; G?BOARD(P) = PIECEBLANK;
        FIM 0,0E0H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,0
        JMS QSTIC
; IF ( DEPTH & 1 )
        FIM 0,0A0H
        JMS QLDA
        JMS QODD
        JCN 0CH,$+4
        JUN L0034
; IF ( SCOREWIN == SCORE )
        FIM 0,0D0H
        JMS QLDA
        FIM 0AH,6
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0035
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0035
; RETURN SCOREWIN;
        FIM 4,0
        FIM 6,6
        FIM 0,070H
        JUN QRETF
L0035:
; IF ( SCORE > VALUE )
        FIM 0,0F0H
        JMS QLDB
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0036
; VALUE = SCORE;
        FIM 0,0F0H
        JMS QSTA
; IF ( VALUE >= BETA )
        FIM 0,090H
        JMS QLDB
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0037
; RETURN VALUE;
        FIM 0,070H
        JUN QRETF
L0037:
; IF ( VALUE > ALPHA )
        FIM 0,080H
        JMS QLDB
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0038
; ALPHA = VALUE;
        FIM 0,080H
        JMS QSTAC
L0038:
L0036:
        JUN L0033
L0034:
; IF ( SCORELOSE == SCORE )
        FIM 0,0D0H
        JMS QLDA
        FIM 0AH,4
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0039
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0039
; RETURN SCORELOSE;
        FIM 4,0
        FIM 6,4
        FIM 0,070H
        JUN QRETF
L0039:
; IF ( SCORE < VALUE )
        FIM 0,0F0H
        JMS QLDB
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,L0040
; VALUE = SCORE;
        FIM 0,0F0H
        JMS QSTA
; IF ( VALUE <= ALPHA )
        FIM 0,080H
        JMS QLDB
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,L0041
; RETURN VALUE;
        FIM 0,070H
        JUN QRETF
L0041:
; IF ( VALUE < BETA )
        FIM 0,090H
        JMS QLDB
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,L0042
; BETA = VALUE;
        FIM 0,090H
        JMS QSTAC
L0042:
L0040:
L0033:
L0031:
L0029:
        FIM 0,0E0H
        JMS QINCV
L0028:
        FIM 8,0
        FIM 0AH,9
        JMS QSLT
        JCN 4,$+4
        JUN L0027
L0030:
; RETURN VALUE;
        FIM 0,0F0H
        JMS QLDA
        FIM 0,070H
        JUN QRETF
        FIM 0,070H
        JUN QRETF
FINDS:
; FINDSOLUTION
; INT I;
; FOR ( I = 0; I < 9; I++ )
        FIM 4,0
        FIM 6,0
        FIM 0,021H
        JMS QSTA
        JUN L0044
L0043:
; G?BOARD( I ) = PIECEBLANK;
        FIM 0,021H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,0
        JMS QSTIC
L0045:
        FIM 0,021H
        JMS QINCV
L0044:
        FIM 8,0
        FIM 0AH,9
        JMS QSLT
        JCN 0CH,L0043
L0046:
; G?BOARD( POSITION ) = PIECEX;
        FIM 0,011H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,1
        JMS QSTIC
; FOR ( I = 0; I < G?ITERATIONS; I++ )
        FIM 4,0
        FIM 6,0
        FIM 0,021H
        JMS QSTA
        JUN L0048
L0047:
; G?IMOVES = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,020H
        JMS QSTA
; MINMAX( SCOREMIN, SCOREMAX, 0, POSITION );
        FIM 4,0
        FIM 6,2
        FIM 0,080H
        JMS QSTAC
        FIM 4,0
        FIM 6,9
        FIM 0,090H
        JMS QSTAC
        FIM 4,0
        FIM 6,0
        FIM 0,0A0H
        JMS QSTAC
        FIM 6,0EH
        FIM 0,070H
        JMS QSTAC
        JUN MINMA
L0051:
L0049:
        FIM 0,021H
        JMS QINCV
L0048:
        FIM 0,010H
        JMS QLDB
        JMS QSLT
        JCN 4,$+4
        JUN L0047
L0050:
; RETURN G?IMOVES;
        FIM 0,020H
        JMS QLDA
        FIM 0,1
        JUN QRETF
        FIM 0,1
        JUN QRETF
        ORG 0433H
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
        ORG 04AAH
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
        ORG 04E9H
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
        ORG 04FEH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0500H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0002
        JUN L0003
        JUN L0021
        JUN L0032
        JUN L0051
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0518H
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
        ORG 0576H
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
        DB 06DH,06FH,076H,065H,020H,063H,06FH,075H,06EH,074H,03AH,020H
        DB 020H,020H,020H,020H,020H,0
S0002:
        DB 069H,074H,065H,072H,061H,074H,069H,06FH,06EH,020H,063H,06FH
        DB 075H,06EH,074H,03AH,020H,0
        ORG 05AEH
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
        ORG 05DFH
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
        ORG 0600H
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
        ORG 062CH
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
        ORG 0640H
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
        ORG 0652H
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
        ORG 0662H
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
        ORG 0670H
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
        ORG 067EH
; B = THE CHAR AT MAIN-MEMORY CHARACTER R0R1 OF BANK ACC.
QLDBC:  DCL
        SRC 0
        RDM
        XCH 10
        INC 1
        SRC 0
        RDM
        XCH 11
        LDM 0
        XCH 8
        LDM 0
        XCH 9
        BBL 0
        ORG 068BH
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
        ORG 0698H
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
        ORG 06A4H
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
        ORG 06B0H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 06B8H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 06BEH
; THE LOW BIT OF A, IN THE ACCUMULATOR.
QODD:   LD 7
        RAR
        JCN 2,QOD1
        BBL 0
QOD1:   BBL 1
        END
