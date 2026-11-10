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
        JMS QV054
; IF (INTERACTIVE) PUTS("READY (UPPERCASE)");
        JMS W0003
        LD 7
        JCN 4,L0004
        FIM 0,S0002 AND 0FFH
        JMS QS1
L0004:
; LOAD();
        FIM 6,4
        FIM 0,0B3H
        JMS QSTAC
        JUN F0017
L0005:
; LINE = 0;
        FIM 4,0
        FIM 6,0
        JMS W0004
; RUNPROGRAM();
        FIM 6,6
        FIM 0,0A3H
        JMS QSTAC
        JUN L0194
L0006:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0005
        LD 7
        JCN 4,L0007
        FIM 0,S0003 AND 0FFH
        JMS QS1
        JMS W0005
        JMS QPRTU
        JMS QV055
L0007:
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
; RETURN 0;
BLANK:
; BLANKS
; WHILE (TEXT(POS) == ' ' ?? TEXT(POS) == 9) POS++;
        JUN L0009
L0008:
        JMS W0006
L0009:
        JMS QV036
        JMS QV047
        JCN 0CH,L0008
        JMS QV036
        JMS QV048
        JCN 0CH,L0008
        FIM 0,090H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS QV036
        FIM 0,0B0H
        JMS QLDB
        JMS QEQ8
        JCN 0CH,L0013
        JMS QV037
        JUN L0012
L0013:
; ELSE POS++;
        JMS W0006
L0012:
        FIM 0,0A0H
        JUN QRETF
NUMBE:
; NUMBER
; UNSIGNED VALUE;
; CHAR CH;
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0D0H
        JMS QSTA
; CH = TEXT(POS);
        JMS QV036
        FIM 0,0E0H
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV050
        JCN 0AH,L0015
        JMS QV051
        JCN 2,L0017
L0015:
        JMS QV037
L0014:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0017
L0016:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0008
        JMS QV056
        JCN 0CH,L0021
        JMS W0008
        JMS QV057
        JCN 4,L0020
        FIM 0,0E0H
        JMS QLDA
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0020
L0021:
        JMS QV058
L0020:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0008
        JMS QSHL1
        JMS QSHL1
        FIM 0,0D0H
        JMS QV059
        FIM 0,0E0H
        JMS QV042
        FIM 0,0D0H
        JMS QV067
; CH = TEXT(POS);
        JMS QV039
        FIM 0,0E0H
        JMS QSTAC
L0017:
        FIM 0,0E0H
        JMS QLDA
        JMS QV050
        JCN 0AH,L0022
        JMS QV051
        JCN 2,L0016
L0022:
; RETURN VALUE;
        JMS W0008
        FIM 0,0C0H
        JUN QRETF
DESTI:
; DESTINATION
; UNSIGNED INDEX;
; CHAR CH;
; BLANKS();
        FIM 6,8
        JMS W0009
        JUN L0009
L0023:
; CH = TEXT(POS);
        JMS QV043
        JCN 0AH,L0024
        JMS QV068
        JCN 0AH,L0024
        JMS QV041
        FIM 0,0F0H
        JUN QRETF
L0024:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        JMS QEQ8
        JCN 0CH,L0025
        JMS QV037
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0025:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0006
        FIM 6,0AH
        JMS W0009
        JUN L0009
L0026:
        FIM 4,0
        FIM 6,028H
        JMS W0010
        FIM 6,0CH
        JMS W0011
        JUN NEED
L0027:
        FIM 6,0EH
        JMS W0009
        JUN L0009
L0028:
; CH = TEXT(POS);
        JMS QV043
        JCN 0AH,L0030
        JMS QV068
        JCN 0AH,L0030
        JMS QV041
        JMS QV038
        JMS QLDI
        FIM 0,1
        JMS QSTA
        JUN L0029
L0030:
; ELSE INDEX = NUMBER();
        FIM 6,010H
        JMS W0012
        JUN NUMBE
L0031:
        FIM 0,1
        JMS QSTA
L0029:
; BLANKS(); NEED(')');
        FIM 6,012H
        JMS W0009
        JUN L0009
L0032:
        FIM 4,0
        FIM 6,029H
        JMS W0010
        FIM 6,014H
        JMS W0011
        JUN NEED
L0033:
; IF (ERROR) RETURN 0;
        JMS W0005
        LD 7
        JCN 4,L0034
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0034:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,040H
        JMS QUGE
        JCN 4,L0035
        FIM 4,0
        FIM 6,7
        JMS W0001
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0035:
; RETURN INDEX+26;
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,01AH
        JMS QADD
        FIM 0,0F0H
        JUN QRETF
ATOM:
; ATOM
; UNSIGNED VALUE;
; CHAR CH;
; BLANKS();
        FIM 6,016H
        JMS W0009
        JUN L0009
L0036:
; CH = TEXT(POS);
        JMS QV036
        FIM 0,041H
        JMS QSTAC
