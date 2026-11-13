; TTT: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 0FH
        XCH 0DH
        JMS QCLR
; THE SAVE STACK
        FIM 4,0
        FIM 6,0CH
        FIM 0,0
        JMS QSTA
; G?ITERATIONS = 1
        FIM 4,0
        FIM 6,1
        FIM 0,010H
        JMS QSTA
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
        FIM 0,0B0H
        JMS QSTN0
        FIM 6,4
        FIM 0,0A0H
        JMS QSTAC
        JUN FINDS
L0001:
        FIM 0,040H
        JMS QSTA
; MOVES += FINDSOLUTION( 1 );
        FIM 4,0
        FIM 6,1
        FIM 0,0B0H
        JMS QSTN0
        FIM 6,6
        FIM 0,0A0H
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
        FIM 0,0B0H
        JMS QSTN0
        FIM 6,8
        FIM 0,0A0H
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
MINMA:
; MINMAX
; TTYPE SCORE;
; TTYPE P, VALUE;  /* BOARD POSITIONS AND SCORES FIT IN FOUR BITS. */
; G?IMOVES++;
        FIM 0,020H
        JMS QINCV
; IF ( DEPTH >= 4 )
        LDM 4
        XCH 0CH
        FIM 0,080H
        LD 1
        DCL
        SRC 0
        RD2
        CLC
        SUB 0CH
        JCN 2,$+4
        JUN L0004
; P = WINNER2(MOVE);
        FIM 0,080H
        JMS QLDN3
        FIM 0,060H
        JMS QSTN0
; TTYPE X;
; SWITCH( MOVE )
L0016:
        LD 7
        CLC
        RAL
        XCH 1
        TCC
        XCH 0
        LDM (T0016 AND 0FH)
        ADD 1
        XCH 1
        TCC
        ADD 0
        XCH 0
        LDM ((T0016 AND 0FFH)/16)
        ADD 0
        XCH 0
        JIN 0
T0016:
        JUN L0007
        JUN L0008
        JUN L0009
        JUN L0010
        JUN L0011
        JUN L0012
        JUN L0013
        JUN L0014
        JUN L0015
        JUN L0006
        JUN L0006
        JUN L0006
        JUN L0006
        JUN L0006
        JUN L0006
        JUN L0006
; CASE 0:
L0007:
; X = G?BOARD( 0 );
        FIM 4,0
        FIM 6,0
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(1) ) && ( X == G?BOARD(2) ) ) ??
        FIM 0,1
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,$+4
        JUN L0019
        FIM 0,2
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0018
L0019:
        FIM 0,3
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0020
        FIM 0,6
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0018
L0020:
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0017
        FIM 0,8
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0017
L0018:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0017:
; BREAK;
        JUN L0006
; CASE 1:
L0008:
; X = G?BOARD( 1 );
        FIM 4,0
        FIM 6,1
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(0) ) && ( X == G?BOARD(2) ) ) ??
        FIM 0,0
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0023
        FIM 0,2
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0022
L0023:
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0021
        FIM 0,7
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0021
L0022:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0021:
; BREAK;
        JUN L0006
; CASE 2:
L0009:
; X = G?BOARD( 2 );
        FIM 4,0
        FIM 6,2
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(0) ) && ( X == G?BOARD(1) ) ) ??
        FIM 0,0
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0026
        FIM 0,1
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0025
L0026:
        FIM 0,5
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0027
        FIM 0,8
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0025
L0027:
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0024
        FIM 0,6
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0024
L0025:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0024:
; BREAK;
        JUN L0006
; CASE 3:
L0010:
; X = G?BOARD( 3 );
        FIM 4,0
        FIM 6,3
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(4) ) && ( X == G?BOARD(5) ) ) ??
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,$+4
        JUN L0030
        FIM 0,5
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,$+4
        JUN L0029
L0030:
        FIM 0,0
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0028
        FIM 0,6
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0028
L0029:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0028:
; BREAK;
        JUN L0006
