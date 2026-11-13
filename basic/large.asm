; LARGE: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 8
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; PUTS("BASIC4L");
        FIM 0,S0001 AND 0FFH
        JMS QS1
; INTERACTIVE = ??ROM?IN(13);
        FIM 0EH,0D0H
        SRC 0EH
        RDR
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        FIM 0,070H
        JMS QSTAC
; DO (
; ERROR = 0; DONE = 0;
        FIM 4,0
        FIM 6,0
        JMS W0001
        JMS QV073
; IF (INTERACTIVE) PUTS("READY (UPPERCASE)");
        JMS W0003
        LD 7
        JCN 4,L0004
        FIM 0,S0002 AND 0FFH
        JMS QS1
L0004:
; LOAD();
        FIM 6,4
        FIM 0,025H
        JMS QSTAC
        JUN F0017
L0005:
; LINE = 0;
        FIM 4,0
        FIM 6,0
        JMS W0004
; RUNPROGRAM();
        FIM 6,6
        FIM 0,015H
        JMS QSTAC
        JUN L0221
L0006:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0005
        LD 7
        JCN 4,L0007
        FIM 0,S0003 AND 0FFH
        JMS QS1
        JMS W0005
        JMS QPRTU
        JMS QV074
L0007:
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
; RETURN 0;
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS QV043
        FIM 0,0B1H
        JMS QV047
        JCN 0CH,L0009
        JMS QV044
        JUN L0008
L0009:
; ELSE POS++;
        JMS W0007
L0008:
        FIM 0,0A1H
        JUN QRETF
NUMBE:
; NUMBER
; UNSIGNED VALUE;
; CHAR CH;
; CH = TEXT(POS++);
        JMS QV056
        FIM 0,0E1H
        JMS QSTAC
; IF (CH >= 128) RETURN CH-128;
        FIM 0AH,080H
        JMS QGE8
        JCN 0AH,L0010
        JMS QV053
        FIM 0,0C1H
        JUN QRETF
L0010:
; IF (CH == 3) ( ERROR = 2; RETURN 0; )
        FIM 0AH,3
        JMS QEQ8
        JCN 4,L0011
        JMS QV075
        FIM 4,0
        FIM 6,0
        FIM 0,0C1H
        JUN QRETF
L0011:
; IF (CH != 1 && CH != 2) ( ERROR = 1; RETURN 0; )
        FIM 0AH,1
        JMS QEQ8
        JCN 0CH,L0012
        FIM 0AH,2
        JMS QEQ8
        JCN 0CH,L0012
        JMS QV044
        FIM 4,0
        FIM 6,0
        FIM 0,0C1H
        JUN QRETF
L0012:
; VALUE = TEXT(POS++)-128;
        JMS QV056
        JMS QV053
        FIM 0,0D1H
        JMS QSTA
; IF (CH == 2) VALUE = VALUE*128 + TEXT(POS++)-128;
        FIM 0,0E1H
        JMS QLDA
        FIM 0AH,2
        JMS QEQ8
        JCN 4,L0013
        JMS QV051
        JMS QV064
        FIM 0,0D1H
        JMS QSTA
L0013:
; RETURN VALUE*128 + TEXT(POS++)-128;
        JMS QV051
        JMS QV064
        FIM 0,0C1H
        JUN QRETF
DESTI:
; DESTINATION
; UNSIGNED INDEX;
; CHAR CH;
; CH = TEXT(POS);
        JMS QV057
        JCN 0AH,L0014
        JMS QV088
        JCN 0AH,L0014
        JMS QV076
        FIM 0,012H
        JUN QRETF
L0014:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        JMS QEQ8
        JCN 0CH,L0015
        JMS QV044
        FIM 4,0
        FIM 6,0
        FIM 0,012H
        JUN QRETF
L0015:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0007
        FIM 4,0
        FIM 6,028H
        JMS W0010
        FIM 6,8
        JMS W0011
        JUN NEED
L0016:
; CH = TEXT(POS);
        JMS QV057
        JCN 0AH,L0018
        JMS QV088
        JCN 0AH,L0018
        JMS QV076
        JMS QV045
        JMS QLDI
        FIM 0,022H
        JMS QSTA
        JUN L0017
L0018:
; ELSE INDEX = NUMBER();
        FIM 6,0AH
        JMS W0012
        JUN NUMBE
L0019:
        FIM 0,022H
        JMS QSTA
L0017:
; BLANKS(); NEED(')');
        FIM 4,0
        FIM 6,029H
        JMS W0010
        FIM 6,0CH
        JMS W0011
        JUN NEED
L0020:
; IF (ERROR) RETURN 0;
        JMS W0005
        LD 7
        JCN 4,L0021
        FIM 4,0
        FIM 6,0
        FIM 0,012H
        JUN QRETF
L0021:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,022H
        JMS QLDA
        FIM 8,0
        FIM 0AH,040H
        JMS QUGE
        JCN 4,L0022
        FIM 4,0
        FIM 6,7
        JMS W0001
        FIM 4,0
        FIM 6,0
        FIM 0,012H
        JUN QRETF
L0022:
; RETURN INDEX+26;
        FIM 0,022H
        JMS QLDA
        FIM 8,0
        FIM 0AH,01AH
        JMS QADD
        FIM 0,012H
        JUN QRETF
ATOM:
; ATOM
; UNSIGNED VALUE;
; CHAR CH;
; CH = TEXT(POS);
        JMS QV043
        FIM 0,062H
        JMS QSTAC
; IF (CH >= 'A' && CH <= 'Z') ( POS++; VALUE = VARS(CH-'A'); )
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0024
        JMS QV088
        JCN 0AH,L0024
        JMS W0007
        FIM 0,062H
        JMS QV052
        JMS QV077
        JUN L0023
L0024:
; ELSE IF (CH == '@') VALUE = VARS(DESTINATION());
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,L0026
        FIM 6,0EH
        FIM 0,012H
        JMS QSTAC
        JUN DESTI
L0027:
        JMS QV077
        JUN L0025
L0026:
; ELSE VALUE = NUMBER();
        FIM 6,010H
        JMS W0012
        JUN NUMBE
L0028:
        JMS W0013
L0025:
L0023:
; RETURN VALUE;
        FIM 0,042H
        JUN QRETF
PRODU:
; PRODUCT
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = ATOM();
        FIM 6,012H
        FIM 0,042H
        JMS QSTAC
        JUN ATOM
L0029:
        JMS W0014
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0031
L0030:
; OP = TEXT(POS++);
        JMS W0006
        FIM 0,0B2H
        JMS QSTA
        JMS W0007
        FIM 0,0B2H
        JMS QLDA
        JMS QV049
        FIM 0,0A2H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,014H
        FIM 0,042H
        JMS QSTAC
        JUN ATOM
L0034:
        FIM 0,092H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,0A2H
        JMS QLDA
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,L0036
        JMS QV078
        JMS QMUL
        JMS W0014
        JUN L0035
L0036:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,092H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0038
        FIM 4,0
        FIM 6,3
        JMS W0001
        JUN L0037
L0038:
; ELSE VALUE = VALUE / RIGHT;
        JMS QV078
        JMS QUDIV
        JMS W0014
L0037:
L0035:
L0031:
        JMS W0005
        LD 7
        JCN 0CH,L0039
        JMS QV043
        FIM 0AH,02AH
        JMS QEQ8
        JCN 0CH,L0030
        JMS QV043
        FIM 0AH,02FH
        JMS QEQ8
        JCN 0CH,L0030
L0039:
; RETURN VALUE;
        JMS W0015
        FIM 0,072H
        JUN QRETF
EXPRE:
; EXPRESSION
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = PRODUCT();
        FIM 6,016H
        FIM 0,072H
        JMS QSTAC
        JUN PRODU
L0040:
        JMS W0016
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0042
L0041:
; OP = TEXT(POS++);
        JMS W0006
        FIM 0,3
        JMS QSTA
        JMS W0007
        FIM 0,3
        JMS QLDA
        JMS QV049
        FIM 0,0F2H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,018H
        FIM 0,072H
        JMS QSTAC
        JUN PRODU
L0045:
        FIM 0,0E2H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0F2H
        JMS QLDA
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,L0047
        JMS QV079
        JMS QADD
        JMS W0016
        JUN L0046
L0047:
; ELSE VALUE = VALUE - RIGHT;
        JMS QV079
        JMS QSUB
        JMS W0016
L0046:
L0042:
        JMS W0005
        LD 7
        JCN 0CH,L0048
        JMS QV043
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,$+4
        JUN L0041
        JMS QV043
        FIM 0AH,02DH
        JMS QEQ8
        JCN 4,$+4
        JUN L0041
L0048:
; RETURN VALUE;
        JMS W0017
        FIM 0,0C2H
        JUN QRETF
FINDL:
; FINDLINE
; UNSIGNED I;
; CHAR KEY;
; IF (!TARGET ?? TARGET > 255) ( ERROR = 4; RETURN USED; )
        FIM 0,023H
        JMS QLDA
        JMS QTST
        JCN 4,L0050
        JMS QV080
        JCN 4,L0049
L0050:
        JMS QV065
        FIM 0,013H
        JUN QRETF
L0049:
; KEY = TARGET;
        FIM 0,023H
        JMS QLDA
        FIM 0,043H
        JMS QSTAC
; IF (KEY == CACHED?TARGET0) RETURN CACHED?OFFSET0;
        FIM 0,080H
        JMS QV047
        JCN 4,L0051
        FIM 0,090H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0051:
; IF (KEY == CACHED?TARGET1) RETURN CACHED?OFFSET1;
        FIM 0,0A0H
        JMS QV047
        JCN 4,L0052
        FIM 0,0B0H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0052:
; IF (KEY == CACHED?TARGET2) RETURN CACHED?OFFSET2;
        FIM 0,0C0H
        JMS QV047
        JCN 4,L0053
        FIM 0,0D0H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0053:
; IF (KEY == CACHED?TARGET3) RETURN CACHED?OFFSET3;
        FIM 0,0E0H
        JMS QV047
        JCN 4,L0054
        FIM 0,0F0H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0054:
; IF (KEY == CACHED?TARGET4) RETURN CACHED?OFFSET4;
        FIM 0,1
        JMS QV047
        JCN 4,L0055
        FIM 0,011H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0055:
; IF (KEY == CACHED?TARGET5) RETURN CACHED?OFFSET5;
        FIM 0,021H
        JMS QV047
        JCN 4,L0056
        FIM 0,031H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0056:
; IF (KEY == CACHED?TARGET6) RETURN CACHED?OFFSET6;
        FIM 0,041H
        JMS QV047
        JCN 4,L0057
        FIM 0,051H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0057:
; IF (KEY == CACHED?TARGET7) RETURN CACHED?OFFSET7;
        FIM 0,061H
        JMS QV047
        JCN 4,L0058
        FIM 0,071H
        JMS QLDA
        FIM 0,013H
        JUN QRETF
L0058:
; I = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,033H
        JMS QSTA
; WHILE (I < USED) (
        JUN L0060
L0059:
; IF (TEXT(I) == TARGET) (
        JMS W0019
        JMS QV049
        FIM 0,023H
        JMS QLDB
        JMS QEQ
        JCN 0CH,$+4
        JUN L0063
; IF (CACHE?NEXT == 0) ( CACHED?TARGET0 = KEY; CACHED?OFFSET0 = I; )
        FIM 0,081H
        JMS QLDN0
        LD 7
        JCN 4,$+4
        JUN L0065
        JMS W0020
        FIM 0,080H
        JMS QV050
        FIM 0,090H
        JMS QSTA
        JUN L0064
L0065:
; ELSE IF (CACHE?NEXT == 1) ( CACHED?TARGET1 = KEY; CACHED?OFFSET1 = I;
        FIM 0AH,1
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0067
        JMS W0020
        FIM 0,0A0H
        JMS QV050
        FIM 0,0B0H
        JMS QSTA
        JUN L0066
L0067:
; ELSE IF (CACHE?NEXT == 2) ( CACHED?TARGET2 = KEY; CACHED?OFFSET2 = I;
        FIM 0AH,2
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0069
        JMS W0020
        FIM 0,0C0H
        JMS QV050
        FIM 0,0D0H
        JMS QSTA
        JUN L0068
L0069:
; ELSE IF (CACHE?NEXT == 3) ( CACHED?TARGET3 = KEY; CACHED?OFFSET3 = I;
        FIM 0AH,3
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0071
        JMS W0020
        FIM 0,0E0H
        JMS QV050
        FIM 0,0F0H
        JMS QSTA
        JUN L0070
L0071:
; ELSE IF (CACHE?NEXT == 4) ( CACHED?TARGET4 = KEY; CACHED?OFFSET4 = I;
        FIM 0AH,4
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0073
        JMS W0020
        FIM 0,1
        JMS QV050
        FIM 0,011H
        JMS QSTA
        JUN L0072
L0073:
; ELSE IF (CACHE?NEXT == 5) ( CACHED?TARGET5 = KEY; CACHED?OFFSET5 = I;
        FIM 0AH,5
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0075
        JMS W0020
        FIM 0,021H
        JMS QV050
        FIM 0,031H
        JMS QSTA
        JUN L0074
L0075:
; ELSE IF (CACHE?NEXT == 6) ( CACHED?TARGET6 = KEY; CACHED?OFFSET6 = I;
        FIM 0AH,6
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0077
        JMS W0020
        FIM 0,041H
        JMS QV050
        FIM 0,051H
        JMS QSTA
        JUN L0076
L0077:
; ELSE IF (CACHE?NEXT == 7) ( CACHED?TARGET7 = KEY; CACHED?OFFSET7 = I;
        FIM 0AH,7
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0078
        JMS W0020
        FIM 0,061H
        JMS QV050
        FIM 0,071H
        JMS QSTA
L0078:
L0076:
L0074:
L0072:
L0070:
L0068:
L0066:
L0064:
; CACHE?NEXT = (CACHE?NEXT+1) & 7;
        FIM 0,081H
        JMS QLDN0
        JMS QINC
        FIM 8,0
        FIM 0AH,7
        JMS QAND
        FIM 0,081H
        JMS QSTN0
; RETURN I;
        JMS W0019
        FIM 0,013H
        JUN QRETF
L0063:
; I++;
        JMS W0021
; WHILE (TEXT(I)) I++;
        JUN L0080
L0079:
        JMS W0021
L0080:
        JMS QV049
        LD 7
        JCN 0CH,L0079
        LD 6
        JCN 0CH,L0079
; I++;
        JMS W0021
L0060:
        JMS W0022
        JMS QULT
        JCN 4,$+4
        JUN L0059
; ERROR = 4;
        JMS QV065
        FIM 0,013H
        JUN QRETF
PRINT:
; PRINTLINE
; UNSIGNED VALUE;
; CHAR CH;
; IF (TEXT(POS) == '"') (
        JMS QV043
        JMS QV089
        JCN 4,L0084
; POS++;
        JMS QV066
; WHILE (CH && CH != '"') (
        JUN L0086
L0085:
; PUTCHAR(CH);
        FIM 0,073H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS QV066
L0086:
        LD 7
        JCN 0CH,L0090
        LD 6
        JCN 4,L0089
L0090:
        JMS QV089
        JCN 4,L0085
L0089:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0010
        FIM 6,01AH
        JMS W0011
        JUN NEED
L0091:
        JUN L0083
L0084:
; VALUE = EXPRESSION();
        FIM 6,01CH
        JMS W0023
        JUN EXPRE
L0092:
        FIM 0,063H
        JMS QSTA
; IF (!ERROR) PRINTF("%U", VALUE);
        JMS W0005
        LD 7
        JCN 0CH,L0093
        FIM 0,063H
        JMS QLDA
        JMS QPRTU
L0093:
L0083:
; IF (TEXT(POS) == ';') POS++;
        JMS QV043
        FIM 0AH,03BH
        JMS QEQ8
        JCN 4,L0095
        JMS W0007
        JUN L0094
L0095:
; ELSE PUTCHAR(10);
        JMS QV074
L0094:
        FIM 0,053H
        JUN QRETF
BRANC:
; BRANCH
; UNSIGNED LEFT, RIGHT, TARGET;
; CHAR OP, EQUAL, YES;
; LEFT = EXPRESSION();
        FIM 6,01EH
        JMS W0023
        JUN EXPRE
L0096:
        FIM 0,093H
        JMS QSTA
; OP = TEXT(POS);
        JMS QV043
        FIM 0,0C3H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0005
        LD 7
        JCN 0CH,L0098
        JMS W0024
        LD 7
        JCN 0CH,L0097
        LD 6
        JCN 0CH,L0097
L0098:
        JMS QV044
        FIM 0,083H
        JUN QRETF
L0097:
; POS++;
        JMS W0007
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0D3H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS QV081
        JCN 0CH,L0100
        JMS QV090
        JCN 4,L0099
L0100:
        JMS QV043
        FIM 0AH,03DH
        JMS QEQ8
        JCN 4,L0099
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,0D3H
        JMS QSTAC
; POS++;
        JMS W0007
L0099:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0024
        FIM 0AH,03DH
        JMS QEQ8
        JCN 0CH,L0101
        FIM 0AH,03CH
        JMS QEQ8
        JCN 0CH,L0101
        JMS QV090
        JCN 0CH,L0101
        JMS QV044
L0101:
; RIGHT = EXPRESSION();
        FIM 6,020H
        JMS W0023
        JUN EXPRE
L0102:
        FIM 0,0A3H
        JMS QSTA
; NEED(':');
        FIM 4,0
        FIM 6,03AH
        JMS W0010
        FIM 6,022H
        JMS W0011
        JUN NEED
L0103:
; TARGET = NUMBER();
        FIM 6,024H
        JMS W0012
        JUN NUMBE
L0104:
        FIM 0,0B3H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS QV091
        JMS QEQ
        JMS QV092
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS QV081
        JCN 4,L0105
        JMS QV091
        JMS QULT
        JCN 0CH,L0108
        FIM 0,0D3H
        JMS QLDA
        LD 7
        JCN 4,L0106
        JMS W0028
        LD 7
        JCN 4,L0106
L0108:
        LDM 1
        JUN L0107
L0106:
        LDM 0
L0107:
        JMS QV092
L0105:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0024
        JMS QV090
        JCN 4,L0109
        JMS QV091
        JMS QUGT
        JCN 0CH,L0112
        FIM 0,0D3H
        JMS QLDA
        LD 7
        JCN 4,L0110
        JMS W0028
        LD 7
        JCN 4,L0110
L0112:
        LDM 1
        JUN L0111
L0110:
        LDM 0
L0111:
        JMS QV092
L0109:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0005
        LD 7
        JCN 0CH,L0113
        JMS W0028
        LD 7
        JCN 4,L0113
        FIM 0,0B3H
        JMS QV082
        FIM 6,026H
        FIM 0,013H
        JMS QSTAC
        JUN FINDL
L0114:
        JMS W0004
L0113:
        FIM 0,083H
        JUN QRETF
F0011:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; CH = TEXT(POS);
        JMS QV043
        FIM 0,4
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0115
        LD 6
        JCN 0CH,L0115
        JMS QV044
        FIM 0,0F3H
        JUN QRETF
L0115:
; POS++;
        JMS W0007
; IF (CH == 'P') PRINTLINE();
        FIM 0,4
        JMS QLDA
        FIM 0AH,050H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0117
        FIM 6,028H
        FIM 0,053H
        JMS QSTAC
        JUN PRINT
L0118:
        JUN L0116
L0117:
; ELSE IF (CH == 'F') BRANCH();
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0120
        FIM 6,02AH
        FIM 0,083H
        JMS QSTAC
        JUN BRANC
L0121:
        JUN L0119
L0120:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0123
; VALUE = NUMBER();
        FIM 6,02CH
        JMS W0012
        JUN NUMBE
L0124:
        JMS QV083
        LD 7
        JCN 0CH,L0122
        FIM 0,024H
        JMS QV082
        FIM 6,02EH
        FIM 0,013H
        JMS QSTAC
        JUN FINDL
L0126:
        JMS W0004
L0125:
        JUN L0122
L0123:
; ) ELSE IF (CH == 'L') (
        FIM 0AH,04CH
        JMS QEQ8
        JCN 4,L0128
; VARIABLE = DESTINATION();
        FIM 6,030H
        FIM 0,012H
        JMS QSTAC
        JUN DESTI
L0129:
        FIM 0,014H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 4,0
        FIM 6,03DH
        JMS W0010
        FIM 6,032H
        JMS W0011
        JUN NEED
L0130:
; VALUE = EXPRESSION();
        FIM 6,034H
        JMS W0023
        JUN EXPRE
L0131:
        JMS QV083
        LD 7
        JCN 0CH,L0127
        FIM 0,014H
        JMS QLDA
        JMS QV045
        FIM 0,024H
        JMS QLDB
        JMS QSTI
L0132:
        JUN L0127
L0128:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0134
; DONE = 1;
        FIM 4,0
        FIM 6,1
        JMS W0002
        JUN L0133
L0134:
; ) ELSE IF (CH == 'R') (
        JMS QV068
        JCN 4,L0136
; WHILE (TEXT(POS)) POS++;
        JUN L0138
L0137:
        JMS W0007
L0138:
        JMS QV043
        LD 7
        JCN 0CH,L0137
        LD 6
        JCN 0CH,L0137
        JUN L0135
L0136:
; ) ELSE ERROR = 1;
        JMS QV044
L0135:
L0133:
L0127:
L0122:
L0119:
L0116:
; IF (TEXT(POS)) ERROR = 1;
        JMS QV043
        LD 7
        JCN 0CH,L0142
        LD 6
        JCN 4,L0141
L0142:
        JMS QV044
L0141:
        FIM 0,0F3H
        JUN QRETF
RNEED:
; RNEED
; IF (GETCHAR() != CH) ERROR = 1;
        JMS QGETC
        FIM 0,044H
        JMS QV047
        JCN 0CH,L0143
        JMS QV044
L0143:
        FIM 0,034H
        JUN QRETF
F0013:
; SAVE
; IF (USED >= SPACE) ERROR = 6;
        JMS W0018
        FIM 8,3
        FIM 0AH,040H
        JMS QUGE
        JCN 4,L0145
        FIM 4,0
        FIM 6,6
        JMS W0001
        JUN L0144
L0145:
; ELSE TEXT(USED++) = CH;
        JMS W0018
        FIM 0,074H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,074H
        JMS QLDA
        JMS QSHL1
        FIM 0,064H
        JMS QLDB
        JMS QSTIC
L0144:
        FIM 0,054H
        JUN QRETF
PACKN:
; PACKNUMBER
; UNSIGNED VALUE;
; CHAR OVERFLOW;
; VALUE = 0; OVERFLOW = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0A4H
        JMS QSTA
        FIM 4,0
        FIM 6,0
        FIM 0,0B4H
        JMS QSTAC
; DO (
L0146:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) OVERFLOW = 1;
        JMS W0029
        JMS QV084
        JCN 4,$+4
        JUN L0150
        JMS W0029
        JMS QV085
        JCN 0CH,$+4
        JUN L0149
        FIM 0,094H
        JMS QLDA
        FIM 0AH,035H
        JMS QLE8
        JCN 0AH,$+4
        JUN L0149
L0150:
        FIM 4,0
        FIM 6,1
        FIM 0,0B4H
        JMS QSTAC
L0149:
; VALUE = VALUE*10 + CH-'0';
        JMS W0029
        JMS QSHL1
        JMS QSHL1
        FIM 0,0A4H
        JMS QV086
        FIM 0,094H
        JMS QV058
        FIM 0,0A4H
        JMS QSTA
; CH = GETCHAR();
        JMS QGETC
        JMS W0030
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0152
L0151:
        JMS QGETC
        JMS W0030
L0152:
        JMS QV062
        JCN 0CH,L0151
        JMS QV063
        JCN 0CH,L0151
        JMS QV069
        JCN 0AH,L0155
        JMS QV070
        JCN 0AH,$+4
        JUN L0146
L0155:
; IF (OVERFLOW) SAVE(3);
        FIM 0,0B4H
        JMS QLDA
        LD 7
        JCN 4,L0157
        FIM 4,0
        FIM 6,3
        JMS W0031
        FIM 6,036H
        JMS W0032
        JUN F0013
L0158:
        JUN L0156
L0157:
; ELSE IF (VALUE < 128) SAVE(VALUE+128);
        JMS W0029
        FIM 8,0
        FIM 0AH,080H
        JMS QULT
        JCN 4,L0160
        JMS W0029
        FIM 8,0
        FIM 0AH,080H
        JMS QADD
        JMS W0031
        FIM 6,038H
        JMS W0032
        JUN F0013
L0161:
        JUN L0159
L0160:
; IF (VALUE < 16384) SAVE(1);
        JMS W0029
        FIM 8,040H
        FIM 0AH,0
        JMS QULT
        JCN 4,L0163
        FIM 4,0
        FIM 6,1
        JMS W0031
        FIM 6,03AH
        JMS W0032
        JUN F0013
L0164:
        JUN L0162
L0163:
; ELSE ( SAVE(2); SAVE(128+(VALUE >> 14)); )
        FIM 4,0
        FIM 6,2
        JMS W0031
        FIM 6,03CH
        JMS W0032
        JUN F0013
L0165:
        JMS W0029
        LD 6
        XCH 7
        LD 5
        XCH 6
        LD 4
        XCH 5
        LDM 0
        XCH 4
        LD 6
        XCH 7
        LD 5
        XCH 6
        LD 4
        XCH 5
        LDM 0
        XCH 4
        JMS QV055
        JMS QV048
        FIM 6,03EH
        JMS W0032
        JUN F0013
L0166:
L0162:
; SAVE(128+((VALUE >> 7) & 127));
        JMS W0029
        JMS QV055
        JMS QUSR1
        JMS QV067
        FIM 6,040H
        JMS W0032
        JUN F0013
L0167:
; SAVE(128+(VALUE & 127));
        JMS W0029
        JMS QV067
        FIM 6,042H
        JMS W0032
        JUN F0013
L0168:
L0159:
L0156:
; RETURN CH;
        FIM 0,094H
        JMS QLDA
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        FIM 0,084H
        JUN QRETF
PACKE:
; PACKEDLINE
; CHAR CH, NEXT, QUOTED;
; IF (COMMAND == 'L') ( RNEED('E'); RNEED('T'); )
        JMS W0033
        FIM 0AH,04CH
        JMS QEQ8
        JCN 4,L0170
        JMS QV059
        FIM 6,044H
        JMS W0035
        JUN RNEED
L0171:
        JMS QV060
        FIM 6,046H
        JMS W0035
        JUN RNEED
L0172:
        JUN L0169
L0170:
; ELSE IF (COMMAND == 'P') ( RNEED('R'); RNEED('I'); RNEED('N'); RNEED('
        FIM 0AH,050H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0174
        FIM 4,0
        FIM 6,052H
        JMS W0034
        FIM 6,048H
        JMS W0035
        JUN RNEED
L0175:
        FIM 4,0
        FIM 6,049H
        JMS W0034
        FIM 6,04AH
        JMS W0035
        JUN RNEED
L0176:
        JMS QV061
        FIM 6,04CH
        JMS W0035
        JUN RNEED
L0177:
        JMS QV060
        FIM 6,04EH
        JMS W0035
        JUN RNEED
L0178:
        JUN L0173
L0174:
; ELSE IF (COMMAND == 'I') ( RNEED('F'); COMMAND = 'F'; )
        FIM 0AH,049H
        JMS QEQ8
        JCN 4,L0180
        FIM 4,0
        FIM 6,046H
        JMS W0034
        FIM 6,050H
        JMS W0035
        JUN RNEED
L0181:
        FIM 4,0
        FIM 6,046H
        FIM 0,0D4H
        JMS QSTAC
        JUN L0179
L0180:
; ELSE IF (COMMAND == 'G') ( RNEED('O'); RNEED('T'); RNEED('O'); )
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0183
        JMS QV087
        FIM 6,052H
        JMS W0035
        JUN RNEED
L0184:
        JMS QV060
        FIM 6,054H
        JMS W0035
        JUN RNEED
L0185:
        JMS QV087
        FIM 6,056H
        JMS W0035
        JUN RNEED
L0186:
        JUN L0182
L0183:
; ELSE IF (COMMAND == 'E') ( RNEED('N'); RNEED('D'); )
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0188
        JMS QV061
        FIM 6,058H
        JMS W0035
        JUN RNEED
L0189:
        FIM 4,0
        FIM 6,044H
        JMS W0034
        FIM 6,05AH
        JMS W0035
        JUN RNEED
L0190:
        JUN L0187
L0188:
; ELSE IF (COMMAND == 'R') ( RNEED('E'); RNEED('M'); )
        JMS QV068
        JCN 4,L0192
        JMS QV059
        FIM 6,05CH
        JMS W0035
        JUN RNEED
L0193:
        FIM 4,0
        FIM 6,04DH
        JMS W0034
        FIM 6,05EH
        JMS W0035
        JUN RNEED
L0194:
        JUN L0191
L0192:
; ELSE ERROR = 1;
        JMS QV044
L0191:
L0187:
L0182:
L0179:
L0173:
L0169:
; SAVE(COMMAND);
        JMS W0033
        JMS W0031
        FIM 6,060H
        JMS W0032
        JUN F0013
L0195:
; QUOTED = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,5
        JMS QSTAC
; CH = GETCHAR();
        JMS QV093
; WHILE (!ERROR && CH != 13 && CH != 10) (
        JUN L0197
L0196:
; IF (!QUOTED && COMMAND != 'R' && CH >= '0' && CH <= '9') (
        JMS W0037
        LD 7
        JCN 0CH,L0201
        LD 6
        JCN 0CH,L0201
        JMS W0033
        JMS QV068
        JCN 0CH,L0201
        JMS W0038
        JMS QV069
        JCN 0AH,L0201
        JMS QV070
        JCN 0AH,L0201
; CH = PACKNUMBER(CH);
        JMS W0030
        FIM 6,062H
        FIM 0,084H
        JMS QSTAC
        JUN PACKN
L0202:
        JMS W0036
        JUN L0200
L0201:
; ) ELSE IF (!QUOTED && COMMAND == 'F' && CH == 'T') (
        JMS W0037
        LD 7
        JCN 4,$+4
        JUN L0204
        LD 6
        JCN 4,$+4
        JUN L0204
        JMS W0033
        FIM 0AH,046H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0204
        JMS W0038
        FIM 0AH,054H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0204
; NEXT = GETCHAR();
        JMS QGETC
        FIM 0,0F4H
        JMS QSTAC
; IF (NEXT == 'H') (
        FIM 0AH,048H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0206
; RNEED('E'); RNEED('N'); SAVE(':');
        JMS QV059
        FIM 6,064H
        JMS W0035
        JUN RNEED
L0207:
        JMS QV061
        FIM 6,066H
        JMS W0035
        JUN RNEED
L0208:
        FIM 4,0
        FIM 6,03AH
        JMS W0031
        FIM 6,068H
        JMS W0032
        JUN F0013
L0209:
; CH = GETCHAR();
        JMS QV093
        JUN L0203
L0206:
; SAVE('T'); CH = NEXT;
        FIM 4,0
        FIM 6,054H
        JMS W0031
        FIM 6,06AH
        JMS W0032
        JUN F0013
L0210:
        FIM 0,0F4H
        JMS QLDA
        JMS W0036
        JUN L0203
L0204:
; IF (!CH ?? (!QUOTED && CH == ':')) ERROR = 1;
        JMS W0038
        LD 7
        JCN 0CH,L0213
        LD 6
        JCN 4,L0212
L0213:
        JMS W0037
        LD 7
        JCN 0CH,L0211
        LD 6
        JCN 0CH,L0211
        JMS W0038
        FIM 0AH,03AH
        JMS QEQ8
        JCN 4,L0211
L0212:
        JMS QV044
L0211:
; IF (CH == '"') QUOTED = 1-QUOTED;
        JMS W0038
        JMS QV089
        JCN 4,L0214
        FIM 4,0
        FIM 6,1
        FIM 0,5
        JMS QLDB
        JMS QSUB
        FIM 0,5
        JMS QSTAC
L0214:
; IF (QUOTED ?? CH > ' ') SAVE(CH);
        JMS W0037
        LD 7
        JCN 0CH,L0216
        LD 6
        JCN 0CH,L0216
        JMS W0038
        FIM 0AH,020H
        JMS QLE8
        JCN 2,L0215
L0216:
        JMS W0038
        JMS W0031
        FIM 6,06CH
        JMS W0032
        JUN F0013
L0217:
L0215:
; CH = GETCHAR();
        JMS QV093
L0203:
L0200:
L0197:
        JMS W0005
        LD 7
        JCN 0CH,L0218
        JMS W0038
        JMS QV071
        JCN 0CH,L0218
        JMS QV072
        JCN 0CH,$+4
        JUN L0196
L0218:
; SAVE(0);
        FIM 4,0
        FIM 6,0
        JMS W0031
        FIM 6,06EH
        JMS W0032
        JUN F0013
L0219:
        FIM 0,0C4H
        JUN QRETF
RUNPR:
; RUNPROGRAM
; WHILE (!ERROR && !DONE && LINE < USED) (
        JUN L0221
L0220:
; POS = LINE+1;
        JMS W0039
        JMS QINC
        FIM 0,020H
        JMS QSTA
; LINE = USED;
        JMS W0018
        JMS W0004
; STATEMENT();
        FIM 6,070H
        FIM 0,0F3H
        JMS QSTAC
        JUN F0011
L0224:
; IF (LINE == USED) LINE = POS+1;
        JMS W0039
        JMS W0022
        JMS QEQ
        JCN 4,L0225
        JMS W0006
        JMS QINC
        JMS W0004
L0225:
L0221:
        JMS W0005
        LD 7
        JCN 0CH,L0226
        FIM 0,060H
        JMS QLDA
        LD 7
        JCN 0CH,L0226
        JMS W0039
        JMS W0022
        JMS QULT
        JCN 0CH,L0220
L0226:
        FIM 0,015H
        JUN QRETF
F0017:
; LOAD
; CHAR CH;
; UNSIGNED LABEL, MARK;
; UNSIGNED PREVIOUS;
; PREVIOUS = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,065H
        JMS QSTA
; WHILE (!ERROR) (
        JUN L0228
L0227:
; DONE = 0; MARK = USED;
        JMS QV073
        JMS W0018
        FIM 0,055H
        JMS QSTA
; DO (
L0231:
; IF (INTERACTIVE) PRINTF("> ");
        JMS W0003
        LD 7
        JCN 4,L0234
        FIM 0,S0004 AND 0FFH
        JMS QS1
L0234:
; CH = GETCHAR();
        JMS QV054
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0236
L0235:
        JMS QV054
L0236:
        JMS QV062
        JCN 4,$+4
        JUN L0235
        JMS QV063
        JCN 4,$+4
        JUN L0235
        JMS QV071
        JCN 4,$+4
        JUN L0231
        JMS QV072
        JCN 4,$+4
        JUN L0231
; IF (CH == 'R') (
        JMS QV068
        JCN 0CH,$+4
        JUN L0239
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0241
        JMS QGETC
        FIM 0AH,04EH
        JMS QEQ8
        JCN 0CH,L0240
L0241:
        JMS QV044
L0240:
; CH = GETCHAR();
        JMS QV054
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0243
L0242:
        JMS QV054
L0243:
        JMS QV062
        JCN 0CH,L0242
        JMS QV063
        JCN 0CH,L0242
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV071
        JCN 0CH,L0246
        JMS QV072
        JCN 0CH,L0246
        JMS QV044
L0246:
; RETURN;
        FIM 0,025H
        JUN QRETF
L0239:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,045H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0041
        JMS QV069
        JCN 0AH,L0248
        JMS QV070
        JCN 2,L0250
L0248:
        JMS QV044
L0247:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0250
L0249:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0042
        JMS QV084
        JCN 0CH,L0254
        JMS W0042
        JMS QV085
        JCN 4,L0253
        JMS W0041
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0253
L0254:
        JMS QV075
L0253:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0042
        JMS QSHL1
        JMS QSHL1
        FIM 0,045H
        JMS QV086
        FIM 0,035H
        JMS QV058
        FIM 0,045H
        JMS QSTA
; CH = GETCHAR();
        JMS QV054
L0250:
        JMS W0041
        JMS QV069
        JCN 0AH,L0255
        JMS QV070
        JCN 2,L0249
L0255:
; IF (!ERROR && CH != ' ' && CH != 9) ERROR = 1;
        JMS W0005
        LD 7
        JCN 0CH,L0256
        JMS W0041
        JMS QV062
        JCN 0CH,L0256
        JMS QV063
        JCN 0CH,L0256
        JMS QV044
L0256:
; IF (!ERROR && (!LABEL ?? LABEL > 255 ?? LABEL <= PREVIOUS)) ERROR = 5;
        JMS W0005
        LD 7
        JCN 0CH,L0257
        JMS W0042
        JMS QTST
        JCN 4,L0258
        JMS QV080
        JCN 0CH,L0258
        JMS W0042
        FIM 0,065H
        JMS QLDB
        JMS QULE
        JCN 4,L0257
L0258:
        FIM 4,0
        FIM 6,5
        JMS W0001
L0257:
; IF (ERROR) (
        JMS W0005
        LD 7
        JCN 4,L0267
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 4,L0260
        JUN L0262
L0261:
        JMS QV054
L0262:
        JMS W0041
        JMS QV071
        JCN 0CH,L0265
        JMS QV072
        JCN 4,L0261
L0265:
L0260:
; RETURN;
        FIM 0,025H
        JUN QRETF
L0259:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0267
L0266:
        JMS QV054
L0267:
        JMS W0041
        JMS QV062
        JCN 0CH,L0266
        JMS QV063
        JCN 0CH,L0266
; PREVIOUS = LABEL;
        JMS W0042
        FIM 0,065H
        JMS QSTA
; SAVE(LABEL);
        JMS W0042
        JMS W0031
        FIM 6,072H
        JMS W0032
        JUN F0013
L0270:
; PACKEDLINE(CH);
        JMS W0041
        FIM 0,0D4H
        JMS QSTAC
        FIM 6,074H
        FIM 0,0C4H
        JMS QSTAC
        JUN PACKE
L0271:
; COUNT++;
        FIM 0,040H
        JMS QINCC
L0228:
        JMS W0005
        LD 7
        JCN 0CH,$+4
        JUN L0227
        FIM 0,025H
        JUN QRETF
        ORG 0A1EH
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
        ORG 0A7CH
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
        ORG 0AD1H
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
        ORG 0AFDH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0B00H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0005
        JUN L0006
        JUN L0016
        JUN L0019
        JUN L0020
        JUN L0027
        JUN L0028
        JUN L0029
        JUN L0034
        JUN L0040
        JUN L0045
        JUN L0091
        JUN L0092
        JUN L0096
        JUN L0102
        JUN L0103
        JUN L0104
        JUN L0114
        JUN L0118
        JUN L0121
        JUN L0124
        JUN L0126
        JUN L0129
        JUN L0130
        JUN L0131
        JUN L0158
        JUN L0161
        JUN L0164
        JUN L0165
        JUN L0166
        JUN L0167
        JUN L0168
        JUN L0171
        JUN L0172
        JUN L0175
        JUN L0176
        JUN L0177
        JUN L0178
        JUN L0181
        JUN L0184
        JUN L0185
        JUN L0186
        JUN L0189
        JUN L0190
        JUN L0193
        JUN L0194
        JUN L0195
        JUN L0202
        JUN L0207
        JUN L0208
        JUN L0209
        JUN L0210
        JUN L0217
        JUN L0219
        JUN L0224
        JUN L0270
        JUN L0271
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0B7EH
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
        ORG 0BD1H
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
        ORG 0BEDH
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
        ORG 0C00H
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
        ORG 0C3FH
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
        DB 042H,041H,053H,049H,043H,034H,04CH,0AH,0
S0002:
        DB 052H,045H,041H,044H,059H,020H,028H,055H,050H,050H,045H,052H
        DB 043H,041H,053H,045H,029H,0AH,0
S0003:
        DB 03FH,045H,052H,052H,04FH,052H,020H,0
S0004:
        DB 03EH,020H,0
        ORG 0C7AH
; A = A * B: SHIFT THE PRODUCT IN R12-R15 LEFT AND ADD B FOR EACH BIT OF A.
QMUL:   LDM 0
        XCH 3
QMLP:   CLC
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
        CLC
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
        JCN 0AH,QMNO
        CLC
        LD 15
        ADD 11
        XCH 15
        LD 14
        ADD 10
        XCH 14
        LD 13
        ADD 9
        XCH 13
        LD 12
        ADD 8
        XCH 12
QMNO:   ISZ 3,QMLP
        LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        BBL 0
        ORG 0CB0H
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
        ORG 0CE1H
QV046:  JMS QSHL1
        JMS QSHL1
        JMS QSHL1
        JMS W0008
        JMS W0006
        FIM 0,2
        JMS QSTA
        JMS W0007
        FIM 0,2
        JMS QLDA
        JMS QSHL1
        JUN QLDIC
        ORG 0CF9H
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0
        ORG 0D00H
; A = THE INT AT MAIN-MEMORY ADDRESS A (BANK, REGISTER, CHARACTER).
QLDI:   LD 5
        DCL
        LD 6
        XCH 0
        LD 7
        XCH 1
        SRC 0
        RDM
        XCH 4
        INC 1
        SRC 0
        RDM
        XCH 5
        INC 1
        SRC 0
        RDM
        XCH 6
        INC 1
        SRC 0
        RDM
        XCH 7
        BBL 0
        ORG 0D16H
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
        ORG 0D2BH
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
        ORG 0D3FH
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
        ORG 0D51H
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
        ORG 0D62H
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
        ORG 0D72H
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
        ORG 0D80H
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
        ORG 0D8EH
QV051:  FIM 0,0D1H
        JMS QLDA
        LD 5
        XCH 4
        LD 6
        XCH 5
        LD 7
        XCH 6
        LDM 0
        XCH 7
        JUN QV046
        ORG 0D9CH
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
        ORG 0DA9H
; A == B IN THEIR LOW BYTES, RETURNING 1 OR 0: --SIZE'S NARROW EQUALITY.
QEQ8:   CLC
        LD 7
        SUB 11
        JCN 0CH,QE8F
        CLC
        LD 6
        SUB 10
        JCN 0CH,QE8F
        BBL 1
QE8F:   BBL 0
        ORG 0DB5H
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
        ORG 0DC1H
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
        ORG 0DCDH
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
        ORG 0DD9H
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
        ORG 0DE5H
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
        ORG 0DF1H
QV055:  LD 6
        XCH 7
        LD 5
        XCH 6
        LD 4
        XCH 5
        LDM 0
        XCH 4
        JMS QUSR1
        JUN QUSR1
        ORG 0E00H
QV045:  JMS QSHL1
        JMS QSHL1
        FIM 8,6
        FIM 0AH,080H
        JUN QADD
        ORG 0E0AH
QV048:  JMS QXAB
        FIM 4,0
        FIM 6,080H
        JMS QADD
        JUN W0031
        ORG 0E14H
QV056:  JMS W0006
        JMS W0008
        JMS W0007
        JMS W0009
        JUN QV049
        ORG 0E1EH
QV057:  JMS QV043
        FIM 0,032H
        JMS QSTAC
        FIM 0AH,041H
        JUN QGE8
        ORG 0E28H
QV058:  JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JUN QSUB
        ORG 0E32H
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0E3AH
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0E42H
QV052:  JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JUN QSUB
        ORG 0E4AH
QV064:  JMS QXAB
        JMS W0009
        JMS QADD
        JUN QV053
        ORG 0E52H
QV065:  FIM 4,0
        FIM 6,4
        JMS W0001
        JUN W0018
        ORG 0E5AH
QV066:  JMS W0007
        JMS QV049
        FIM 0,073H
        JUN QSTAC
        ORG 0E62H
QV067:  FIM 8,0
        FIM 0AH,07FH
        JMS QAND
        JUN QV048
        ORG 0E6AH
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0
        ORG 0E71H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0E77H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0E7DH
QV043:  JMS W0006
        JMS QSHL1
        JUN QLDIC
        ORG 0E83H
QV044:  FIM 4,0
        FIM 6,1
        JUN W0001
        ORG 0E89H
QV053:  FIM 8,0
        FIM 0AH,080H
        JUN QSUB
        ORG 0E8FH
QV059:  FIM 4,0
        FIM 6,045H
        JUN W0034
        ORG 0E95H
QV060:  FIM 4,0
        FIM 6,054H
        JUN W0034
        ORG 0E9BH
QV061:  FIM 4,0
        FIM 6,04EH
        JUN W0034
        ORG 0EA1H
QV073:  FIM 4,0
        FIM 6,0
        JUN W0002
        ORG 0EA7H
QV074:  FIM 4,0
        FIM 6,0AH
        JUN QPUTC
        ORG 0EADH
QV075:  FIM 4,0
        FIM 6,2
        JUN W0001
        ORG 0EB3H
QV076:  JMS W0007
        FIM 0,032H
        JUN QV052
        ORG 0EB9H
QV077:  JMS QV045
        JMS QLDI
        JUN W0013
        ORG 0EBFH
QV078:  JMS W0015
        FIM 0,092H
        JUN QLDB
        ORG 0EC5H
QV079:  JMS W0017
        FIM 0,0E2H
        JUN QLDB
        ORG 0ECBH
QV080:  FIM 8,0
        FIM 0AH,0FFH
        JUN QUGT
        ORG 0ED1H
QV081:  JMS W0024
        FIM 0AH,03CH
        JUN QEQ8
        ORG 0ED7H
QV082:  JMS QLDA
        FIM 0,023H
        JUN QSTA
        ORG 0EDDH
QV083:  FIM 0,024H
        JMS QSTA
        JUN W0005
        ORG 0EE3H
QV084:  FIM 8,019H
        FIM 0AH,099H
        JUN QUGT
        ORG 0EE9H
QV085:  FIM 8,019H
        FIM 0AH,099H
        JUN QEQ
        ORG 0EEFH
QV086:  JMS QLDB
        JMS QADD
        JUN QSHL1
        ORG 0EF5H
QV087:  FIM 4,0
        FIM 6,04FH
        JUN W0034
        ORG 0EFBH
W0001: FIM 0,050H
        JUN QSTAC
        ORG 0F00H
W0002: FIM 0,060H
        JUN QSTAC
        ORG 0F04H
W0003: FIM 0,070H
        JUN QLDA
        ORG 0F08H
W0004: FIM 0,030H
        JUN QSTA
        ORG 0F0CH
W0005: FIM 0,050H
        JUN QLDA
        ORG 0F10H
W0006: FIM 0,020H
        JUN QLDA
        ORG 0F14H
W0007: FIM 0,020H
        JUN QINCV
        ORG 0F18H
W0008: FIM 0,0F1H
        JUN QSTA
        ORG 0F1CH
W0009: FIM 0,0F1H
        JUN QLDA
        ORG 0F20H
W0010: FIM 0,0B1H
        JUN QSTAC
        ORG 0F24H
W0011: FIM 0,0A1H
        JUN QSTAC
        ORG 0F28H
W0012: FIM 0,0C1H
        JUN QSTAC
        ORG 0F2CH
W0013: FIM 0,052H
        JUN QSTA
        ORG 0F30H
W0014: FIM 0,082H
        JUN QSTA
        ORG 0F34H
W0015: FIM 0,082H
        JUN QLDA
        ORG 0F38H
W0016: FIM 0,0D2H
        JUN QSTA
        ORG 0F3CH
W0017: FIM 0,0D2H
        JUN QLDA
        ORG 0F40H
W0018: FIM 0,010H
        JUN QLDA
        ORG 0F44H
W0019: FIM 0,033H
        JUN QLDA
        ORG 0F48H
W0020: FIM 0,043H
        JUN QLDA
        ORG 0F4CH
W0021: FIM 0,033H
        JUN QINCV
        ORG 0F50H
W0022: FIM 0,010H
        JUN QLDB
        ORG 0F54H
W0023: FIM 0,0C2H
        JUN QSTAC
        ORG 0F58H
W0024: FIM 0,0C3H
        JUN QLDA
        ORG 0F5CH
W0025: FIM 0,093H
        JUN QLDA
        ORG 0F60H
W0026: FIM 0,0A3H
        JUN QLDB
        ORG 0F64H
W0027: FIM 0,0E3H
        JUN QSTAC
        ORG 0F68H
W0028: FIM 0,0E3H
        JUN QLDA
        ORG 0F6CH
W0029: FIM 0,0A4H
        JUN QLDA
        ORG 0F70H
W0030: FIM 0,094H
        JUN QSTAC
        ORG 0F74H
W0031: FIM 0,064H
        JUN QSTAC
        ORG 0F78H
W0032: FIM 0,054H
        JUN QSTAC
        ORG 0F7CH
W0033: FIM 0,0D4H
        JUN QLDA
        ORG 0F80H
W0034: FIM 0,044H
        JUN QSTAC
        ORG 0F84H
W0035: FIM 0,034H
        JUN QSTAC
        ORG 0F88H
W0036: FIM 0,0E4H
        JUN QSTAC
        ORG 0F8CH
W0037: FIM 0,5
        JUN QLDA
        ORG 0F90H
W0038: FIM 0,0E4H
        JUN QLDA
        ORG 0F94H
W0039: FIM 0,030H
        JUN QLDA
        ORG 0F98H
W0040: FIM 0,035H
        JUN QSTAC
        ORG 0F9CH
W0041: FIM 0,035H
        JUN QLDA
        ORG 0FA0H
W0042: FIM 0,045H
        JUN QLDA
        ORG 0FA4H
QV047:  JMS QLDB
        JUN QEQ8
        ORG 0FA8H
QV049:  JMS QSHL1
        JUN QLDIC
        ORG 0FACH
QV050:  JMS QSTAC
        JUN W0019
        ORG 0FB0H
QV054:  JMS QGETC
        JUN W0040
        ORG 0FB4H
QV062:  FIM 0AH,020H
        JUN QEQ8
        ORG 0FB8H
QV063:  FIM 0AH,9
        JUN QEQ8
        ORG 0FBCH
QV068:  FIM 0AH,052H
        JUN QEQ8
        ORG 0FC0H
QV069:  FIM 0AH,030H
        JUN QGE8
        ORG 0FC4H
QV070:  FIM 0AH,039H
        JUN QLE8
        ORG 0FC8H
QV071:  FIM 0AH,0DH
        JUN QEQ8
        ORG 0FCCH
QV072:  FIM 0AH,0AH
        JUN QEQ8
        ORG 0FD0H
QV088:  FIM 0AH,05AH
        JUN QLE8
        ORG 0FD4H
QV089:  FIM 0AH,022H
        JUN QEQ8
        ORG 0FD8H
QV090:  FIM 0AH,03EH
        JUN QEQ8
        ORG 0FDCH
QV091:  JMS W0025
        JUN W0026
        ORG 0FE0H
QV092:  JMS QBOOL
        JUN W0027
        ORG 0FE4H
QV093:  JMS QGETC
        JUN W0036
        END