; IF ((CH >= 'A' && CH <= 'Z') ?? CH == '@') VALUE = VARS(DESTINATION())
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0040
        JMS QV068
        JCN 2,L0039
L0040:
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,L0038
L0039:
        FIM 6,018H
        FIM 0,0F0H
        JMS QSTAC
        JUN DESTI
L0041:
        JMS QV038
        JMS QLDI
        FIM 0,031H
        JMS QSTA
        JUN L0037
L0038:
; ELSE VALUE = NUMBER();
        FIM 6,01AH
        JMS W0012
        JUN NUMBE
L0042:
        FIM 0,031H
        JMS QSTA
L0037:
; BLANKS();
        FIM 6,01CH
        JMS W0009
        JUN L0009
L0043:
; RETURN VALUE;
        FIM 0,031H
        JMS QLDA
        FIM 0,021H
        JUN QRETF
PRODU:
; PRODUCT
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = ATOM();
        FIM 6,01EH
        FIM 0,021H
        JMS QSTAC
        JUN ATOM
L0044:
        JMS W0013
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0046
L0045:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,091H
        JMS QV067
        FIM 0,091H
        JMS QV069
        FIM 0,081H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,020H
        FIM 0,021H
        JMS QSTAC
        JUN ATOM
L0049:
        FIM 0,071H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,081H
        JMS QLDA
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,L0051
        JMS QV060
        JMS QMUL
        JMS W0013
        JUN L0050
L0051:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,071H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0053
        FIM 4,0
        FIM 6,3
        JMS W0001
        JUN L0052
L0053:
; ELSE VALUE = VALUE / RIGHT;
        JMS QV060
        JMS QUDIV
        JMS W0013
L0052:
L0050:
L0046:
        JMS W0005
        LD 7
        JCN 0CH,L0054
        JMS QV036
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,$+4
        JUN L0045
        JMS QV036
        FIM 0AH,02FH
        JMS QEQ8
        JCN 4,$+4
        JUN L0045
L0054:
; RETURN VALUE;
        JMS W0014
        FIM 0,051H
        JUN QRETF
EXPRE:
; EXPRESSION
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = PRODUCT();
        FIM 6,022H
        FIM 0,051H
        JMS QSTAC
        JUN PRODU
L0055:
        JMS W0015
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0057
L0056:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,0E1H
        JMS QV067
        FIM 0,0E1H
        JMS QV069
        FIM 0,0D1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,024H
        FIM 0,051H
        JMS QSTAC
        JUN PRODU
L0060:
        FIM 0,0C1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0D1H
        JMS QLDA
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,L0062
        JMS QV061
        JMS QADD
        JMS W0015
        JUN L0061
L0062:
; ELSE VALUE = VALUE - RIGHT;
        JMS QV061
        JMS QSUB
        JMS W0015
L0061:
L0057:
        JMS W0005
        LD 7
        JCN 0CH,L0063
        JMS QV036
        FIM 0AH,02BH
        JMS QEQ8
        JCN 0CH,L0056
        JMS QV036
        FIM 0AH,02DH
        JMS QEQ8
        JCN 0CH,L0056
L0063:
; RETURN VALUE;
        JMS W0016
        FIM 0,0A1H
        JUN QRETF
FINDL:
; FINDLINE
; UNSIGNED I;
; I = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,012H
        JMS QSTA