; CASE 4:
L0011:
; X = G?BOARD( 4 );
        FIM 4,0
        FIM 6,4
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(0) ) && ( X == G?BOARD(8) ) ) ??
        FIM 0,0
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0033
        FIM 0,8
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0032
L0033:
        FIM 0,2
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0034
        FIM 0,6
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0032
L0034:
        FIM 0,1
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0035
        FIM 0,7
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0032
L0035:
        FIM 0,3
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0031
        FIM 0,5
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0031
L0032:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0031:
; BREAK;
        JUN L0006
; CASE 5:
L0012:
; X = G?BOARD( 5 );
        FIM 4,0
        FIM 6,5
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(3) ) && ( X == G?BOARD(4) ) ) ??
        FIM 0,3
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0038
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0037
L0038:
        FIM 0,2
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0036
        FIM 0,8
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0036
L0037:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0036:
; BREAK;
        JUN L0006
; CASE 6:
L0013:
; X = G?BOARD( 6 );
        FIM 4,0
        FIM 6,6
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(7) ) && ( X == G?BOARD(8) ) ) ??
        FIM 0,7
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,$+4
        JUN L0041
        FIM 0,8
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,$+4
        JUN L0040
L0041:
        FIM 0,0
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0042
        FIM 0,3
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0040
L0042:
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0006
        FIM 0,2
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0006
L0040:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0039:
; BREAK;
        JUN L0006
; CASE 7:
L0014:
; X = G?BOARD( 7 );
        FIM 4,0
        FIM 6,7
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(6) ) && ( X == G?BOARD(8) ) ) ??
        FIM 0,6
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0045
        FIM 0,8
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0044
L0045:
        FIM 0,1
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0006
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0006
L0044:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0043:
; BREAK;
        JUN L0006
; CASE 8:
L0015:
; X = G?BOARD( 8 );
        FIM 4,0
        FIM 6,8
        JMS QLDIN
        FIM 0,060H
        JMS QSTN1
