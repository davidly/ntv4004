; BASIC: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 8
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; PUTS("BASIC4");
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
        FIM 0,080H
        JMS QSTAC
; DO (
L0001:
; ERROR = 0; DONE = 0;
        FIM 4,0
        FIM 6,0
        JMS W0001
        JMS QV076
; IF (INTERACTIVE) PUTS("READY (UPPERCASE)");
        JMS W0003
        LD 7
        JCN 4,L0004
        FIM 0,S0002 AND 0FFH
        JMS QS1
L0004:
; LOAD();
        FIM 6,4
        FIM 0,034H
        JMS QSTAC
        JUN L0256
L0005:
; IF (QUITTING) RETURN 0;
        FIM 0,040H
        JMS QLDA
        LD 7
        JCN 4,L0006
        FIM 4,0
        FIM 6,0
        JUN QEXIT
L0006:
; IF (INTERACTIVE && !ERROR) CLEARVARS();
        JMS W0003
        LD 7
        JCN 4,L0007
        JMS W0004
        LD 7
        JCN 0CH,L0007
        FIM 6,6
        FIM 0,0B3H
        JMS QSTAC
        JUN CLEAR
L0008:
L0007:
; LINE = 0;
        FIM 4,0
        FIM 6,0
        JMS W0005
; RUNPROGRAM();
        FIM 6,8
        FIM 0,053H
        JMS QSTAC
        JUN L0194
L0009:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0004
        LD 7
        JCN 4,L0010
        FIM 0,S0003 AND 0FFH
        JMS QS1
        JMS W0004
        JMS QPRTU
        JMS QV061
L0010:
        JMS W0003
        LD 7
        JCN 0CH,L0001
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
BLANK:
; BLANKS
; WHILE (TEXT(POS) == ' ' ?? TEXT(POS) == 9) POS++;
        JUN L0012
L0011:
        JMS W0006
L0012:
        JMS QV040
        JMS QV054
        JCN 0CH,L0011
        JMS QV040
        JMS QV058
        JCN 0CH,L0011
        FIM 0,0A0H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS QV040
        FIM 0,0C0H
        JMS QLDB
        JMS QEQ8
        JCN 0CH,L0016
        JMS QV041
        JUN L0015
L0016:
; ELSE POS++;
        JMS W0006
L0015:
        FIM 0,0B0H
        JUN QRETF
NUMBE:
; NUMBER
; UNSIGNED VALUE;
; CHAR CH;
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JMS QSTA
; CH = TEXT(POS);
        JMS QV040
        FIM 0,0F0H
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV055
        JCN 0AH,L0018
        JMS QV059
        JCN 2,L0020
L0018:
        JMS QV041
L0017:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0020
L0019:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0008
        JMS QV062
        JCN 0CH,L0024
        JMS W0008
        JMS QV063
        JCN 4,L0023
        FIM 0,0F0H
        JMS QLDA
        JMS QV088
        JCN 2,L0023
L0024:
        JMS QV064
L0023:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0008
        JMS QV089
        FIM 0,0E0H
        JMS QV065
        FIM 0,0F0H
        JMS QV046
        FIM 0,0E0H
        JMS QV090
; CH = TEXT(POS);
        JMS QV051
        FIM 0,0F0H
        JMS QSTAC
L0020:
        FIM 0,0F0H
        JMS QLDA
        JMS QV055
        JCN 0AH,L0025
        JMS QV059
        JCN 2,L0019
L0025:
; RETURN VALUE;
        JMS W0008
        FIM 0,0D0H
        JUN QRETF
DESTI:
; DESTINATION
; UNSIGNED INDEX;
; CHAR CH;
; CH = TEXT(POS);
        JMS QV060
        JCN 2,$+4
        JUN L0026
        JMS QV071
        JCN 2,$+4
        JUN L0026
; POS++;
        JMS QV077
        FIM 0,1
        JUN QRETF
L0026:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        JMS QEQ8
        JCN 0CH,L0027
        JMS QV041
        FIM 4,0
        FIM 6,0
        FIM 0,1
        JUN QRETF
L0027:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0006
        FIM 6,0AH
        JMS W0009
        JUN L0012
L0028:
        FIM 4,0
        FIM 6,028H
        JMS W0010
        FIM 6,0CH
        JMS W0011
        JUN NEED
L0029:
        FIM 6,0EH
        JMS W0009
        JUN L0012
L0030:
; CH = TEXT(POS);
        JMS QV060
        JCN 0AH,L0032
        JMS QV071
        JCN 0AH,L0032
        JMS QV077
        JMS QV042
        JMS QLDI
        FIM 0,011H
        JMS QSTA
        JUN L0031
L0032:
; ELSE INDEX = NUMBER();
        FIM 6,010H
        JMS W0012
        JUN NUMBE
L0033:
        FIM 0,011H
        JMS QSTA
L0031:
; BLANKS(); NEED(')');
        FIM 6,012H
        JMS W0009
        JUN L0012
L0034:
        FIM 4,0
        FIM 6,029H
        JMS W0010
        FIM 6,014H
        JMS W0011
        JUN NEED
L0035:
; IF (ERROR) RETURN 0;
        JMS W0004
        LD 7
        JCN 4,L0036
        FIM 4,0
        FIM 6,0
        FIM 0,1
        JUN QRETF
L0036:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,011H
        JMS QLDA
        FIM 8,0
        FIM 0AH,0C8H
        JMS QUGE
        JCN 4,L0037
        FIM 4,0
        FIM 6,7
        JMS W0001
        FIM 4,0
        FIM 6,0
        FIM 0,1
        JUN QRETF
L0037:
; RETURN INDEX+26;
        FIM 0,011H
        JMS QLDA
        FIM 8,0
        FIM 0AH,01AH
        JMS QADD
        FIM 0,1
        JUN QRETF
ATOM:
; ATOM
; UNSIGNED VALUE;
; CHAR CH;
; BLANKS();
        FIM 6,016H
        JMS W0009
        JUN L0012
L0038:
; CH = TEXT(POS);
        JMS QV040
        FIM 0,051H
        JMS QSTAC
; IF (CH >= 'A' && CH <= 'Z') ( POS++; VALUE = VARS(CH-'A'); )
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0040
        JMS QV071
        JCN 0AH,L0040
        JMS W0006
        FIM 0,051H
        JMS QV053
        JMS QV078
        JUN L0039
L0040:
; ELSE IF (CH == '@') (
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,L0042
; VALUE = VARS(DESTINATION());
        FIM 6,018H
        JMS W0014
        JUN DESTI
L0043:
        JMS QV078
        JUN L0041
L0042:
; ELSE VALUE = NUMBER();
        FIM 6,01AH
        JMS W0012
        JUN NUMBE
L0044:
        JMS W0013
L0041:
L0039:
; BLANKS();
        FIM 6,01CH
        JMS W0009
        JUN L0012
L0045:
; RETURN VALUE;
        FIM 0,041H
        JMS QLDA
        FIM 0,031H
        JUN QRETF
PRODU:
; PRODUCT
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = ATOM();
        FIM 6,01EH
        FIM 0,031H
        JMS QSTAC
        JUN ATOM
L0046:
        JMS W0015
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0048
L0047:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,0A1H
        JMS QV090
        FIM 0,0A1H
        JMS QLDA
        JMS QV051
        FIM 0,091H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,020H
        FIM 0,031H
        JMS QSTAC
        JUN ATOM
L0051:
        FIM 0,081H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,091H
        JMS QLDA
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,L0053
        JMS QV079
        JMS QMUL
        JMS W0015
        JUN L0052
L0053:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,081H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0055
        FIM 4,0
        FIM 6,3
        JMS W0001
        JUN L0054
L0055:
; ELSE VALUE = VALUE / RIGHT;
        JMS QV079
        JMS QUDIV
        JMS W0015
L0054:
L0052:
L0048:
        JMS W0004
        LD 7
        JCN 0CH,L0056
        JMS QV040
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,$+4
        JUN L0047
        JMS QV040
        FIM 0AH,02FH
        JMS QEQ8
        JCN 4,$+4
        JUN L0047
L0056:
; RETURN VALUE;
        JMS W0016
        FIM 0,061H
        JUN QRETF
EXPRE:
; EXPRESSION
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = PRODUCT();
        FIM 6,022H
        FIM 0,061H
        JMS QSTAC
        JUN PRODU
L0057:
        JMS W0017
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0059
L0058:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,0F1H
        JMS QV090
        FIM 0,0F1H
        JMS QLDA
        JMS QV051
        FIM 0,0E1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,024H
        FIM 0,061H
        JMS QSTAC
        JUN PRODU
L0062:
        FIM 0,0D1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0E1H
        JMS QLDA
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,L0064
        JMS QV080
        JMS QADD
        JMS W0017
        JUN L0063
L0064:
; ELSE VALUE = VALUE - RIGHT;
        JMS QV080
        JMS QSUB
        JMS W0017
L0063:
L0059:
        JMS W0004
        LD 7
        JCN 0CH,L0065
        JMS QV040
        FIM 0AH,02BH
        JMS QEQ8
        JCN 0CH,L0058
        JMS QV040
        FIM 0AH,02DH
        JMS QEQ8
        JCN 0CH,L0058
L0065:
; RETURN VALUE;
        JMS W0018
        FIM 0,0B1H
        JUN QRETF
FINDL:
; FINDLINE
; CHAR I;
; I = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,022H
        JMS QSTAC
; WHILE (I < COUNT && LABELS(I) != TARGET) I++;
        JUN L0067
L0066:
        FIM 0,022H
        JMS QINCC
L0067:
        JMS QV091
        JCN 2,L0070
        JMS QV092
        FIM 0,012H
        JMS QLDB
        JMS QNE
        JCN 0CH,L0066
L0070:
; IF (I == COUNT) ERROR = 4;
        FIM 0,022H
        JMS QLDA
        JMS W0019
        JMS QEQ8
        JCN 4,L0071
        FIM 4,0
        FIM 6,4
        JMS W0001
L0071:
; RETURN I;
        FIM 0,022H
        JMS QLDA
        FIM 0,2
        JUN QRETF
PRINT:
; PRINTLINE
; UNSIGNED VALUE;
; CHAR CH;
; NEED('R'); NEED('I'); NEED('N'); NEED('T');
        FIM 4,0
        FIM 6,052H
        JMS W0010
        FIM 6,026H
        JMS W0011
        JUN NEED
L0072:
        JMS QV081
        FIM 6,028H
        JMS W0011
        JUN NEED
L0073:
        JMS QV048
        FIM 6,02AH
        JMS W0011
        JUN NEED
L0074:
        JMS QV044
        FIM 6,02CH
        JMS W0011
        JUN NEED
L0075:
; BLANKS();
        FIM 6,02EH
        JMS W0009
        JUN L0012
L0076:
; IF (TEXT(POS) == '"') (
        JMS QV040
        FIM 0AH,022H
        JMS QEQ8
        JCN 4,L0078
; POS++;
        JMS QV068
; WHILE (CH && CH != '"') (
        JUN L0080
L0079:
; PUTCHAR(CH);
        FIM 0,052H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS QV068
L0080:
        LD 7
        JCN 0CH,L0084
        LD 6
        JCN 4,L0083
L0084:
        FIM 0AH,022H
        JMS QEQ8
        JCN 4,L0079
L0083:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0010
        FIM 6,030H
        JMS W0011
        JUN NEED
L0085:
        JUN L0077
L0078:
; VALUE = EXPRESSION();
        FIM 6,032H
        JMS W0020
        JUN EXPRE
L0086:
        FIM 0,042H
        JMS QV072
        LD 7
        JCN 0CH,L0087
        FIM 0,042H
        JMS QLDA
        JMS QPRTU
L0087:
L0077:
; BLANKS();
        FIM 6,034H
        JMS W0009
        JUN L0012
L0088:
; IF (TEXT(POS) == ';') POS++;
        JMS QV040
        FIM 0AH,03BH
        JMS QEQ8
        JCN 4,L0090
        JMS W0006
        JUN L0089
L0090:
; ELSE PUTCHAR(10);
        JMS QV061
L0089:
        FIM 0,032H
        JUN QRETF
INPUT:
; INPUTVAR
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; NEED('N'); NEED('P'); NEED('U'); NEED('T'); BLANKS();
        JMS QV048
        FIM 6,036H
        JMS W0011
        JUN NEED
L0091:
        FIM 4,0
        FIM 6,050H
        JMS W0010
        FIM 6,038H
        JMS W0011
        JUN NEED
L0092:
        JMS QV082
        FIM 6,03AH
        JMS W0011
        JUN NEED
L0093:
        JMS QV044
        FIM 6,03CH
        JMS W0011
        JUN NEED
L0094:
        FIM 6,03EH
        JMS W0009
        JUN L0012
L0095:
; VARIABLE = DESTINATION();
        FIM 6,040H
        JMS W0014
        JUN DESTI
L0096:
        FIM 0,082H
        JMS QV072
        LD 7
        JCN 4,$+4
        JUN L0097
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,092H
        JMS QSTA
; PUTCHAR('?'); PUTCHAR(' ');
        FIM 4,0
        FIM 6,03FH
        JMS QPUTC
        JMS QV083
; CH = GETCHAR();
        JMS QV067
; WHILE (CH <= ' ') CH = GETCHAR();
        JUN L0099
L0098:
        JMS QV067
L0099:
        FIM 0AH,020H
        JMS QLE8
        JCN 2,L0098
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV055
        JCN 0AH,L0103
        JMS QV059
        JCN 2,L0105
L0103:
        JMS QV041
L0102:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0105
L0104:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0022
        JMS QV062
        JCN 0CH,L0109
        JMS W0022
        JMS QV063
        JCN 4,L0108
        JMS W0023
        JMS QV088
        JCN 2,L0108
L0109:
        JMS QV064
L0108:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0022
        JMS QV089
        FIM 0,092H
        JMS QV065
        FIM 0,072H
        JMS QV046
        FIM 0,092H
        JMS QSTA
; CH = GETCHAR();
        JMS QV067
L0105:
        JMS W0023
        JMS QV055
        JCN 0AH,L0112
        JMS QV059
        JCN 2,L0104
L0110:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0112
L0111:
        JMS QV067
L0112:
        JMS QV054
        JCN 0CH,L0111
        JMS QV058
        JCN 0CH,L0111
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV056
        JCN 0CH,L0115
        JMS QV057
        JCN 0CH,L0115
        JMS QV041
L0115:
; IF (!ERROR) (
        JMS W0004
        LD 7
        JCN 0CH,L0116
; VARS(VARIABLE) = VALUE;
        FIM 0,082H
        JMS QV093
        FIM 0,092H
        JMS QV073
L0116:
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 4,L0117
        JUN L0119
L0118:
        JMS QV067
L0119:
        JMS W0023
        JMS QV056
        JCN 0CH,L0122
        JMS QV057
        JCN 4,L0118
L0122:
L0117:
L0097:
        FIM 0,062H
        JUN QRETF
BRANC:
; BRANCH
; UNSIGNED LEFT, RIGHT, TARGET;
; CHAR OP, EQUAL, YES;
; NEED('F');
        FIM 4,0
        FIM 6,046H
        JMS W0010
        FIM 6,042H
        JMS W0011
        JUN NEED
L0123:
; BLANKS();
        FIM 6,044H
        JMS W0009
        JUN L0012
L0124:
; LEFT = EXPRESSION();
        FIM 6,046H
        JMS W0020
        JUN EXPRE
L0125:
        FIM 0,0B2H
        JMS QSTA
; OP = TEXT(POS);
        JMS QV040
        FIM 0,0E2H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0004
        LD 7
        JCN 0CH,L0127
        JMS W0024
        LD 7
        JCN 0CH,L0126
        LD 6
        JCN 0CH,L0126
L0127:
        JMS QV041
        FIM 0,0A2H
        JUN QRETF
L0126:
; POS++;
        JMS W0006
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0F2H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS QV084
        JCN 0CH,L0129
        JMS QV094
        JCN 4,L0128
L0129:
        JMS QV040
        FIM 0AH,03DH
        JMS QEQ8
        JCN 4,L0128
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,0F2H
        JMS QSTAC
; POS++;
        JMS W0006
L0128:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0024
        FIM 0AH,03DH
        JMS QEQ8
        JCN 0CH,L0130
        FIM 0AH,03CH
        JMS QEQ8
        JCN 0CH,L0130
        JMS QV094
        JCN 0CH,L0130
        JMS QV041
L0130:
; RIGHT = EXPRESSION();
        FIM 6,048H
        JMS W0020
        JUN EXPRE
L0131:
        FIM 0,0C2H
        JMS QSTA
; NEED('T'); NEED('H'); NEED('E'); NEED('N');
        JMS QV044
        FIM 6,04AH
        JMS W0011
        JUN NEED
L0132:
        FIM 4,0
        FIM 6,048H
        JMS W0010
        FIM 6,04CH
        JMS W0011
        JUN NEED
L0133:
        JMS QV049
        FIM 6,04EH
        JMS W0011
        JUN NEED
L0134:
        JMS QV048
        FIM 6,050H
        JMS W0011
        JUN NEED
L0135:
; BLANKS();
        FIM 6,052H
        JMS W0009
        JUN L0012
L0136:
; TARGET = NUMBER();
        FIM 6,054H
        JMS W0012
        JUN NUMBE
L0137:
        FIM 0,0D2H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS QV095
        JMS QEQ
        JMS QV096
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS QV084
        JCN 4,L0138
        JMS QV095
        JMS QULT
        JCN 0CH,L0141
        FIM 0,0F2H
        JMS QLDA
        LD 7
        JCN 4,L0139
        JMS W0028
        LD 7
        JCN 4,L0139
L0141:
        LDM 1
        JUN L0140
L0139:
        LDM 0
L0140:
        JMS QV096
L0138:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0024
        JMS QV094
        JCN 0CH,$+4
        JUN L0142
        JMS QV095
        JMS QUGT
        JCN 4,$+4
        JUN L0145
        FIM 0,0F2H
        JMS QLDA
        LD 7
        JCN 4,L0143
        JMS W0028
        LD 7
        JCN 4,L0143
L0145:
        LDM 1
        JUN L0144
L0143:
        LDM 0
L0144:
        JMS QV096
L0142:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0004
        LD 7
        JCN 0CH,L0146
        JMS W0028
        LD 7
        JCN 4,L0146
        FIM 0,0D2H
        JMS QV085
        FIM 6,056H
        FIM 0,2
        JMS QSTAC
        JUN FINDL
L0147:
        JMS W0005
L0146:
        FIM 0,0A2H
        JUN QRETF
F0013:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,058H
        JMS W0009
        JUN L0012
L0148:
; CH = TEXT(POS);
        JMS QV040
        FIM 0,023H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0149
        LD 6
        JCN 0CH,L0149
        JMS QV041
        FIM 0,013H
        JUN QRETF
L0149:
; POS++;
        JMS W0006
; IF (CH == 'P') PRINTLINE();
        FIM 0,023H
        JMS QLDA
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0151
        FIM 6,05AH
        FIM 0,032H
        JMS QSTAC
        JUN PRINT
L0152:
        JUN L0150
L0151:
; ELSE IF (CH == 'I' && TEXT(POS) == 'F') BRANCH();
        JMS QV097
        JCN 4,L0154
        JMS QV040
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0154
        FIM 6,05CH
        FIM 0,0A2H
        JMS QSTAC
        JUN BRANC
L0155:
        JUN L0153
L0154:
; ELSE IF (CH == 'I') INPUTVAR();
        FIM 0,023H
        JMS QLDA
        JMS QV097
        JCN 4,L0157
        FIM 6,05EH
        FIM 0,062H
        JMS QSTAC
        JUN INPUT
L0158:
        JUN L0156
L0157:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0160
; NEED('O'); NEED('T'); NEED('O');
        JMS QV086
        FIM 6,060H
        JMS W0011
        JUN NEED
L0161:
        JMS QV044
        FIM 6,062H
        JMS W0011
        JUN NEED
L0162:
        JMS QV086
        FIM 6,064H
        JMS W0011
        JUN NEED
L0163:
; BLANKS();
        FIM 6,066H
        JMS W0009
        JUN L0012
L0164:
; VALUE = NUMBER();
        FIM 6,068H
        JMS W0012
        JUN NUMBE
L0165:
        FIM 0,043H
        JMS QV072
        LD 7
        JCN 0CH,L0166
        FIM 0,043H
        JMS QV085
        FIM 6,06AH
        FIM 0,2
        JMS QSTAC
        JUN FINDL
L0167:
        JMS W0005
L0166:
        JUN L0159
L0160:
; ) ELSE IF (CH == 'L') (
        JMS QV098
        JCN 0CH,$+4
        JUN L0169
; NEED('E'); NEED('T');
        JMS QV049
        FIM 6,06CH
        JMS W0011
        JUN NEED
L0170:
        JMS QV044
        FIM 6,06EH
        JMS W0011
        JUN NEED
L0171:
; BLANKS();
        FIM 6,070H
        JMS W0009
        JUN L0012
L0172:
; VARIABLE = DESTINATION();
        FIM 6,072H
        JMS W0014
        JUN DESTI
L0173:
        FIM 0,033H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,074H
        JMS W0009
        JUN L0012
L0174:
        FIM 4,0
        FIM 6,03DH
        JMS W0010
        FIM 6,076H
        JMS W0011
        JUN NEED
L0175:
; VALUE = EXPRESSION();
        FIM 6,078H
        JMS W0020
        JUN EXPRE
L0176:
        FIM 0,043H
        JMS QV072
        LD 7
        JCN 0CH,L0168
; VARS(VARIABLE) = VALUE;
        FIM 0,033H
        JMS QV093
        FIM 0,043H
        JMS QV073
L0177:
        JUN L0168
L0169:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0179
; NEED('N'); NEED('D');
        JMS QV048
        FIM 6,07AH
        JMS W0011
        JUN NEED
L0180:
        FIM 4,0
        FIM 6,044H
        JMS W0010
        FIM 6,07CH
        JMS W0011
        JUN NEED
L0181:
; DONE = 1;
        FIM 4,0
        FIM 6,1
        JMS W0002
        JUN L0178
L0179:
; ) ELSE IF (CH == 'R') (
        JMS QV074
        JCN 4,L0183
; NEED('E'); NEED('M');
        JMS QV049
        FIM 6,07EH
        JMS W0011
        JUN NEED
L0184:
        FIM 4,0
        FIM 6,04DH
        JMS W0010
        FIM 6,080H
        JMS W0011
        JUN NEED
L0185:
; WHILE (TEXT(POS)) POS++;
        JUN L0187
L0186:
        JMS W0006
L0187:
        JMS QV040
        LD 7
        JCN 0CH,L0186
        LD 6
        JCN 0CH,L0186
        JUN L0182
L0183:
; ) ELSE ERROR = 1;
        JMS QV041
L0182:
L0178:
L0168:
L0159:
L0156:
L0153:
L0150:
; BLANKS();
        FIM 6,082H
        JMS W0009
        JUN L0012
L0190:
; IF (TEXT(POS)) ERROR = 1;
        JMS QV040
        LD 7
        JCN 0CH,L0192
        LD 6
        JCN 4,L0191
L0192:
        JMS QV041
L0191:
        FIM 0,013H
        JUN QRETF
RUNPR:
; RUNPROGRAM
; WHILE (!ERROR && !DONE && LINE < COUNT) (
        JUN L0194
L0193:
; POS = OFFSETS(LINE++);
        FIM 0,030H
        JMS QLDA
        FIM 0,063H
        JMS QSTA
        FIM 0,030H
        JMS QINCC
        FIM 0,063H
        JMS QV069
; STATEMENT();
        FIM 6,084H
        FIM 0,013H
        JMS QSTAC
        JUN F0013
L0197:
L0194:
        JMS W0004
        LD 7
        JCN 0CH,L0198
        FIM 0,070H
        JMS QLDA
        LD 7
        JCN 0CH,L0198
        FIM 0,030H
        JMS QLDA
        JMS QV091
        JCN 0AH,L0193
L0198:
        FIM 0,053H
        JUN QRETF
F0015:
; SWAPLINE
; CHAR I, CH;
; FOR (I = 0; I < 48; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,083H
        JMS QSTAC
        JUN L0200
L0199:
; CH = COMMAND(I); COMMAND(I) = TEXT(I); TEXT(I) = CH;
        JMS W0030
        JMS QV045
        JMS QLDIC
        FIM 0,093H
        JMS QSTAC
        JMS W0030
        JMS QV051
        FIM 0,0A3H
        JMS QSTA
        JMS W0030
        JMS QV045
        FIM 0,0A3H
        JMS QV075
        JMS W0030
        JMS QSHL1
        FIM 0,093H
        JMS QV075
        FIM 0,083H
        JMS QINCC
L0200:
        JMS QV055
        JCN 0AH,L0199
        FIM 0,073H
        JUN QRETF
CLEAR:
; CLEARVARS
; UNSIGNED I;
; FOR (I = 0; I < 26+CELLS; I++) VARS(I) = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0C3H
        JMS QSTA
        JUN L0204
L0203:
        FIM 0,0C3H
        JMS QV093
        FIM 8,0
        FIM 0AH,0
        JMS QSTI
        FIM 0,0C3H
        JMS QINCV
L0204:
        FIM 8,0
        FIM 0AH,0E2H
        JMS QULT
        JCN 4,$+4
        JUN L0203
        FIM 0,0B3H
        JUN QRETF
CONSO:
; CONSOLELINE
; CHAR LENGTH, I, ACTION;
; LENGTH = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0F3H
        JMS QSTAC
; WHILE (CH != 13 && CH != 10) (
        JUN L0208
L0207:
; IF (LENGTH < 47) COMMAND(LENGTH++) = CH;
        FIM 0,0F3H
        JMS QLDA
        FIM 0AH,02FH
        JMS QGE8
        JCN 2,L0212
        JMS W0031
        FIM 0,0F3H
        JMS QINCC
        JMS W0032
        JMS QV045
        FIM 0,0E3H
        JMS QV075
        JUN L0211
L0212:
; ELSE ERROR = 6;
        JMS QV066
L0211:
; CH = GETCHAR();
        JMS QGETC
        JMS W0033
L0208:
        JMS W0034
        JMS QV056
        JCN 0CH,L0213
        JMS QV057
        JCN 4,L0207
L0213:
; COMMAND(LENGTH) = 0;
        FIM 0,0F3H
        JMS QLDA
        JMS QV045
        JMS QV087
; IF (ERROR) RETURN 0;
        JMS W0004
        LD 7
        JCN 4,L0214
        FIM 4,0
        FIM 6,0
        FIM 0,0D3H
        JUN QRETF
L0214:
; SWAPLINE();
        FIM 6,086H
        FIM 0,073H
        JMS QSTAC
        JUN F0015
L0215:
; POS = 0; CH = TEXT(POS++); ACTION = CH;
        FIM 4,0
        FIM 6,0
        JMS W0029
        JMS QV070
        JMS W0033
        FIM 0,014H
        JMS QSTAC
; IF (CH == 'R' && TEXT(POS) == 'U') ( NEED('U'); NEED('N'); )
        JMS W0034
        JMS QV074
        JCN 4,L0217
        JMS QV040
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0217
        JMS QV082
        FIM 6,088H
        JMS W0011
        JUN NEED
L0218:
        JMS QV048
        FIM 6,08AH
        JMS W0011
        JUN NEED
L0219:
        JUN L0216
L0217:
; ELSE IF (CH == 'N') ( NEED('E'); NEED('W'); )
        JMS W0034
        JMS QV099
        JCN 4,L0221
        JMS QV049
        FIM 6,08CH
        JMS W0011
        JUN NEED
L0222:
        FIM 4,0
        FIM 6,057H
        JMS W0010
        FIM 6,08EH
        JMS W0011
        JUN NEED
L0223:
        JUN L0220
L0221:
; ELSE IF (CH == 'B') ( NEED('Y'); NEED('E'); )
        FIM 0AH,042H
        JMS QEQ8
        JCN 4,L0225
        FIM 4,0
        FIM 6,059H
        JMS W0010
        FIM 6,090H
        JMS W0011
        JUN NEED
L0226:
        JMS QV049
        FIM 6,092H
        JMS W0011
        JUN NEED
L0227:
        JUN L0224
L0225:
; ELSE IF (CH == 'L' && TEXT(POS) == 'I') ( NEED('I'); NEED('S'); NEED('
        JMS QV098
        JCN 4,L0229
        JMS QV040
        JMS QV097
        JCN 4,L0229
        JMS QV081
        FIM 6,094H
        JMS W0011
        JUN NEED
L0230:
        FIM 4,0
        FIM 6,053H
        JMS W0010
        FIM 6,096H
        JMS W0011
        JUN NEED
L0231:
        JMS QV044
        FIM 6,098H
        JMS W0011
        JUN NEED
L0232:
        JUN L0228
L0229:
; POS--; ACTION = 0; LINE = COUNT;
        FIM 0,020H
        JMS QDECV
        FIM 4,0
        FIM 6,0
        FIM 0,014H
        JMS QSTAC
        JMS W0035
        JMS W0005
; STATEMENT();
        FIM 6,09AH
        FIM 0,013H
        JMS QSTAC
        JUN F0013
L0233:
L0228:
L0224:
L0220:
L0216:
; BLANKS(); IF (TEXT(POS)) ERROR = 1;
        FIM 6,09CH
        JMS W0009
        JUN L0012
L0234:
        JMS QV040
        LD 7
        JCN 0CH,L0236
        LD 6
        JCN 4,L0235
L0236:
        JMS QV041
L0235:
; SWAPLINE();
        FIM 6,09EH
        FIM 0,073H
        JMS QSTAC
        JUN F0015
L0237:
; IF (!ERROR) (
        JMS W0004
        LD 7
        JCN 0CH,L0238
; IF (ACTION == 'R') RETURN 1;
        FIM 0,014H
        JMS QLDA
        JMS QV074
        JCN 4,L0239
        FIM 4,0
        FIM 6,1
        FIM 0,0D3H
        JUN QRETF
L0239:
; IF (ACTION == 'B') ( QUITTING = 1; RETURN 1; )
        FIM 0AH,042H
        JMS QEQ8
        JCN 4,L0240
        FIM 4,0
        FIM 6,1
        FIM 0,040H
        JMS QSTAC
        FIM 4,0
        FIM 6,1
        FIM 0,0D3H
        JUN QRETF
L0240:
; IF (ACTION == 'N') ( USED = 0; COUNT = 0; CLEARVARS(); )
        JMS QV099
        JCN 4,L0242
        FIM 4,0
        FIM 6,0
        FIM 0,010H
        JMS QSTA
        FIM 4,0
        FIM 6,0
        FIM 0,050H
        JMS QSTAC
        FIM 6,0A0H
        FIM 0,0B3H
        JMS QSTAC
        JUN CLEAR
L0243:
        JUN L0241
L0242:
; ELSE IF (ACTION == 'L') (
        JMS QV098
        JCN 4,L0245
; FOR (I = 0; I < COUNT; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,4
        JMS QSTAC
        JUN L0247
L0246:
; PRINTF("%U ", LABELS(I)); POS = OFFSETS(I);
        FIM 0,4
        JMS QLDA
        JMS QV092
        JMS QPRTU
        JMS QV083
        FIM 0,4
        JMS QV069
; WHILE (TEXT(POS)) PUTCHAR(TEXT(POS++));
        JUN L0251
L0250:
        JMS W0007
        JMS QV070
        JMS QPUTC
L0251:
        JMS QV040
        LD 7
        JCN 0CH,L0250
        LD 6
        JCN 0CH,L0250
; PUTCHAR(10);
        JMS QV061
        FIM 0,4
        JMS QINCC
L0247:
        JMS QV091
        JCN 0AH,L0246
        JUN L0244
L0245:
; ) ELSE RUNPROGRAM();
        FIM 6,0A2H
        FIM 0,053H
        JMS QSTAC
        JUN L0194
L0254:
L0244:
L0241:
L0238:
; RETURN 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0D3H
        JUN QRETF
F0018:
; LOAD
; CHAR CH;
; UNSIGNED LABEL, MARK;
; WHILE (!ERROR) (
        JUN L0256
L0255:
; DONE = 0; MARK = USED;
        JMS QV076
        JMS W0036
        FIM 0,064H
        JMS QSTA
; DO (
L0259:
; IF (INTERACTIVE) PRINTF("> ");
        JMS W0003
        LD 7
        JCN 4,L0262
        FIM 0,S0004 AND 0FFH
        JMS QS1
L0262:
; CH = GETCHAR();
        JMS QV052
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0264
L0263:
        JMS QV052
L0264:
        JMS QV054
        JCN 0CH,L0263
        JMS QV058
        JCN 0CH,L0263
        JMS QV056
        JCN 0CH,L0259
        JMS QV057
        JCN 0CH,L0259
; IF (INTERACTIVE && CH >= 'A' && CH <= 'Z') (
        JMS W0003
        LD 7
        JCN 4,L0267
        JMS W0038
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0267
        JMS QV071
        JCN 0AH,L0267
; IF (CONSOLELINE(CH)) RETURN;
        JMS W0033
        FIM 6,0A4H
        FIM 0,0D3H
        JMS QSTAC
        JUN CONSO
L0269:
        LD 7
        JCN 4,L0268
        FIM 0,034H
        JUN QRETF
L0268:
; CONTINUE;
        JUN L0257
L0267:
; IF (CH == 'R') (
        JMS W0038
        JMS QV074
        JCN 0CH,$+4
        JUN L0270
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0272
        JMS QGETC
        JMS QV099
        JCN 0CH,L0271
L0272:
        JMS QV041
L0271:
; CH = GETCHAR();
        JMS QV052
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0274
L0273:
        JMS QV052
L0274:
        JMS QV054
        JCN 4,$+4
        JUN L0273
        JMS QV058
        JCN 4,$+4
        JUN L0273
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV056
        JCN 0CH,L0277
        JMS QV057
        JCN 0CH,L0277
        JMS QV041
L0277:
; RETURN;
        FIM 0,034H
        JUN QRETF
L0270:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,054H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0038
        JMS QV055
        JCN 0AH,L0279
        JMS QV059
        JCN 2,L0281
L0279:
        JMS QV041
L0278:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0281
L0280:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0039
        JMS QV062
        JCN 0CH,L0285
        JMS W0039
        JMS QV063
        JCN 4,L0284
        JMS W0038
        JMS QV088
        JCN 2,L0284
L0285:
        JMS QV064
L0284:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0039
        JMS QV089
        FIM 0,054H
        JMS QV065
        FIM 0,044H
        JMS QV046
        FIM 0,054H
        JMS QSTA
; CH = GETCHAR();
        JMS QV052
L0281:
        JMS W0038
        JMS QV055
        JCN 0AH,L0286
        JMS QV059
        JCN 2,L0280
L0286:
; IF (!ERROR && CH != ' ' && CH != 9) ERROR = 1;
        JMS W0004
        LD 7
        JCN 0CH,L0287
        JMS W0038
        JMS QV054
        JCN 0CH,L0287
        JMS QV058
        JCN 0CH,L0287
        JMS QV041
L0287:
; IF (!ERROR && (!LABEL ?? COUNT == LINES ?? (COUNT && LABEL <= LABELS(C
        JMS W0004
        LD 7
        JCN 0CH,L0288
        JMS W0039
        JMS QTST
        JCN 4,L0289
        JMS W0035
        JMS QV054
        JCN 0CH,L0289
        LD 7
        JCN 0CH,L0290
        LD 6
        JCN 4,L0288
L0290:
        JMS QDEC
        JMS QV092
        JMS QXAB
        JMS W0039
        JMS QULE
        JCN 4,L0288
L0289:
        FIM 4,0
        FIM 6,5
        JMS W0001
L0288:
; IF (ERROR) (
        JMS W0004
        LD 7
        JCN 4,L0299
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 4,L0292
        JUN L0294
L0293:
        JMS QV052
L0294:
        JMS W0038
        JMS QV056
        JCN 0CH,L0297
        JMS QV057
        JCN 4,L0293
L0297:
L0292:
; RETURN;
        FIM 0,034H
        JUN QRETF
L0291:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0299
L0298:
        JMS QV052
L0299:
        JMS W0038
        JMS QV054
        JCN 0CH,L0298
        JMS QV058
        JCN 0CH,L0298
; LABELS(COUNT) = LABEL;
        JMS W0035
        JMS QV043
        FIM 0,054H
        JMS QV073
; OFFSETS(COUNT) = USED;
        JMS W0035
        JMS QV047
        FIM 0,010H
        JMS QV073
; WHILE (CH != 13 && CH != 10) (
        JUN L0303
L0302:
; IF (USED >= SPACE-1) ERROR = 6;
        JMS W0036
        FIM 8,1
        FIM 0AH,07FH
        JMS QUGE
        JCN 4,L0307
        JMS QV066
        JUN L0306
L0307:
; ELSE TEXT(USED++) = CH;
        JMS QV050
        FIM 0,044H
        JMS QV075
L0306:
; CH = GETCHAR();
        JMS QV052
L0303:
        JMS W0038
        JMS QV056
        JCN 0CH,L0308
        JMS QV057
        JCN 0CH,$+4
        JUN L0302
L0308:
; IF (USED >= SPACE) ERROR = 6;
        JMS W0036
        FIM 8,1
        FIM 0AH,080H
        JMS QUGE
        JCN 4,L0309
        JMS QV066
L0309:
; IF (ERROR) ( USED = MARK; RETURN; )
        JMS W0004
        LD 7
        JCN 4,L0310
        FIM 0,064H
        JMS QLDA
        FIM 0,010H
        JMS QSTA
        FIM 0,034H
        JUN QRETF
L0310:
; TEXT(USED++) = 0;
        JMS QV050
        JMS QV087
; COUNT++;
        FIM 0,050H
        JMS QINCC
L0257:
L0256:
        JMS W0004
        LD 7
        JCN 0CH,$+4
        JUN L0255
        FIM 0,034H
        JUN QRETF
        ORG 0A3CH
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
        ORG 0A9AH
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
        ORG 0AEFH
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
        ORG 0B00H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0005
        JUN L0008
        JUN L0009
        JUN L0028
        JUN L0029
        JUN L0030
        JUN L0033
        JUN L0034
        JUN L0035
        JUN L0038
        JUN L0043
        JUN L0044
        JUN L0045
        JUN L0046
        JUN L0051
        JUN L0057
        JUN L0062
        JUN L0072
        JUN L0073
        JUN L0074
        JUN L0075
        JUN L0076
        JUN L0085
        JUN L0086
        JUN L0088
        JUN L0091
        JUN L0092
        JUN L0093
        JUN L0094
        JUN L0095
        JUN L0096
        JUN L0123
        JUN L0124
        JUN L0125
        JUN L0131
        JUN L0132
        JUN L0133
        JUN L0134
        JUN L0135
        JUN L0136
        JUN L0137
        JUN L0147
        JUN L0148
        JUN L0152
        JUN L0155
        JUN L0158
        JUN L0161
        JUN L0162
        JUN L0163
        JUN L0164
        JUN L0165
        JUN L0167
        JUN L0170
        JUN L0171
        JUN L0172
        JUN L0173
        JUN L0174
        JUN L0175
        JUN L0176
        JUN L0180
        JUN L0181
        JUN L0184
        JUN L0185
        JUN L0190
        JUN L0197
        JUN L0215
        JUN L0218
        JUN L0219
        JUN L0222
        JUN L0223
        JUN L0226
        JUN L0227
        JUN L0230
        JUN L0231
        JUN L0232
        JUN L0233
        JUN L0234
        JUN L0237
        JUN L0243
        JUN L0254
        JUN L0269
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0BAEH
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
        ORG 0BEDH
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
        ORG 0C00H
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
        DB 042H,041H,053H,049H,043H,034H,0AH,0
S0002:
        DB 052H,045H,041H,044H,059H,020H,028H,055H,050H,050H,045H,052H
        DB 043H,041H,053H,045H,029H,0AH,0
S0003:
        DB 03FH,045H,052H,052H,04FH,052H,020H,0
S0004:
        DB 03EH,020H,0
        ORG 0C3AH
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
        ORG 0C70H
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
        ORG 0CA1H
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
        ORG 0CCDH
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
        ORG 0CE9H
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
        ORG 0D00H
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
        ORG 0D15H
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
        ORG 0D29H
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
        ORG 0D3BH
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
        ORG 0D4BH
QV050:  JMS W0036
        FIM 0,074H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,074H
        JMS QLDA
        JUN QSHL1
        ORG 0D5BH
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
        ORG 0D69H
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
        ORG 0D77H
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
        ORG 0D84H
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
        ORG 0D90H
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
        ORG 0D9CH
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
        ORG 0DA8H
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
        ORG 0DB4H
QV042:  JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JUN QADD
        ORG 0DBEH
QV043:  JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,0
        JUN QADD
        ORG 0DC8H
QV046:  JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JUN QSUB
        ORG 0DD2H
QV047:  JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,080H
        JUN QADD
        ORG 0DDCH
QV060:  JMS QV040
        FIM 0,021H
        JMS QSTAC
        FIM 0AH,041H
        JUN QGE8
        ORG 0DE6H
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0DEEH
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0DF6H
QV045:  JMS QSHL1
        FIM 8,7
        FIM 0AH,088H
        JUN QADD
        ORG 0DFEH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0E00H
QV053:  JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JUN QSUB
        ORG 0E08H
QV068:  JMS W0006
        JMS QV051
        FIM 0,052H
        JUN QSTAC
        ORG 0E10H
QV069:  JMS QLDA
        JMS QV047
        JMS QLDI
        JUN W0029
        ORG 0E18H
QV070:  JMS W0031
        JMS W0006
        JMS W0032
        JUN QV051
        ORG 0E20H
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0
        ORG 0E27H
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0
        ORG 0E2EH
; DECREMENT THE INT AT R0R1, LEAVING IT IN A.
QDECV:  JMS QLDA
        JMS QDEC
        JUN QSTA
        ORG 0E34H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0E3AH
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0E40H
QV040:  JMS W0007
        JMS QSHL1
        JUN QLDIC
        ORG 0E46H
QV041:  FIM 4,0
        FIM 6,1
        JUN W0001
        ORG 0E4CH
QV044:  FIM 4,0
        FIM 6,054H
        JUN W0010
        ORG 0E52H
QV048:  FIM 4,0
        FIM 6,04EH
        JUN W0010
        ORG 0E58H
QV049:  FIM 4,0
        FIM 6,045H
        JUN W0010
        ORG 0E5EH
QV061:  FIM 4,0
        FIM 6,0AH
        JUN QPUTC
        ORG 0E64H
QV062:  FIM 8,019H
        FIM 0AH,099H
        JUN QUGT
        ORG 0E6AH
QV063:  FIM 8,019H
        FIM 0AH,099H
        JUN QEQ
        ORG 0E70H
QV064:  FIM 4,0
        FIM 6,2
        JUN W0001
        ORG 0E76H
QV065:  JMS QLDB
        JMS QADD
        JUN QSHL1
        ORG 0E7CH
QV066:  FIM 4,0
        FIM 6,6
        JUN W0001
        ORG 0E82H
QV076:  FIM 4,0
        FIM 6,0
        JUN W0002
        ORG 0E88H
QV077:  JMS W0006
        FIM 0,021H
        JUN QV053
        ORG 0E8EH
QV078:  JMS QV042
        JMS QLDI
        JUN W0013
        ORG 0E94H
QV079:  JMS W0016
        FIM 0,081H
        JUN QLDB
        ORG 0E9AH
QV080:  JMS W0018
        FIM 0,0D1H
        JUN QLDB
        ORG 0EA0H
QV081:  FIM 4,0
        FIM 6,049H
        JUN W0010
        ORG 0EA6H
QV082:  FIM 4,0
        FIM 6,055H
        JUN W0010
        ORG 0EACH
QV083:  FIM 4,0
        FIM 6,020H
        JUN QPUTC
        ORG 0EB2H
QV084:  JMS W0024
        FIM 0AH,03CH
        JUN QEQ8
        ORG 0EB8H
QV085:  JMS QLDA
        FIM 0,012H
        JUN QSTA
        ORG 0EBEH
QV086:  FIM 4,0
        FIM 6,04FH
        JUN W0010
        ORG 0EC4H
QV087:  FIM 8,0
        FIM 0AH,0
        JUN QSTIC
        ORG 0ECAH
W0001: FIM 0,060H
        JUN QSTAC
        ORG 0ECEH
W0002: FIM 0,070H
        JUN QSTAC
        ORG 0ED2H
W0003: FIM 0,080H
        JUN QLDA
        ORG 0ED6H
W0004: FIM 0,060H
        JUN QLDA
        ORG 0EDAH
W0005: FIM 0,030H
        JUN QSTAC
        ORG 0EDEH
W0006: FIM 0,020H
        JUN QINCV
        ORG 0EE2H
W0007: FIM 0,020H
        JUN QLDA
        ORG 0EE6H
W0008: FIM 0,0E0H
        JUN QLDA
        ORG 0EEAH
W0009: FIM 0,0A0H
        JUN QSTAC
        ORG 0EEEH
W0010: FIM 0,0C0H
        JUN QSTAC
        ORG 0EF2H
W0011: FIM 0,0B0H
        JUN QSTAC
        ORG 0EF6H
W0012: FIM 0,0D0H
        JUN QSTAC
        ORG 0EFAH
W0013: FIM 0,041H
        JUN QSTA
        ORG 0F00H
W0014: FIM 0,1
        JUN QSTAC
        ORG 0F04H
W0015: FIM 0,071H
        JUN QSTA
        ORG 0F08H
W0016: FIM 0,071H
        JUN QLDA
        ORG 0F0CH
W0017: FIM 0,0C1H
        JUN QSTA
        ORG 0F10H
W0018: FIM 0,0C1H
        JUN QLDA
        ORG 0F14H
W0019: FIM 0,050H
        JUN QLDB
        ORG 0F18H
W0020: FIM 0,0B1H
        JUN QSTAC
        ORG 0F1CH
W0021: FIM 0,072H
        JUN QSTAC
        ORG 0F20H
W0022: FIM 0,092H
        JUN QLDA
        ORG 0F24H
W0023: FIM 0,072H
        JUN QLDA
        ORG 0F28H
W0024: FIM 0,0E2H
        JUN QLDA
        ORG 0F2CH
W0025: FIM 0,0B2H
        JUN QLDA
        ORG 0F30H
W0026: FIM 0,0C2H
        JUN QLDB
        ORG 0F34H
W0027: FIM 0,3
        JUN QSTAC
        ORG 0F38H
W0028: FIM 0,3
        JUN QLDA
        ORG 0F3CH
W0029: FIM 0,020H
        JUN QSTA
        ORG 0F40H
W0030: FIM 0,083H
        JUN QLDA
        ORG 0F44H
W0031: FIM 0,024H
        JUN QSTA
        ORG 0F48H
W0032: FIM 0,024H
        JUN QLDA
        ORG 0F4CH
W0033: FIM 0,0E3H
        JUN QSTAC
        ORG 0F50H
W0034: FIM 0,0E3H
        JUN QLDA
        ORG 0F54H
W0035: FIM 0,050H
        JUN QLDA
        ORG 0F58H
W0036: FIM 0,010H
        JUN QLDA
        ORG 0F5CH
W0037: FIM 0,044H
        JUN QSTAC
        ORG 0F60H
W0038: FIM 0,044H
        JUN QLDA
        ORG 0F64H
W0039: FIM 0,054H
        JUN QLDA
        ORG 0F68H
QV051:  JMS QSHL1
        JUN QLDIC
        ORG 0F6CH
QV052:  JMS QGETC
        JUN W0037
        ORG 0F70H
QV054:  FIM 0AH,020H
        JUN QEQ8
        ORG 0F74H
QV055:  FIM 0AH,030H
        JUN QGE8
        ORG 0F78H
QV056:  FIM 0AH,0DH
        JUN QEQ8
        ORG 0F7CH
QV057:  FIM 0AH,0AH
        JUN QEQ8
        ORG 0F80H
QV058:  FIM 0AH,9
        JUN QEQ8
        ORG 0F84H
QV059:  FIM 0AH,039H
        JUN QLE8
        ORG 0F88H
QV067:  JMS QGETC
        JUN W0021
        ORG 0F8CH
QV071:  FIM 0AH,05AH
        JUN QLE8
        ORG 0F90H
QV072:  JMS QSTA
        JUN W0004
        ORG 0F94H
QV073:  JMS QLDB
        JUN QSTI
        ORG 0F98H
QV074:  FIM 0AH,052H
        JUN QEQ8
        ORG 0F9CH
QV075:  JMS QLDB
        JUN QSTIC
        ORG 0FA0H
QV088:  FIM 0AH,035H
        JUN QLE8
        ORG 0FA4H
QV089:  JMS QSHL1
        JUN QSHL1
        ORG 0FA8H
QV090:  JMS QSTA
        JUN W0006
        ORG 0FACH
QV091:  JMS W0019
        JUN QGE8
        ORG 0FB0H
QV092:  JMS QV043
        JUN QLDI
        ORG 0FB4H
QV093:  JMS QLDA
        JUN QV042
        ORG 0FB8H
QV094:  FIM 0AH,03EH
        JUN QEQ8
        ORG 0FBCH
QV095:  JMS W0025
        JUN W0026
        ORG 0FC0H
QV096:  JMS QBOOL
        JUN W0027
        ORG 0FC4H
QV097:  FIM 0AH,049H
        JUN QEQ8
        ORG 0FC8H
QV098:  FIM 0AH,04CH
        JUN QEQ8
        ORG 0FCCH
QV099:  FIM 0AH,04EH
        JUN QEQ8
        END