; WHILE (I < USED) (
        JUN L0065
L0064:
; IF (TEXT(I) == TARGET) RETURN I;
        FIM 0,012H
        JMS QV069
        FIM 0,2
        JMS QLDB
        JMS QEQ
        JCN 4,L0068
        FIM 0,012H
        JMS QLDA
        FIM 0,0F1H
        JUN QRETF
L0068:
; I++;
        JMS W0017
; WHILE (TEXT(I)) I++;
        JUN L0070
L0069:
        JMS W0017
L0070:
        JMS QV039
        LD 7
        JCN 0CH,L0069
        LD 6
        JCN 0CH,L0069
; I++;
        JMS W0017
L0065:
        JMS QV062
        JCN 0CH,L0064
; ERROR = 4;
        FIM 4,0
        FIM 6,4
        JMS W0001
; RETURN USED;
        JMS W0018
        FIM 0,0F1H
        JUN QRETF
PRINT:
; PRINTLINE
; UNSIGNED VALUE;
; CHAR CH;
; BLANKS();
        FIM 6,026H
        JMS W0009
        JUN L0009
L0073:
; IF (TEXT(POS) == '"') (
        JMS QV036
        JMS QV070
        JCN 4,L0075
; POS++;
        JMS QV049
; WHILE (CH && CH != '"') (
        JUN L0077
L0076:
; PUTCHAR(CH);
        FIM 0,042H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS QV049
L0077:
        LD 7
        JCN 0CH,L0081
        LD 6
        JCN 4,L0080
L0081:
        JMS QV070
        JCN 4,L0076
L0080:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0010
        FIM 6,028H
        JMS W0011
        JUN NEED
L0082:
        JUN L0074
L0075:
; VALUE = EXPRESSION();
        FIM 6,02AH
        JMS W0019
        JUN EXPRE
L0083:
        FIM 0,032H
        JMS QSTA
; IF (!ERROR) PRINTF("%U", VALUE);
        JMS W0005
        LD 7
        JCN 4,$+4
        JUN L0084
        FIM 0,032H
        JMS QLDA
        JMS QPRTU
L0084:
L0074:
; BLANKS();
        FIM 6,02CH
        JMS W0009
        JUN L0009
L0085:
; IF (TEXT(POS) == ';') POS++;
        JMS QV036
        FIM 0AH,03BH
        JMS QEQ8
        JCN 4,L0087
        JMS W0006
        JUN L0086
L0087:
; ELSE PUTCHAR(10);
        JMS QV055
L0086:
        FIM 0,022H
        JUN QRETF
BRANC:
; BRANCH
; UNSIGNED LEFT, RIGHT, TARGET;
; CHAR OP, EQUAL, YES;
; BLANKS();
        FIM 6,02EH
        JMS W0009
        JUN L0009
L0088:
; LEFT = EXPRESSION();
        FIM 6,030H
        JMS W0019
        JUN EXPRE
L0089:
        FIM 0,062H
        JMS QSTA
; OP = TEXT(POS);
        JMS QV036
        FIM 0,092H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0005
        LD 7
        JCN 0CH,L0091
        JMS W0020
        LD 7
        JCN 0CH,L0090
        LD 6
        JCN 0CH,L0090
L0091:
        JMS QV037
        FIM 0,052H
        JUN QRETF
L0090:
; POS++;
        JMS W0006
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0A2H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS QV063
        JCN 0CH,L0093
        JMS QV071
        JCN 4,L0092
L0093:
        JMS QV036
        FIM 0AH,03DH
        JMS QEQ8
        JCN 4,L0092
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,0A2H
        JMS QSTAC
; POS++;
        JMS W0006
L0092:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0020
        FIM 0AH,03DH
        JMS QEQ8
        JCN 0CH,L0094
        FIM 0AH,03CH
        JMS QEQ8
        JCN 0CH,L0094
        JMS QV071
        JCN 0CH,L0094
        JMS QV037
L0094:
; RIGHT = EXPRESSION();
        FIM 6,032H
        JMS W0019
        JUN EXPRE
L0095:
        FIM 0,072H
        JMS QSTA
; NEED(':');
        FIM 4,0
        FIM 6,03AH
        JMS W0010
        FIM 6,034H
        JMS W0011
        JUN NEED
L0096:
; BLANKS();
        FIM 6,036H
        JMS W0009
        JUN L0009
L0097:
; TARGET = NUMBER();
        FIM 6,038H
        JMS W0012
        JUN NUMBE
L0098:
        FIM 0,082H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS QV072
        JMS QEQ
        JMS QV073
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS QV063
        JCN 4,L0099
        JMS QV072
        JMS QULT
        JCN 0CH,L0102
        FIM 0,0A2H
        JMS QLDA
        LD 7
        JCN 4,L0100
        JMS W0024
        LD 7
        JCN 4,L0100
L0102:
        LDM 1
        JUN L0101
L0100:
        LDM 0
L0101:
        JMS QV073
L0099:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0020
        JMS QV071
        JCN 4,L0103
        JMS QV072
        JMS QUGT
        JCN 0CH,L0106
        FIM 0,0A2H
        JMS QLDA
        LD 7
        JCN 4,L0104
        JMS W0024
        LD 7
        JCN 4,L0104
L0106:
        LDM 1
        JUN L0105
L0104:
        LDM 0
L0105:
        JMS QV073
L0103:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0005
        LD 7
        JCN 4,$+4
        JUN L0107
        JMS W0024
        LD 7
        JCN 0CH,$+4
        JUN L0107
        FIM 0,082H
        JMS QV064
        FIM 6,03AH
        FIM 0,0F1H
        JMS QSTAC
        JUN FINDL
L0108:
        JMS W0004
L0107:
        FIM 0,052H
        JUN QRETF
F0012:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,03CH
        JMS W0009
        JUN L0009
L0109:
; CH = TEXT(POS);
        JMS QV036
        FIM 0,0D2H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0110
        LD 6
        JCN 0CH,L0110
        JMS QV037
        FIM 0,0C2H
        JUN QRETF
L0110:
; POS++;
        JMS W0006
; IF (CH == 'P') PRINTLINE();
        FIM 0,0D2H
        JMS QLDA
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0112
        FIM 6,03EH
        FIM 0,022H
        JMS QSTAC
        JUN PRINT
L0113:
        JUN L0111
L0112:
; ELSE IF (CH == 'F') BRANCH();
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0115
        FIM 6,040H
        FIM 0,052H
        JMS QSTAC
        JUN BRANC
L0116:
        JUN L0114
L0115:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0118
; BLANKS();
        FIM 6,042H
        JMS W0009
        JUN L0009
L0119:
; VALUE = NUMBER();
        FIM 6,044H
        JMS W0012
        JUN NUMBE
L0120:
        JMS QV065
        LD 7
        JCN 0CH,L0117
        FIM 0,0F2H
        JMS QV064
        FIM 6,046H
        FIM 0,0F1H
        JMS QSTAC
        JUN FINDL
L0122:
        JMS W0004
L0121:
        JUN L0117
L0118:
; ) ELSE IF (CH == 'L') (
        FIM 0AH,04CH
        JMS QEQ8
        JCN 4,L0124
; BLANKS();
        FIM 6,048H
        JMS W0009
        JUN L0009
L0125:
; VARIABLE = DESTINATION();
        FIM 6,04AH
        FIM 0,0F0H
        JMS QSTAC
        JUN DESTI
L0126:
        FIM 0,0E2H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,04CH
        JMS W0009
        JUN L0009
L0127:
        FIM 4,0
        FIM 6,03DH
        JMS W0010
        FIM 6,04EH
        JMS W0011
        JUN NEED
L0128:
; VALUE = EXPRESSION();
        FIM 6,050H
        JMS W0019
        JUN EXPRE
L0129:
        JMS QV065
        LD 7
        JCN 0CH,L0123
        FIM 0,0E2H
        JMS QLDA
        JMS QV038
        FIM 0,0F2H
        JMS QLDB
        JMS QSTI
L0130:
        JUN L0123
L0124:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0132
; DONE = 1;
        FIM 4,0
        FIM 6,1
        JMS W0002
        JUN L0131
L0132:
; ) ELSE IF (CH == 'R') (
        JMS QV074
        JCN 4,L0134
; WHILE (TEXT(POS)) POS++;
        JUN L0136
L0135:
        JMS W0006
L0136:
        JMS QV036
        LD 7
        JCN 0CH,L0135
        LD 6
        JCN 0CH,L0135
        JUN L0133
L0134:
; ) ELSE ERROR = 1;
        JMS QV037
L0133:
L0131:
L0123:
L0117:
L0114:
L0111:
; BLANKS();
        FIM 6,052H
        JMS W0009
        JUN L0009
L0139:
; IF (TEXT(POS)) ERROR = 1;
        JMS QV036
        LD 7
        JCN 0CH,L0141
        LD 6
        JCN 4,L0140
L0141:
        JMS QV037
L0140:
        FIM 0,0C2H
        JUN QRETF
RNEED:
; RNEED
; IF (GETCHAR() != CH) ERROR = 1;
        JMS QGETC
        FIM 0,013H
        JMS QLDB
        JMS QEQ8
        JCN 0CH,L0142
        JMS QV037
L0142:
        FIM 0,3
        JUN QRETF
F0014:
; SAVE
; IF (USED >= SPACE) ERROR = 6;
        JMS W0018
        FIM 8,3
        FIM 0AH,040H
        JMS QUGE
        JCN 0CH,$+4
        JUN L0144
        FIM 4,0
        FIM 6,6
        JMS W0001
        JUN L0143
L0144:
; ELSE TEXT(USED++) = CH;
        JMS W0018
        FIM 0,043H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,043H
        JMS QLDA
        JMS QSHL1
        FIM 0,033H
        JMS QLDB
        JMS QSTIC
L0143:
        FIM 0,023H
        JUN QRETF
PACKE:
; PACKEDLINE
; CHAR CH, NEXT, QUOTED;
; IF (COMMAND == 'L') ( RNEED('E'); RNEED('T'); )
        JMS W0025
        FIM 0AH,04CH
        JMS QEQ8
        JCN 4,L0146
        JMS QV044
        FIM 6,054H
        JMS W0027
        JUN RNEED
L0147:
        JMS QV045
        FIM 6,056H
        JMS W0027
        JUN RNEED
L0148:
        JUN L0145
L0146:
; ELSE IF (COMMAND == 'P') ( RNEED('R'); RNEED('I'); RNEED('N'); RNEED('
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0150
        FIM 4,0
        FIM 6,052H
        JMS W0026
        FIM 6,058H
        JMS W0027
        JUN RNEED
L0151:
        FIM 4,0
        FIM 6,049H
        JMS W0026
        FIM 6,05AH
        JMS W0027
        JUN RNEED
L0152:
        JMS QV046
        FIM 6,05CH
        JMS W0027
        JUN RNEED
L0153:
        JMS QV045
        FIM 6,05EH
        JMS W0027
        JUN RNEED
L0154:
        JUN L0149
L0150:
; ELSE IF (COMMAND == 'I') ( RNEED('F'); COMMAND = 'F'; )
        FIM 0AH,049H
        JMS QEQ8
        JCN 4,L0156
        FIM 4,0
        FIM 6,046H
        JMS W0026
        FIM 6,060H
        JMS W0027
        JUN RNEED
L0157:
        FIM 4,0
        FIM 6,046H
        FIM 0,063H
        JMS QSTAC
        JUN L0155
L0156:
; ELSE IF (COMMAND == 'G') ( RNEED('O'); RNEED('T'); RNEED('O'); )
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0159
        JMS QV066
        FIM 6,062H
        JMS W0027
        JUN RNEED
L0160:
        JMS QV045
        FIM 6,064H
        JMS W0027
        JUN RNEED
L0161:
        JMS QV066
        FIM 6,066H
        JMS W0027
        JUN RNEED
L0162:
        JUN L0158
L0159:
; ELSE IF (COMMAND == 'E') ( RNEED('N'); RNEED('D'); )
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0164
        JMS QV046
        FIM 6,068H
        JMS W0027
        JUN RNEED
L0165:
        FIM 4,0
        FIM 6,044H
        JMS W0026
        FIM 6,06AH
        JMS W0027
        JUN RNEED
L0166:
        JUN L0163
L0164:
; ELSE IF (COMMAND == 'R') ( RNEED('E'); RNEED('M'); )
        JMS QV074
        JCN 4,L0168
        JMS QV044
        FIM 6,06CH
        JMS W0027
        JUN RNEED
L0169:
        FIM 4,0
        FIM 6,04DH
        JMS W0026
        FIM 6,06EH
        JMS W0027
        JUN RNEED
L0170:
        JUN L0167
L0168:
; ELSE ERROR = 1;
        JMS QV037
L0167:
L0163:
L0158:
L0155:
L0149:
L0145:
; SAVE(COMMAND);
        JMS W0025
        JMS W0028
        FIM 6,070H
        JMS W0029
        JUN F0014
L0171:
; QUOTED = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,093H
        JMS QSTAC
; CH = GETCHAR();
        JMS QV075
; WHILE (!ERROR && CH != 13 && CH != 10) (
        JUN L0173
L0172:
; IF (!QUOTED && COMMAND == 'F' && CH == 'T') (
        JMS W0031
        LD 7
        NOP
        JCN 4,$+4
        JUN L0177
        LD 6
        JCN 4,$+4
        JUN L0177
        JMS W0025
        FIM 0AH,046H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0177
        JMS W0032
        FIM 0AH,054H
        JMS QEQ8
        JCN 4,L0177
; NEXT = GETCHAR();
        JMS QGETC
        FIM 0,083H
        JMS QSTAC
; IF (NEXT == 'H') (
        FIM 0AH,048H
        JMS QEQ8
        JCN 4,L0179
; RNEED('E'); RNEED('N'); SAVE(':');
        JMS QV044
        FIM 6,072H
        JMS W0027
        JUN RNEED
L0180:
        JMS QV046
        FIM 6,074H
        JMS W0027
        JUN RNEED
L0181:
        FIM 4,0
        FIM 6,03AH
        JMS W0028
        FIM 6,076H
        JMS W0029
        JUN F0014
L0182:
; CH = GETCHAR();
        JMS QV075
        JUN L0176
L0179:
; SAVE('T'); CH = NEXT;
        FIM 4,0
        FIM 6,054H
        JMS W0028
        FIM 6,078H
        JMS W0029
        JUN F0014
L0183:
        FIM 0,083H
        JMS QLDA
        JMS W0030
        JUN L0176
L0177:
; IF (!CH ?? (!QUOTED && CH == ':')) ERROR = 1;
        JMS W0032
        LD 7
        JCN 0CH,L0186
        LD 6
        JCN 4,L0185
L0186:
        JMS W0031
        LD 7
        JCN 0CH,L0184
        LD 6
        JCN 0CH,L0184
        JMS W0032
        FIM 0AH,03AH
        JMS QEQ8
        JCN 4,L0184
L0185:
        JMS QV037
L0184:
; IF (CH == '"') QUOTED = 1-QUOTED;
        JMS W0032
        JMS QV070
        JCN 4,L0187
        FIM 4,0
        FIM 6,1
        FIM 0,093H
        JMS QLDB
        JMS QSUB
        FIM 0,093H
        JMS QSTAC
L0187:
; IF (QUOTED ?? CH > ' ') SAVE(CH);
        JMS W0031
        LD 7
        JCN 0CH,L0189
        LD 6
        JCN 0CH,L0189
        JMS W0032
        FIM 0AH,020H
        JMS QLE8
        JCN 2,L0188
L0189:
        JMS W0032
        JMS W0028
        FIM 6,07AH
        JMS W0029
        JUN F0014
L0190:
L0188:
; CH = GETCHAR();
        JMS QV075
L0176:
L0173:
        JMS W0005
        LD 7
        JCN 0CH,L0191
        JMS W0032
        JMS QV052
        JCN 0CH,L0191
        JMS QV053
        JCN 0CH,$+4
        JUN L0172
L0191:
; SAVE(0);
        FIM 4,0
        FIM 6,0
        JMS W0028
        FIM 6,07CH
        JMS W0029
        JUN F0014
L0192:
        FIM 0,053H
        JUN QRETF
RUNPR:
; RUNPROGRAM
; WHILE (!ERROR && !DONE && LINE < USED) (
        JUN L0194
L0193:
; POS = LINE+1;
        FIM 0,030H
        JMS QLDA
        JMS QINC
        FIM 0,020H
        JMS QSTA
; LINE = POS;
        JMS W0004
; WHILE (TEXT(LINE)) LINE++;
        JUN L0198
L0197:
        FIM 0,030H
        JMS QINCV
L0198:
        JMS QV039
        LD 7
        JCN 0CH,L0197
        LD 6
        JCN 0CH,L0197
; LINE++;
        FIM 0,030H
        JMS QINCV
; STATEMENT();
        FIM 6,07EH
        FIM 0,0C2H
        JMS QSTAC
        JUN F0012
L0201:
L0194:
        JMS W0005
        LD 7
        JCN 4,$+4
        JUN L0202
        FIM 0,060H
        JMS QLDA
        LD 7
        JCN 4,$+4
        JUN L0202
        FIM 0,030H
        JMS QLDA
        JMS QV062
        JCN 4,$+4
        JUN L0193
L0202:
        FIM 0,0A3H
        JUN QRETF
F0017:
; LOAD
; CHAR CH;
; UNSIGNED LABEL, MARK;
; UNSIGNED PREVIOUS;
; PREVIOUS = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0F3H
        JMS QSTA
; WHILE (!ERROR) (
        JUN L0204
L0203:
; DONE = 0; MARK = USED;
        JMS QV054
        JMS W0018
        FIM 0,0E3H
        JMS QSTA
; DO (
L0207:
; IF (INTERACTIVE) PRINTF("> ");
        JMS W0003
        LD 7
        JCN 4,L0210
        FIM 0,S0004 AND 0FFH
        JMS QS1
L0210:
; CH = GETCHAR();
        JMS QV040
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0212
L0211:
        JMS QV040
L0212:
        JMS QV047
        JCN 0CH,L0211
        JMS QV048
        JCN 0CH,L0211
        JMS QV052
        JCN 0CH,L0207
        JMS QV053
        JCN 0CH,L0207
; IF (CH == 'R') (
        JMS QV074
        JCN 4,L0215
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0217
        JMS QGETC
        FIM 0AH,04EH
        JMS QEQ8
        JCN 0CH,L0216
L0217:
        JMS QV037
L0216:
; CH = GETCHAR();
        JMS QV040
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0219
L0218:
        JMS QV040
L0219:
        JMS QV047
        JCN 0CH,L0218
        JMS QV048
        JCN 0CH,L0218
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV052
        JCN 0CH,L0222
        JMS QV053
        JCN 0CH,L0222
        JMS QV037
L0222:
; RETURN;
        FIM 0,0B3H
        JUN QRETF
L0215:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0D3H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0034
        JMS QV050
        JCN 0AH,L0224
        JMS QV051
        JCN 2,L0226
L0224:
        JMS QV037
L0223:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0226
L0225:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0035
        JMS QV056
        JCN 0CH,L0230
        JMS W0035
        JMS QV057
        JCN 4,L0229
        JMS W0034
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0229
L0230:
        JMS QV058
L0229:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0035
        JMS QSHL1
        JMS QSHL1
        FIM 0,0D3H
        JMS QV059
        FIM 0,0C3H
        JMS QV042
        FIM 0,0D3H
        JMS QSTA
; CH = GETCHAR();
        JMS QV040
L0226:
        JMS W0034
        JMS QV050
        JCN 0AH,L0231
        JMS QV051
        JCN 2,L0225
L0231:
; IF (!ERROR && CH != ' ' && CH != 9) ERROR = 1;
        JMS W0005
        LD 7
        JCN 0CH,L0232
        JMS W0034
        JMS QV047
        JCN 0CH,L0232
        JMS QV048
        JCN 0CH,L0232
        JMS QV037
L0232:
; IF (!ERROR && (!LABEL ?? LABEL > 255 ?? LABEL <= PREVIOUS)) ERROR = 5;
        JMS W0005
        LD 7
        JCN 0CH,L0233
        JMS W0035
        JMS QTST
        JCN 4,L0234
        FIM 8,0
        FIM 0AH,0FFH
        JMS QUGT
        JCN 0CH,L0234
        JMS W0035
        FIM 0,0F3H
        JMS QLDB
        JMS QULE
        JCN 4,L0233
L0234:
        FIM 4,0
        FIM 6,5
        JMS W0001
L0233:
; IF (ERROR) (
        JMS W0005
        LD 7
        JCN 0CH,$+4
        JUN L0243
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 0CH,$+4
        JUN L0236
        JUN L0238
L0237:
        JMS QV040
L0238:
        JMS W0034
        JMS QV052
        JCN 0CH,L0241
        JMS QV053
        JCN 0CH,$+4
        JUN L0237
L0241:
L0236:
; RETURN;
        FIM 0,0B3H
        JUN QRETF
L0235:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0243
L0242:
        JMS QV040
L0243:
        JMS W0034
        JMS QV047
        JCN 0CH,L0242
        JMS QV048
        JCN 0CH,L0242
; PREVIOUS = LABEL;
        JMS W0035
        FIM 0,0F3H
        JMS QSTA
; SAVE(LABEL);
        JMS W0035
        JMS W0028
        FIM 6,080H
        JMS W0029
        JUN F0014
L0246:
; PACKEDLINE(CH);
        JMS W0034
        FIM 0,063H
        JMS QSTAC
        FIM 6,082H
        FIM 0,053H
        JMS QSTAC
        JUN PACKE
L0247:
; COUNT++;
        FIM 0,040H
        JMS QINCC
L0204:
        JMS W0005
        LD 7
        JCN 0CH,$+4
        JUN L0203
        FIM 0,0B3H
        JUN QRETF
        ORG 0848H
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
        ORG 08A6H
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
        ORG 08FBH
W0001: FIM 0,050H
        JUN QSTAC
        ORG 0900H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0005
        JUN L0006
        JUN L0023
        JUN L0026
        JUN L0027
        JUN L0028
        JUN L0031
        JUN L0032
        JUN L0033
        JUN L0036
        JUN L0041
        JUN L0042
        JUN L0043
        JUN L0044
        JUN L0049
        JUN L0055
        JUN L0060
        JUN L0073
        JUN L0082
        JUN L0083
        JUN L0085
        JUN L0088
        JUN L0089
        JUN L0095
        JUN L0096
        JUN L0097
        JUN L0098
        JUN L0108
        JUN L0109
        JUN L0113
        JUN L0116
        JUN L0119
        JUN L0120
        JUN L0122
        JUN L0125
        JUN L0126
        JUN L0127
        JUN L0128
        JUN L0129
        JUN L0139
        JUN L0147
        JUN L0148
        JUN L0151
        JUN L0152
        JUN L0153
        JUN L0154
        JUN L0157
        JUN L0160
        JUN L0161
        JUN L0162
        JUN L0165
        JUN L0166
        JUN L0169
        JUN L0170
        JUN L0171
        JUN L0180
        JUN L0181
        JUN L0182
        JUN L0183
        JUN L0190
        JUN L0192
        JUN L0201
        JUN L0246
        JUN L0247
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 098CH
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
        ORG 09CBH
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
        ORG 09FCH
W0002: FIM 0,060H
        JUN QSTAC
        ORG 0A00H
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
        ORG 0A3BH
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
        ORG 0A71H
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
        ORG 0A9DH
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
        ORG 0AB9H
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
        ORG 0ACFH
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
        ORG 0AE4H
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
        ORG 0AF8H
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0B00H
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
        ORG 0B12H
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
        ORG 0B23H
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
        ORG 0B33H
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
        ORG 0B41H
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
        ORG 0B4FH
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
        ORG 0B5BH
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
        ORG 0B67H
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
        ORG 0B73H
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
        ORG 0B7FH
QV041:  JMS W0006
        FIM 0,011H
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JUN QSUB
        ORG 0B8BH
QV038:  JMS QSHL1
        JMS QSHL1
        FIM 8,6
        FIM 0AH,080H
        JUN QADD
        ORG 0B95H
QV042:  JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JUN QSUB
        ORG 0B9FH
QV043:  JMS QV036
        FIM 0,011H
        JMS QSTAC
        FIM 0AH,041H
        JUN QGE8
        ORG 0BA9H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0BB1H
QV049:  JMS W0006
        JMS QV039
        FIM 0,042H
        JUN QSTAC
        ORG 0BB9H
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0
        ORG 0BC0H
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0
        ORG 0BC7H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0BCDH
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0BD3H
QV036:  JMS W0007
        JMS QSHL1
        JUN QLDIC
        ORG 0BD9H
QV037:  FIM 4,0
        FIM 6,1
        JUN W0001
        ORG 0BDFH
QV044:  FIM 4,0
        FIM 6,045H
        JUN W0026
        ORG 0BE5H
QV045:  FIM 4,0
        FIM 6,054H
        JUN W0026
        ORG 0BEBH
QV046:  FIM 4,0
        FIM 6,04EH
        JUN W0026
        ORG 0BF1H
QV054:  FIM 4,0
        FIM 6,0
        JUN W0002
        ORG 0BF7H
QV055:  FIM 4,0
        FIM 6,0AH
        JUN QPUTC
        ORG 0BFDH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0C00H
QV056:  FIM 8,019H
        FIM 0AH,099H
        JUN QUGT
        ORG 0C06H
QV057:  FIM 8,019H
        FIM 0AH,099H
        JUN QEQ
        ORG 0C0CH
QV058:  FIM 4,0
        FIM 6,2
        JUN W0001
        ORG 0C12H
QV059:  JMS QLDB
        JMS QADD
        JUN QSHL1
        ORG 0C18H
QV060:  JMS W0014
        FIM 0,071H
        JUN QLDB
        ORG 0C1EH
QV061:  JMS W0016
        FIM 0,0C1H
        JUN QLDB
        ORG 0C24H
QV062:  FIM 0,010H
        JMS QLDB
        JUN QULT
        ORG 0C2AH
QV063:  JMS W0020
        FIM 0AH,03CH
        JUN QEQ8
        ORG 0C30H
QV064:  JMS QLDA
        FIM 0,2
        JUN QSTA
        ORG 0C36H
QV065:  FIM 0,0F2H
        JMS QSTA
        JUN W0005
        ORG 0C3CH
QV066:  FIM 4,0
        FIM 6,04FH
        JUN W0026
        ORG 0C42H
W0003: FIM 0,070H
        JUN QLDA
        ORG 0C46H
W0004: FIM 0,030H
        JUN QSTA
        ORG 0C4AH
W0005: FIM 0,050H
        JUN QLDA
        ORG 0C4EH
W0006: FIM 0,020H
        JUN QINCV
        ORG 0C52H
W0007: FIM 0,020H
        JUN QLDA
        ORG 0C56H
W0008: FIM 0,0D0H
        JUN QLDA
        ORG 0C5AH
W0009: FIM 0,090H
        JUN QSTAC
        ORG 0C5EH
W0010: FIM 0,0B0H
        JUN QSTAC
        ORG 0C62H
W0011: FIM 0,0A0H
        JUN QSTAC
        ORG 0C66H
W0012: FIM 0,0C0H
        JUN QSTAC
        ORG 0C6AH
W0013: FIM 0,061H
        JUN QSTA
        ORG 0C6EH
W0014: FIM 0,061H
        JUN QLDA
        ORG 0C72H
W0015: FIM 0,0B1H
        JUN QSTA
        ORG 0C76H
W0016: FIM 0,0B1H
        JUN QLDA
        ORG 0C7AH
W0017: FIM 0,012H
        JUN QINCV
        ORG 0C7EH
W0018: FIM 0,010H
        JUN QLDA
        ORG 0C82H
W0019: FIM 0,0A1H
        JUN QSTAC
        ORG 0C86H
W0020: FIM 0,092H
        JUN QLDA
        ORG 0C8AH
W0021: FIM 0,062H
        JUN QLDA
        ORG 0C8EH
W0022: FIM 0,072H
        JUN QLDB
        ORG 0C92H
W0023: FIM 0,0B2H
        JUN QSTAC
        ORG 0C96H
W0024: FIM 0,0B2H
        JUN QLDA
        ORG 0C9AH
W0025: FIM 0,063H
        JUN QLDA
        ORG 0C9EH
W0026: FIM 0,013H
        JUN QSTAC
        ORG 0CA2H
W0027: FIM 0,3
        JUN QSTAC
        ORG 0CA6H
W0028: FIM 0,033H
        JUN QSTAC
        ORG 0CAAH
W0029: FIM 0,023H
        JUN QSTAC
        ORG 0CAEH
W0030: FIM 0,073H
        JUN QSTAC
        ORG 0CB2H
W0031: FIM 0,093H
        JUN QLDA
        ORG 0CB6H
W0032: FIM 0,073H
        JUN QLDA
        ORG 0CBAH
W0033: FIM 0,0C3H
        JUN QSTAC
        ORG 0CBEH
W0034: FIM 0,0C3H
        JUN QLDA
        ORG 0CC2H
W0035: FIM 0,0D3H
        JUN QLDA
        ORG 0CC6H
QV039:  JMS QSHL1
        JUN QLDIC
        ORG 0CCAH
QV040:  JMS QGETC
        JUN W0033
        ORG 0CCEH
QV047:  FIM 0AH,020H
        JUN QEQ8
        ORG 0CD2H
QV048:  FIM 0AH,9
        JUN QEQ8
        ORG 0CD6H
QV050:  FIM 0AH,030H
        JUN QGE8
        ORG 0CDAH
QV051:  FIM 0AH,039H
        JUN QLE8
        ORG 0CDEH
QV052:  FIM 0AH,0DH
        JUN QEQ8
        ORG 0CE2H
QV053:  FIM 0AH,0AH
        JUN QEQ8
        ORG 0CE6H
QV067:  JMS QSTA
        JUN W0006
        ORG 0CEAH
QV068:  FIM 0AH,05AH
        JUN QLE8
        ORG 0CEEH
QV069:  JMS QLDA
        JUN QV039
        ORG 0CF2H
QV070:  FIM 0AH,022H
        JUN QEQ8
        ORG 0CF6H
QV071:  FIM 0AH,03EH
        JUN QEQ8
        ORG 0CFAH
QV072:  JMS W0021
        JUN W0022
        ORG 0D00H
QV073:  JMS QBOOL
        JUN W0023
        ORG 0D04H
QV074:  FIM 0AH,052H
        JUN QEQ8
        ORG 0D08H
QV075:  JMS QGETC
        JUN W0030
        END