; IF ( ( ( X == G?BOARD(6) ) && ( X == G?BOARD(7) ) ) ??
        FIM 0,6
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0048
        FIM 0,7
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0047
L0048:
        FIM 0,2
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0049
        FIM 0,5
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 4,L0047
L0049:
        FIM 0,0
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0046
        FIM 0,4
        LDM 0
        DCL
        SRC 0
        RDM
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0046
L0047:
; RETURN X;
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
        JUN L0005
L0046:
; BREAK;
L0006:
; RETURN PIECEBLANK;
        FIM 4,0
        FIM 6,0
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        LDM 0
        XCH 6
L0005:
        FIM 0,090H
        JMS QSTN1
; IF ( PIECEBLANK != P )
        LD 7
        JCN 0CH,$+4
        JUN L0050
; IF ( PIECEX == P )
        LDM 1
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0CH,L0051
; RETURN SCOREWIN;
        FIM 4,0
        FIM 6,6
        FIM 0,070H
        JUN QRETF
L0051:
; RETURN SCORELOSE;
        FIM 4,0
        FIM 6,4
        FIM 0,070H
        JUN QRETF
L0050:
; IF ( 8 == DEPTH )
        LDM 8
        XCH 0CH
        FIM 0,080H
        LD 1
        DCL
        SRC 0
        RD2
        CLC
        SUB 0CH
        JCN 0CH,L0052
; RETURN SCORETIE;
        FIM 4,0
        FIM 6,5
        FIM 0,070H
        JUN QRETF
L0052:
L0004:
; IF (DEPTH & 1)
        FIM 0,080H
        LD 1
        DCL
        SRC 0
        RD2
        RAR
        JCN 0AH,L0053
; VALUE = SCOREMIN;
        FIM 4,0
        FIM 6,2
        FIM 0,090H
        JMS QSTN2
; FOR (P = 0; P < 9; P++)
        FIM 4,0
        FIM 6,0
        FIM 0,090H
        JMS QSTN1
        JUN L0055
L0054:
; IF (PIECEBLANK == G?BOARD(P))
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD1
        XCH 1
        LDM 0
        XCH 0
        LDM 0
        DCL
        SRC 0
        RDM
        JCN 0CH,L0058
; G?BOARD(P) = PIECEX;
        FIM 0,090H
        JMS QLDN1
        FIM 8,0
        FIM 0AH,1
        JMS QSTIN
; SCORE = MINMAX(ALPHA, BETA, DEPTH + 1, P);
        FIM 0,070H
        LDM 0DH
        XCH 0DH
        JMS QSAVE
        FIM 0,080H
        JMS QLDN2
        JMS QINC
        FIM 0,080H
        JMS QSTN2
        FIM 0,090H
        JMS QLDN1
        FIM 0,080H
        JMS QSTN3
        FIM 6,0AH
        FIM 0,070H
        JMS QSTAC
        JUN MINMA
L0059:
        FIM 0,070H
        FIM 2,0F4H
        LDM 0DH
        XCH 0DH
        JMS QRSTR
        FIM 0,090H
        JMS QSTN0
; G?BOARD(P) = PIECEBLANK;
        FIM 0,090H
        JMS QLDN1
        FIM 8,0
        FIM 0AH,0
        JMS QSTIN
; IF (SCORE == SCOREWIN) RETURN SCOREWIN;
        LDM 6
        XCH 0CH
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD0
        CLC
        SUB 0CH
        JCN 0CH,L0060
        FIM 4,0
        FIM 6,6
        FIM 0,070H
        JUN QRETF
L0060:
; IF (SCORE > VALUE)
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD0
        XCH 0CH
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD2
        CLC
        SUB 0CH
        JCN 2,L0061
; VALUE = SCORE;
        FIM 0,090H
        JMS QLDN0
        FIM 0,090H
        JMS QSTN2
; IF (VALUE >= BETA) RETURN VALUE;
        FIM 0,080H
        LD 1
        DCL
        SRC 0
        RD1
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 0AH,L0062
        FIM 0,070H
        JUN QRETF
L0062:
; IF (VALUE > ALPHA) ALPHA = VALUE;
        LD 7
        XCH 0CH
        FIM 0,080H
        LD 1
        DCL
        SRC 0
        RD0
        CLC
        SUB 0CH
        JCN 2,L0063
        FIM 0,080H
        JMS QSTN0
L0063:
L0061:
L0058:
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD1
        IAC
        WR1
L0055:
        LDM 9
        XCH 0CH
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD1
        CLC
        SUB 0CH
        JCN 0AH,L0054
; RETURN VALUE;
        FIM 0,090H
        JMS QLDN2
        FIM 0,070H
        JUN QRETF
L0053:
; VALUE = SCOREMAX;
        FIM 4,0
        FIM 6,9
        FIM 0,090H
        JMS QSTN2
; FOR (P = 0; P < 9; P++)
        FIM 4,0
        FIM 6,0
        FIM 0,090H
        JMS QSTN1
        JUN L0065
L0064:
; IF (PIECEBLANK == G?BOARD(P))
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD1
        XCH 1
        LDM 0
        XCH 0
        LDM 0
        DCL
        SRC 0
        RDM
        JCN 0CH,L0068
; G?BOARD(P) = PIECEO;
        FIM 0,090H
        JMS QLDN1
        FIM 8,0
        FIM 0AH,2
        JMS QSTIN
; SCORE = MINMAX(ALPHA, BETA, DEPTH + 1, P);
        FIM 0,070H
        LDM 0DH
        XCH 0DH
        JMS QSAVE
        FIM 0,080H
        JMS QLDN2
        JMS QINC
        FIM 0,080H
        JMS QSTN2
        FIM 0,090H
        JMS QLDN1
        FIM 0,080H
        JMS QSTN3
        FIM 6,0CH
        FIM 0,070H
        JMS QSTAC
        JUN MINMA
L0069:
        FIM 0,070H
        FIM 2,0F4H
        LDM 0DH
        XCH 0DH
        JMS QRSTR
        FIM 0,090H
        JMS QSTN0
; G?BOARD(P) = PIECEBLANK;
        FIM 0,090H
        JMS QLDN1
        FIM 8,0
        FIM 0AH,0
        JMS QSTIN
; IF (SCORE == SCORELOSE) RETURN SCORELOSE;
        LDM 4
        XCH 0CH
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD0
        CLC
        SUB 0CH
        JCN 0CH,L0070
        FIM 4,0
        FIM 6,4
        FIM 0,070H
        JUN QRETF
L0070:
; IF (SCORE < VALUE)
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD2
        XCH 0CH
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD0
        CLC
        SUB 0CH
        JCN 2,L0071
; VALUE = SCORE;
        FIM 0,090H
        JMS QLDN0
        FIM 0,090H
        JMS QSTN2
; IF (VALUE <= ALPHA) RETURN VALUE;
        LD 7
        XCH 0CH
        FIM 0,080H
        LD 1
        DCL
        SRC 0
        RD0
        CLC
        SUB 0CH
        JCN 0AH,L0072
        FIM 0,070H
        JUN QRETF
L0072:
; IF (VALUE < BETA) BETA = VALUE;
        FIM 0,080H
        LD 1
        DCL
        SRC 0
        RD1
        XCH 0CH
        LD 7
        CLC
        SUB 0CH
        JCN 2,L0073
        FIM 0,080H
        JMS QSTN1
L0073:
L0071:
L0068:
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD1
        IAC
        WR1
L0065:
        LDM 9
        XCH 0CH
        FIM 0,090H
        LD 1
        DCL
        SRC 0
        RD1
        CLC
        SUB 0CH
        JCN 2,$+4
        JUN L0064
; RETURN VALUE;
        FIM 0,090H
        JMS QLDN2
        FIM 0,070H
        JUN QRETF
FINDS:
; FINDSOLUTION
; INT I;
; FOR ( I = 0; I < 9; I++ )
        FIM 4,0
        FIM 6,0
        FIM 0,0C0H
        JMS QSTA
        JUN L0075
L0074:
; G?BOARD( I ) = PIECEBLANK;
        FIM 0,0C0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,0
        JMS QSTIN
        FIM 0,0C0H
        JMS QINCV
L0075:
        FIM 8,0
        FIM 0AH,9
        JMS QSLT
        JCN 0CH,L0074
; G?BOARD( POSITION ) = PIECEX;
        FIM 0,0B0H
        JMS QLDN0
        FIM 8,0
        FIM 0AH,1
        JMS QSTIN
; FOR ( I = 0; I < G?ITERATIONS; I++ )
        FIM 4,0
        FIM 6,0
        FIM 0,0C0H
        JMS QSTA
        JUN L0079
L0078:
; G?IMOVES = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,020H
        JMS QSTA
; MINMAX( SCOREMIN, SCOREMAX, 0, POSITION );
        FIM 4,0
        FIM 6,2
        FIM 0,080H
        JMS QSTN0
        FIM 4,0
        FIM 6,9
        FIM 0,080H
        JMS QSTN1
        FIM 4,0
        FIM 6,0
        FIM 0,080H
        JMS QSTN2
        FIM 0,0B0H
        JMS QLDN0
        FIM 0,080H
        JMS QSTN3
        FIM 6,0EH
        FIM 0,070H
        JMS QSTAC
        JUN MINMA
L0082:
        FIM 0,0C0H
        JMS QINCV
L0079:
        FIM 0,010H
        JMS QLDB
        JMS QSLT
        JCN 4,$+4
        JUN L0078
; RETURN G?IMOVES;
        FIM 0,020H
        JMS QLDA
        FIM 0,0A0H
        JUN QRETF
        ORG 0633H
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
        ORG 06AAH
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
        ORG 06E9H
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
        ORG 06FEH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0700H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0002
        JUN L0003
        JUN L0059
        JUN L0069
        JUN L0082
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0718H
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
        ORG 0776H
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
        ORG 07AEH
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
        ORG 07C2H
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
        ORG 07D4H
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
        ORG 07E4H
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
        ORG 07F4H
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
        ORG 0800H
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
        ORG 080EH
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
        ORG 081BH
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
        ORG 0827H
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
        ORG 0833H
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
        ORG 083FH
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
        ORG 084BH
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
        ORG 0857H
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
        ORG 0863H
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
        ORG 086FH
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
        ORG 087BH
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
        ORG 0887H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 088FH
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        END
