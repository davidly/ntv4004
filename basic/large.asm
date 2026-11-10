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
; LOAD();
        FIM 6,4
        FIM 0,093H
        JMS QSTAC
        JUN F0016
L0001:
; LINE = 0;
        FIM 4,0
        FIM 6,0
        JMS W0001
; WHILE (!ERROR && !DONE && LINE < USED) (
        JUN L0003
L0002:
; POS = LINE+1;
        FIM 0,030H
        JMS QLDA
        JMS QINC
        FIM 0,020H
        JMS QSTA
; LINE = POS;
        JMS W0001
; WHILE (TEXT(LINE)) LINE++;
        JUN L0007
L0006:
        FIM 0,030H
        JMS QINCV
L0007:
        JMS QV037
        LD 7
        JCN 0CH,L0006
        LD 6
        JCN 0CH,L0006
; LINE++;
        FIM 0,030H
        JMS QINCV
; STATEMENT();
        FIM 6,6
        FIM 0,0B2H
        JMS QSTAC
        JUN F0012
L0010:
L0003:
        JMS W0002
        LD 7
        JCN 0CH,L0011
        FIM 0,060H
        JMS QLDA
        LD 7
        JCN 0CH,L0011
        FIM 0,030H
        JMS QLDA
        JMS QV050
        JCN 0CH,L0002
L0011:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0002
        LD 7
        JCN 4,L0012
        FIM 0,S0002 AND 0FFH
        JMS QS1
        JMS W0002
        JMS QPRTU
        JMS QV051
L0012:
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
BLANK:
; BLANKS
; WHILE (TEXT(POS) == ' ' ?? TEXT(POS) == 9) POS++;
        JUN L0014
L0013:
        JMS W0003
L0014:
        JMS QV034
        JMS QV045
        JCN 0CH,L0013
        JMS QV034
        JMS QV046
        JCN 0CH,L0013
        FIM 0,080H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS QV034
        FIM 0,0A0H
        JMS QLDB
        JMS QEQ8
        JCN 0CH,L0018
        JMS QV035
        JUN L0017
L0018:
; ELSE POS++;
        JMS W0003
L0017:
        FIM 0,090H
        JUN QRETF
NUMBE:
; NUMBER
; UNSIGNED VALUE;
; CHAR CH;
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0C0H
        JMS QSTA
; CH = TEXT(POS);
        JMS QV034
        FIM 0,0D0H
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV048
        JCN 0AH,L0020
        JMS QV049
        JCN 2,L0022
L0020:
        JMS QV035
L0019:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0022
L0021:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0006
        JMS QV052
        JCN 0CH,L0026
        JMS W0006
        JMS QV053
        JCN 4,L0025
        FIM 0,0D0H
        JMS QLDA
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0025
L0026:
        JMS QV054
L0025:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0006
        JMS QSHL1
        JMS QSHL1
        FIM 0,0C0H
        JMS QV055
        FIM 0,0D0H
        JMS QV040
        FIM 0,0C0H
        JMS QV062
; CH = TEXT(POS);
        JMS QV037
        FIM 0,0D0H
        JMS QSTAC
L0022:
        FIM 0,0D0H
        JMS QLDA
        JMS QV048
        JCN 0AH,L0027
        JMS QV049
        JCN 2,L0021
L0027:
; RETURN VALUE;
        JMS W0006
        FIM 0,0B0H
        JUN QRETF
DESTI:
; DESTINATION
; UNSIGNED INDEX;
; CHAR CH;
; BLANKS();
        FIM 6,8
        JMS W0007
        JUN L0014
L0028:
; CH = TEXT(POS);
        JMS QV041
        JCN 0AH,L0029
        JMS QV063
        JCN 0AH,L0029
        JMS QV038
        FIM 0,0E0H
        JUN QRETF
L0029:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        JMS QEQ8
        JCN 0CH,L0030
        JMS QV035
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JUN QRETF
L0030:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0003
        FIM 6,0AH
        JMS W0007
        JUN L0014
L0031:
        FIM 4,0
        FIM 6,028H
        JMS W0008
        FIM 6,0CH
        JMS W0009
        JUN NEED
L0032:
        FIM 6,0EH
        JMS W0007
        JUN L0014
L0033:
; CH = TEXT(POS);
        JMS QV041
        JCN 0AH,L0035
        JMS QV063
        JCN 0AH,L0035
        JMS QV038
        JMS QV036
        JMS QLDI
        FIM 0,0F0H
        JMS QSTA
        JUN L0034
L0035:
; ELSE INDEX = NUMBER();
        FIM 6,010H
        JMS W0010
        JUN NUMBE
L0036:
        FIM 0,0F0H
        JMS QSTA
L0034:
; BLANKS(); NEED(')');
        FIM 6,012H
        JMS W0007
        JUN L0014
L0037:
        FIM 4,0
        FIM 6,029H
        JMS W0008
        FIM 6,014H
        JMS W0009
        JUN NEED
L0038:
; IF (ERROR) RETURN 0;
        JMS W0002
        LD 7
        JCN 4,L0039
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JUN QRETF
L0039:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,0F0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,040H
        JMS QUGE
        JCN 4,L0040
        FIM 4,0
        FIM 6,7
        JMS W0005
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JUN QRETF
L0040:
; RETURN INDEX+26;
        FIM 0,0F0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,01AH
        JMS QADD
        FIM 0,0E0H
        JUN QRETF
ATOM:
; ATOM
; UNSIGNED VALUE;
; CHAR CH;
; BLANKS();
        FIM 6,016H
        JMS W0007
        JUN L0014
L0041:
; CH = TEXT(POS);
        JMS QV034
        FIM 0,031H
        JMS QSTAC
; IF ((CH >= 'A' && CH <= 'Z') ?? CH == '@') VALUE = VARS(DESTINATION())
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0045
        JMS QV063
        JCN 2,L0044
L0045:
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,L0043
L0044:
        FIM 6,018H
        FIM 0,0E0H
        JMS QSTAC
        JUN DESTI
L0046:
        JMS QV036
        JMS QLDI
        FIM 0,021H
        JMS QSTA
        JUN L0042
L0043:
; ELSE VALUE = NUMBER();
        FIM 6,01AH
        JMS W0010
        JUN NUMBE
L0047:
        FIM 0,021H
        JMS QSTA
L0042:
; BLANKS();
        FIM 6,01CH
        JMS W0007
        JUN L0014
L0048:
; RETURN VALUE;
        FIM 0,021H
        JMS QLDA
        FIM 0,011H
        JUN QRETF
PRODU:
; PRODUCT
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = ATOM();
        FIM 6,01EH
        FIM 0,011H
        JMS QSTAC
        JUN ATOM
L0049:
        JMS W0011
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0051
L0050:
; OP = TEXT(POS++);
        JMS W0004
        FIM 0,081H
        JMS QV062
        FIM 0,081H
        JMS QV064
        FIM 0,071H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,020H
        FIM 0,011H
        JMS QSTAC
        JUN ATOM
L0054:
        FIM 0,061H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,071H
        JMS QLDA
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,L0056
        JMS QV056
        JMS QMUL
        JMS W0011
        JUN L0055
L0056:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,061H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0058
        FIM 4,0
        FIM 6,3
        JMS W0005
        JUN L0057
L0058:
; ELSE VALUE = VALUE / RIGHT;
        JMS QV056
        JMS QUDIV
        JMS W0011
L0057:
L0055:
L0051:
        JMS W0002
        LD 7
        JCN 0CH,L0059
        JMS QV034
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,$+4
        JUN L0050
        JMS QV034
        FIM 0AH,02FH
        JMS QEQ8
        JCN 4,$+4
        JUN L0050
L0059:
; RETURN VALUE;
        JMS W0012
        FIM 0,041H
        JUN QRETF
EXPRE:
; EXPRESSION
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = PRODUCT();
        FIM 6,022H
        FIM 0,041H
        JMS QSTAC
        JUN PRODU
L0060:
        JMS W0013
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0062
L0061:
; OP = TEXT(POS++);
        JMS W0004
        FIM 0,0D1H
        JMS QV062
        FIM 0,0D1H
        JMS QV064
        FIM 0,0C1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,024H
        FIM 0,041H
        JMS QSTAC
        JUN PRODU
L0065:
        FIM 0,0B1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0C1H
        JMS QLDA
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,L0067
        JMS QV057
        JMS QADD
        JMS W0013
        JUN L0066
L0067:
; ELSE VALUE = VALUE - RIGHT;
        JMS QV057
        JMS QSUB
        JMS W0013
L0066:
L0062:
        JMS W0002
        LD 7
        JCN 0CH,L0068
        JMS QV034
        FIM 0AH,02BH
        JMS QEQ8
        JCN 0CH,L0061
        JMS QV034
        FIM 0AH,02DH
        JMS QEQ8
        JCN 0CH,L0061
L0068:
; RETURN VALUE;
        JMS W0014
        FIM 0,091H
        JUN QRETF
FINDL:
; FINDLINE
; UNSIGNED I;
; I = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,2
        JMS QSTA
; WHILE (I < USED) (
        JUN L0070
L0069:
; IF (TEXT(I) == TARGET) RETURN I;
        FIM 0,2
        JMS QV064
        FIM 0,0F1H
        JMS QLDB
        JMS QEQ
        JCN 4,L0073
        FIM 0,2
        JMS QLDA
        FIM 0,0E1H
        JUN QRETF
L0073:
; I++;
        JMS W0015
; WHILE (TEXT(I)) I++;
        JUN L0075
L0074:
        JMS W0015
L0075:
        JMS QV037
        LD 7
        JCN 0CH,L0074
        LD 6
        JCN 0CH,L0074
; I++;
        JMS W0015
L0070:
        JMS QV050
        JCN 0CH,L0069
; ERROR = 4;
        FIM 4,0
        FIM 6,4
        JMS W0005
; RETURN USED;
        JMS W0016
        FIM 0,0E1H
        JUN QRETF
PRINT:
; PRINTLINE
; UNSIGNED VALUE;
; CHAR CH;
; BLANKS();
        FIM 6,026H
        JMS W0007
        JUN L0014
L0078:
; IF (TEXT(POS) == '"') (
        JMS QV034
        JMS QV065
        JCN 0CH,$+4
        JUN L0080
; POS++;
        JMS QV047
; WHILE (CH && CH != '"') (
        JUN L0082
L0081:
; PUTCHAR(CH);
        FIM 0,032H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS QV047
L0082:
        LD 7
        JCN 0CH,L0086
        LD 6
        JCN 4,L0085
L0086:
        JMS QV065
        JCN 4,L0081
L0085:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0008
        FIM 6,028H
        JMS W0009
        JUN NEED
L0087:
        JUN L0079
L0080:
; VALUE = EXPRESSION();
        FIM 6,02AH
        JMS W0017
        JUN EXPRE
L0088:
        FIM 0,022H
        JMS QSTA
; IF (!ERROR) PRINTF("%U", VALUE);
        JMS W0002
        LD 7
        JCN 0CH,L0089
        FIM 0,022H
        JMS QLDA
        JMS QPRTU
L0089:
L0079:
; BLANKS();
        FIM 6,02CH
        JMS W0007
        JUN L0014
L0090:
; IF (TEXT(POS) == ';') POS++;
        JMS QV034
        FIM 0AH,03BH
        JMS QEQ8
        JCN 4,L0092
        JMS W0003
        JUN L0091
L0092:
; ELSE PUTCHAR(10);
        JMS QV051
L0091:
        FIM 0,012H
        JUN QRETF
BRANC:
; BRANCH
; UNSIGNED LEFT, RIGHT, TARGET;
; CHAR OP, EQUAL, YES;
; BLANKS();
        FIM 6,02EH
        JMS W0007
        JUN L0014
L0093:
; LEFT = EXPRESSION();
        FIM 6,030H
        JMS W0017
        JUN EXPRE
L0094:
        FIM 0,052H
        JMS QSTA
; OP = TEXT(POS);
        JMS QV034
        FIM 0,082H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0002
        LD 7
        JCN 0CH,L0096
        JMS W0018
        LD 7
        JCN 0CH,L0095
        LD 6
        JCN 0CH,L0095
L0096:
        JMS QV035
        FIM 0,042H
        JUN QRETF
L0095:
; POS++;
        JMS W0003
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,092H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS QV058
        JCN 0CH,L0098
        JMS QV066
        JCN 4,L0097
L0098:
        JMS QV034
        FIM 0AH,03DH
        JMS QEQ8
        JCN 4,L0097
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,092H
        JMS QSTAC
; POS++;
        JMS W0003
L0097:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0018
        FIM 0AH,03DH
        JMS QEQ8
        JCN 0CH,L0099
        FIM 0AH,03CH
        JMS QEQ8
        JCN 0CH,L0099
        JMS QV066
        JCN 0CH,L0099
        JMS QV035
L0099:
; RIGHT = EXPRESSION();
        FIM 6,032H
        JMS W0017
        JUN EXPRE
L0100:
        FIM 0,062H
        JMS QSTA
; NEED(':');
        FIM 4,0
        FIM 6,03AH
        JMS W0008
        FIM 6,034H
        JMS W0009
        JUN NEED
L0101:
; BLANKS();
        FIM 6,036H
        JMS W0007
        JUN L0014
L0102:
; TARGET = NUMBER();
        FIM 6,038H
        JMS W0010
        JUN NUMBE
L0103:
        FIM 0,072H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS QV067
        JMS QEQ
        JMS QV068
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS QV058
        JCN 4,L0104
        JMS QV067
        JMS QULT
        JCN 0CH,L0107
        FIM 0,092H
        JMS QLDA
        LD 7
        JCN 4,L0105
        JMS W0022
        LD 7
        JCN 4,L0105
L0107:
        LDM 1
        JUN L0106
L0105:
        LDM 0
L0106:
        JMS QV068
L0104:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0018
        JMS QV066
        JCN 4,L0108
        JMS QV067
        JMS QUGT
        JCN 0CH,L0111
        FIM 0,092H
        JMS QLDA
        LD 7
        JCN 4,L0109
        JMS W0022
        LD 7
        JCN 4,L0109
L0111:
        LDM 1
        JUN L0110
L0109:
        LDM 0
L0110:
        JMS QV068
L0108:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0002
        LD 7
        JCN 4,$+4
        JUN L0112
        JMS W0022
        LD 7
        JCN 4,L0112
        FIM 0,072H
        JMS QV059
        FIM 6,03AH
        FIM 0,0E1H
        JMS QSTAC
        JUN FINDL
L0113:
        JMS W0001
L0112:
        FIM 0,042H
        JUN QRETF
F0012:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,03CH
        JMS W0007
        JUN L0014
L0114:
; CH = TEXT(POS);
        JMS QV034
        FIM 0,0C2H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0115
        LD 6
        JCN 0CH,L0115
        JMS QV035
        FIM 0,0B2H
        JUN QRETF
L0115:
; POS++;
        JMS W0003
; IF (CH == 'P') PRINTLINE();
        FIM 0,0C2H
        JMS QLDA
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0117
        FIM 6,03EH
        FIM 0,012H
        JMS QSTAC
        JUN PRINT
L0118:
        JUN L0116
L0117:
; ELSE IF (CH == 'F') BRANCH();
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0120
        FIM 6,040H
        FIM 0,042H
        JMS QSTAC
        JUN BRANC
L0121:
        JUN L0119
L0120:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0123
; BLANKS();
        FIM 6,042H
        JMS W0007
        JUN L0014
L0124:
; VALUE = NUMBER();
        FIM 6,044H
        JMS W0010
        JUN NUMBE
L0125:
        JMS QV060
        LD 7
        JCN 0CH,L0122
        FIM 0,0E2H
        JMS QV059
        FIM 6,046H
        FIM 0,0E1H
        JMS QSTAC
        JUN FINDL
L0127:
        JMS W0001
L0126:
        JUN L0122
L0123:
; ) ELSE IF (CH == 'L') (
        FIM 0AH,04CH
        JMS QEQ8
        JCN 4,L0129
; BLANKS();
        FIM 6,048H
        JMS W0007
        JUN L0014
L0130:
; VARIABLE = DESTINATION();
        FIM 6,04AH
        FIM 0,0E0H
        JMS QSTAC
        JUN DESTI
L0131:
        FIM 0,0D2H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,04CH
        JMS W0007
        JUN L0014
L0132:
        FIM 4,0
        FIM 6,03DH
        JMS W0008
        FIM 6,04EH
        JMS W0009
        JUN NEED
L0133:
; VALUE = EXPRESSION();
        FIM 6,050H
        JMS W0017
        JUN EXPRE
L0134:
        JMS QV060
        LD 7
        JCN 0CH,L0128
        FIM 0,0D2H
        JMS QLDA
        JMS QV036
        FIM 0,0E2H
        JMS QLDB
        JMS QSTI
L0135:
        JUN L0128
L0129:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0137
; DONE = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,060H
        JMS QSTAC
        JUN L0136
L0137:
; ) ELSE IF (CH == 'R') (
        JMS QV069
        JCN 4,L0139
; WHILE (TEXT(POS)) POS++;
        JUN L0141
L0140:
        JMS W0003
L0141:
        JMS QV034
        LD 7
        JCN 0CH,L0140
        LD 6
        JCN 0CH,L0140
        JUN L0138
L0139:
; ) ELSE ERROR = 1;
        JMS QV035
L0138:
L0136:
L0128:
L0122:
L0119:
L0116:
; BLANKS();
        FIM 6,052H
        JMS W0007
        JUN L0014
L0144:
; IF (TEXT(POS)) ERROR = 1;
        JMS QV034
        LD 7
        JCN 0CH,L0146
        LD 6
        JCN 4,L0145
L0146:
        JMS QV035
L0145:
        FIM 0,0B2H
        JUN QRETF
RNEED:
; RNEED
; IF (GETCHAR() != CH) ERROR = 1;
        JMS QGETC
        FIM 0,3
        JMS QLDB
        JMS QEQ8
        JCN 4,$+4
        JUN L0147
        JMS QV035
L0147:
        FIM 0,0F2H
        JUN QRETF
F0014:
; SAVE
; IF (USED >= SPACE) ERROR = 6;
        JMS W0016
        FIM 8,3
        FIM 0AH,040H
        JMS QUGE
        JCN 4,L0149
        FIM 4,0
        FIM 6,6
        JMS W0005
        JUN L0148
L0149:
; ELSE TEXT(USED++) = CH;
        JMS W0016
        FIM 0,033H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,033H
        JMS QLDA
        JMS QSHL1
        FIM 0,023H
        JMS QLDB
        JMS QSTIC
L0148:
        FIM 0,013H
        JUN QRETF
PACKE:
; PACKEDLINE
; CHAR CH, NEXT, QUOTED;
; IF (COMMAND == 'L') ( RNEED('E'); RNEED('T'); )
        JMS W0023
        FIM 0AH,04CH
        JMS QEQ8
        JCN 4,L0151
        JMS QV042
        FIM 6,054H
        JMS W0025
        JUN RNEED
L0152:
        JMS QV043
        FIM 6,056H
        JMS W0025
        JUN RNEED
L0153:
        JUN L0150
L0151:
; ELSE IF (COMMAND == 'P') ( RNEED('R'); RNEED('I'); RNEED('N'); RNEED('
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0155
        FIM 4,0
        FIM 6,052H
        JMS W0024
        FIM 6,058H
        JMS W0025
        JUN RNEED
L0156:
        FIM 4,0
        FIM 6,049H
        JMS W0024
        FIM 6,05AH
        JMS W0025
        JUN RNEED
L0157:
        JMS QV044
        FIM 6,05CH
        JMS W0025
        JUN RNEED
L0158:
        JMS QV043
        FIM 6,05EH
        JMS W0025
        JUN RNEED
L0159:
        JUN L0154
L0155:
; ELSE IF (COMMAND == 'I') ( RNEED('F'); COMMAND = 'F'; )
        FIM 0AH,049H
        JMS QEQ8
        JCN 4,L0161
        FIM 4,0
        FIM 6,046H
        JMS W0024
        FIM 6,060H
        JMS W0025
        JUN RNEED
L0162:
        FIM 4,0
        FIM 6,046H
        FIM 0,053H
        JMS QSTAC
        JUN L0160
L0161:
; ELSE IF (COMMAND == 'G') ( RNEED('O'); RNEED('T'); RNEED('O'); )
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0164
        JMS QV061
        FIM 6,062H
        JMS W0025
        JUN RNEED
L0165:
        JMS QV043
        FIM 6,064H
        JMS W0025
        JUN RNEED
L0166:
        JMS QV061
        FIM 6,066H
        JMS W0025
        JUN RNEED
L0167:
        JUN L0163
L0164:
; ELSE IF (COMMAND == 'E') ( RNEED('N'); RNEED('D'); )
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0169
        JMS QV044
        FIM 6,068H
        JMS W0025
        JUN RNEED
L0170:
        FIM 4,0
        FIM 6,044H
        JMS W0024
        FIM 6,06AH
        JMS W0025
        JUN RNEED
L0171:
        JUN L0168
L0169:
; ELSE IF (COMMAND == 'R') ( RNEED('E'); RNEED('M'); )
        JMS QV069
        JCN 4,L0173
        JMS QV042
        FIM 6,06CH
        JMS W0025
        JUN RNEED
L0174:
        FIM 4,0
        FIM 6,04DH
        JMS W0024
        FIM 6,06EH
        JMS W0025
        JUN RNEED
L0175:
        JUN L0172
L0173:
; ELSE ERROR = 1;
        JMS QV035
L0172:
L0168:
L0163:
L0160:
L0154:
L0150:
; SAVE(COMMAND);
        JMS W0023
        JMS W0026
        FIM 6,070H
        JMS W0027
        JUN F0014
L0176:
; QUOTED = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,083H
        JMS QSTAC
; CH = GETCHAR();
        JMS QV070
; WHILE (!ERROR && CH != 13 && CH != 10) (
        JUN L0178
L0177:
; IF (!QUOTED && COMMAND == 'F' && CH == 'T') (
        JMS W0029
        LD 7
        JCN 0CH,L0182
        LD 6
        JCN 0CH,L0182
        JMS W0023
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0182
        JMS W0030
        FIM 0AH,054H
        JMS QEQ8
        JCN 4,L0182
; NEXT = GETCHAR();
        JMS QGETC
        FIM 0,073H
        JMS QSTAC
; IF (NEXT == 'H') (
        FIM 0AH,048H
        JMS QEQ8
        JCN 4,L0184
; RNEED('E'); RNEED('N'); SAVE(':');
        JMS QV042
        FIM 6,072H
        JMS W0025
        JUN RNEED
L0185:
        JMS QV044
        FIM 6,074H
        JMS W0025
        JUN RNEED
L0186:
        FIM 4,0
        FIM 6,03AH
        JMS W0026
        FIM 6,076H
        JMS W0027
        JUN F0014
L0187:
; CH = GETCHAR();
        JMS QV070
        JUN L0181
L0184:
; SAVE('T'); CH = NEXT;
        FIM 4,0
        FIM 6,054H
        JMS W0026
        FIM 6,078H
        JMS W0027
        JUN F0014
L0188:
        FIM 0,073H
        JMS QLDA
        JMS W0028
        JUN L0181
L0182:
; IF (!CH ?? (!QUOTED && CH == ':')) ERROR = 1;
        JMS W0030
        LD 7
        JCN 0CH,L0191
        LD 6
        JCN 4,L0190
L0191:
        JMS W0029
        LD 7
        JCN 0CH,L0189
        LD 6
        JCN 0CH,L0189
        JMS W0030
        FIM 0AH,03AH
        JMS QEQ8
        JCN 4,L0189
L0190:
        JMS QV035
L0189:
; IF (CH == '"') QUOTED = 1-QUOTED;
        JMS W0030
        JMS QV065
        JCN 4,L0192
        FIM 4,0
        FIM 6,1
        FIM 0,083H
        JMS QLDB
        JMS QSUB
        FIM 0,083H
        JMS QSTAC
L0192:
; IF (QUOTED ?? CH > ' ') SAVE(CH);
        JMS W0029
        LD 7
        JCN 0CH,L0194
        LD 6
        JCN 0CH,L0194
        JMS W0030
        FIM 0AH,020H
        JMS QLE8
        JCN 2,L0193
L0194:
        JMS W0030
        JMS W0026
        FIM 6,07AH
        JMS W0027
        JUN F0014
L0195:
L0193:
; CH = GETCHAR();
        JMS QV070
L0181:
L0178:
        JMS W0002
        LD 7
        JCN 0CH,L0196
        JMS W0030
        JMS QV071
        JCN 0CH,L0196
        JMS QV072
        JCN 4,L0177
L0196:
; SAVE(0);
        FIM 4,0
        FIM 6,0
        JMS W0026
        FIM 6,07CH
        JMS W0027
        JUN F0014
L0197:
        FIM 0,043H
        JUN QRETF
F0016:
; LOAD
; CHAR CH;
; UNSIGNED LABEL;
; UNSIGNED PREVIOUS;
; PREVIOUS = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0C3H
        JMS QSTA
; WHILE (!ERROR) (
        JUN L0199
L0198:
; CH = GETCHAR();
        JMS QV039
; WHILE (CH == 13 ?? CH == 10 ?? CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0203
L0202:
        JMS QV039
L0203:
        JMS QV071
        JCN 0CH,L0202
        JMS QV072
        JCN 0CH,L0202
        JMS QV045
        JCN 0CH,L0202
        JMS QV046
        JCN 0CH,L0202
; IF (CH == 'R') (
        JMS QV069
        JCN 0CH,$+4
        JUN L0206
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0208
        JMS QGETC
        FIM 0AH,04EH
        JMS QEQ8
        JCN 0CH,L0207
L0208:
        JMS QV035
L0207:
; CH = GETCHAR();
        JMS QV039
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0210
L0209:
        JMS QV039
L0210:
        JMS QV045
        JCN 4,$+4
        JUN L0209
        JMS QV046
        JCN 4,$+4
        JUN L0209
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV071
        JCN 0CH,L0213
        JMS QV072
        JCN 0CH,L0213
        JMS QV035
L0213:
; RETURN;
        FIM 0,093H
        JUN QRETF
L0206:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0B3H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0032
        JMS QV048
        JCN 0AH,L0215
        JMS QV049
        JCN 2,L0217
L0215:
        JMS QV035
L0214:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0217
L0216:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0033
        JMS QV052
        JCN 0CH,L0221
        JMS W0033
        JMS QV053
        JCN 4,L0220
        JMS W0032
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0220
L0221:
        JMS QV054
L0220:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0033
        JMS QSHL1
        JMS QSHL1
        FIM 0,0B3H
        JMS QV055
        FIM 0,0A3H
        JMS QV040
        FIM 0,0B3H
        JMS QSTA
; CH = GETCHAR();
        JMS QV039
L0217:
        JMS W0032
        JMS QV048
        JCN 0AH,L0222
        JMS QV049
        JCN 2,L0216
L0222:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0223
        FIM 0,093H
        JUN QRETF
L0223:
; IF (CH != ' ' && CH != 9) ERROR = 1;
        JMS W0032
        JMS QV045
        JCN 0CH,L0224
        JMS QV046
        JCN 0CH,L0224
        JMS QV035
L0224:
; IF (!LABEL ?? LABEL > 255 ?? LABEL <= PREVIOUS) ERROR = 5;
        JMS W0033
        JMS QTST
        JCN 4,L0226
        FIM 8,0
        FIM 0AH,0FFH
        JMS QUGT
        JCN 0CH,L0226
        JMS W0033
        FIM 0,0C3H
        JMS QLDB
        JMS QULE
        JCN 4,L0225
L0226:
        FIM 4,0
        FIM 6,5
        JMS W0005
L0225:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0229
        FIM 0,093H
        JUN QRETF
L0227:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0229
L0228:
        JMS QV039
L0229:
        JMS W0032
        JMS QV045
        JCN 0CH,L0228
        JMS QV046
        JCN 0CH,L0228
; PREVIOUS = LABEL;
        JMS W0033
        FIM 0,0C3H
        JMS QSTA
; SAVE(LABEL);
        JMS W0033
        JMS W0026
        FIM 6,07EH
        JMS W0027
        JUN F0014
L0232:
; PACKEDLINE(CH);
        JMS W0032
        FIM 0,053H
        JMS QSTAC
        FIM 6,080H
        FIM 0,043H
        JMS QSTAC
        JUN PACKE
L0233:
; COUNT++;
        FIM 0,040H
        JMS QINCC
L0199:
        JMS W0002
        LD 7
        JCN 0CH,$+4
        JUN L0198
        FIM 0,093H
        JUN QRETF
        ORG 07EAH
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
        ORG 0800H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0010
        JUN L0028
        JUN L0031
        JUN L0032
        JUN L0033
        JUN L0036
        JUN L0037
        JUN L0038
        JUN L0041
        JUN L0046
        JUN L0047
        JUN L0048
        JUN L0049
        JUN L0054
        JUN L0060
        JUN L0065
        JUN L0078
        JUN L0087
        JUN L0088
        JUN L0090
        JUN L0093
        JUN L0094
        JUN L0100
        JUN L0101
        JUN L0102
        JUN L0103
        JUN L0113
        JUN L0114
        JUN L0118
        JUN L0121
        JUN L0124
        JUN L0125
        JUN L0127
        JUN L0130
        JUN L0131
        JUN L0132
        JUN L0133
        JUN L0134
        JUN L0144
        JUN L0152
        JUN L0153
        JUN L0156
        JUN L0157
        JUN L0158
        JUN L0159
        JUN L0162
        JUN L0165
        JUN L0166
        JUN L0167
        JUN L0170
        JUN L0171
        JUN L0174
        JUN L0175
        JUN L0176
        JUN L0185
        JUN L0186
        JUN L0187
        JUN L0188
        JUN L0195
        JUN L0197
        JUN L0232
        JUN L0233
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 088AH
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
        ORG 08E8H
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
        ORG 08FDH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0900H
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
        ORG 0955H
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
        ORG 0994H
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
        ORG 09CAH
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
        ORG 09FBH
W0001: FIM 0,030H
        JUN QSTA
        ORG 0A00H
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
        ORG 0A2CH
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
        DB 03FH,045H,052H,052H,04FH,052H,020H,0
        ORG 0A51H
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
        ORG 0A6DH
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
        ORG 0A81H
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
        ORG 0A93H
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
        ORG 0AA4H
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
        ORG 0AB4H
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
        ORG 0AC2H
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
        ORG 0AD0H
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
        ORG 0ADCH
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
        ORG 0AE8H
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
        ORG 0AF4H
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
        ORG 0B00H
QV038:  JMS W0003
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JUN QSUB
        ORG 0B0CH
QV036:  JMS QSHL1
        JMS QSHL1
        FIM 8,6
        FIM 0AH,080H
        JUN QADD
        ORG 0B16H
QV040:  JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JUN QSUB
        ORG 0B20H
QV041:  JMS QV034
        FIM 0,1
        JMS QSTAC
        FIM 0AH,041H
        JUN QGE8
        ORG 0B2AH
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0B32H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0B3AH
QV047:  JMS W0003
        JMS QV037
        FIM 0,032H
        JUN QSTAC
        ORG 0B42H
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0
        ORG 0B49H
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0
        ORG 0B50H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0B56H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0B5CH
QV034:  JMS W0004
        JMS QSHL1
        JUN QLDIC
        ORG 0B62H
QV035:  FIM 4,0
        FIM 6,1
        JUN W0005
        ORG 0B68H
QV042:  FIM 4,0
        FIM 6,045H
        JUN W0024
        ORG 0B6EH
QV043:  FIM 4,0
        FIM 6,054H
        JUN W0024
        ORG 0B74H
QV044:  FIM 4,0
        FIM 6,04EH
        JUN W0024
        ORG 0B7AH
QV050:  FIM 0,010H
        JMS QLDB
        JUN QULT
        ORG 0B80H
QV051:  FIM 4,0
        FIM 6,0AH
        JUN QPUTC
        ORG 0B86H
QV052:  FIM 8,019H
        FIM 0AH,099H
        JUN QUGT
        ORG 0B8CH
QV053:  FIM 8,019H
        FIM 0AH,099H
        JUN QEQ
        ORG 0B92H
QV054:  FIM 4,0
        FIM 6,2
        JUN W0005
        ORG 0B98H
QV055:  JMS QLDB
        JMS QADD
        JUN QSHL1
        ORG 0B9EH
QV056:  JMS W0012
        FIM 0,061H
        JUN QLDB
        ORG 0BA4H
QV057:  JMS W0014
        FIM 0,0B1H
        JUN QLDB
        ORG 0BAAH
QV058:  JMS W0018
        FIM 0AH,03CH
        JUN QEQ8
        ORG 0BB0H
QV059:  JMS QLDA
        FIM 0,0F1H
        JUN QSTA
        ORG 0BB6H
QV060:  FIM 0,0E2H
        JMS QSTA
        JUN W0002
        ORG 0BBCH
QV061:  FIM 4,0
        FIM 6,04FH
        JUN W0024
        ORG 0BC2H
W0002: FIM 0,050H
        JUN QLDA
        ORG 0BC6H
W0003: FIM 0,020H
        JUN QINCV
        ORG 0BCAH
W0004: FIM 0,020H
        JUN QLDA
        ORG 0BCEH
W0005: FIM 0,050H
        JUN QSTAC
        ORG 0BD2H
W0006: FIM 0,0C0H
        JUN QLDA
        ORG 0BD6H
W0007: FIM 0,080H
        JUN QSTAC
        ORG 0BDAH
W0008: FIM 0,0A0H
        JUN QSTAC
        ORG 0BDEH
W0009: FIM 0,090H
        JUN QSTAC
        ORG 0BE2H
W0010: FIM 0,0B0H
        JUN QSTAC
        ORG 0BE6H
W0011: FIM 0,051H
        JUN QSTA
        ORG 0BEAH
W0012: FIM 0,051H
        JUN QLDA
        ORG 0BEEH
W0013: FIM 0,0A1H
        JUN QSTA
        ORG 0BF2H
W0014: FIM 0,0A1H
        JUN QLDA
        ORG 0BF6H
W0015: FIM 0,2
        JUN QINCV
        ORG 0BFAH
W0016: FIM 0,010H
        JUN QLDA
        ORG 0C00H
W0017: FIM 0,091H
        JUN QSTAC
        ORG 0C04H
W0018: FIM 0,082H
        JUN QLDA
        ORG 0C08H
W0019: FIM 0,052H
        JUN QLDA
        ORG 0C0CH
W0020: FIM 0,062H
        JUN QLDB
        ORG 0C10H
W0021: FIM 0,0A2H
        JUN QSTAC
        ORG 0C14H
W0022: FIM 0,0A2H
        JUN QLDA
        ORG 0C18H
W0023: FIM 0,053H
        JUN QLDA
        ORG 0C1CH
W0024: FIM 0,3
        JUN QSTAC
        ORG 0C20H
W0025: FIM 0,0F2H
        JUN QSTAC
        ORG 0C24H
W0026: FIM 0,023H
        JUN QSTAC
        ORG 0C28H
W0027: FIM 0,013H
        JUN QSTAC
        ORG 0C2CH
W0028: FIM 0,063H
        JUN QSTAC
        ORG 0C30H
W0029: FIM 0,083H
        JUN QLDA
        ORG 0C34H
W0030: FIM 0,063H
        JUN QLDA
        ORG 0C38H
W0031: FIM 0,0A3H
        JUN QSTAC
        ORG 0C3CH
W0032: FIM 0,0A3H
        JUN QLDA
        ORG 0C40H
W0033: FIM 0,0B3H
        JUN QLDA
        ORG 0C44H
QV037:  JMS QSHL1
        JUN QLDIC
        ORG 0C48H
QV039:  JMS QGETC
        JUN W0031
        ORG 0C4CH
QV045:  FIM 0AH,020H
        JUN QEQ8
        ORG 0C50H
QV046:  FIM 0AH,9
        JUN QEQ8
        ORG 0C54H
QV048:  FIM 0AH,030H
        JUN QGE8
        ORG 0C58H
QV049:  FIM 0AH,039H
        JUN QLE8
        ORG 0C5CH
QV062:  JMS QSTA
        JUN W0003
        ORG 0C60H
QV063:  FIM 0AH,05AH
        JUN QLE8
        ORG 0C64H
QV064:  JMS QLDA
        JUN QV037
        ORG 0C68H
QV065:  FIM 0AH,022H
        JUN QEQ8
        ORG 0C6CH
QV066:  FIM 0AH,03EH
        JUN QEQ8
        ORG 0C70H
QV067:  JMS W0019
        JUN W0020
        ORG 0C74H
QV068:  JMS QBOOL
        JUN W0021
        ORG 0C78H
QV069:  FIM 0AH,052H
        JUN QEQ8
        ORG 0C7CH
QV070:  JMS QGETC
        JUN W0028
        ORG 0C80H
QV071:  FIM 0AH,0DH
        JUN QEQ8
        ORG 0C84H
QV072:  FIM 0AH,0AH
        JUN QEQ8
        END
