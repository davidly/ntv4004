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
        JMS QV075
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
        JUN L0257
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
        JUN L0195
L0009:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0004
        LD 7
        JCN 4,L0010
        FIM 0,S0003 AND 0FFH
        JMS QS1
        JMS W0004
        JMS QPRTU
        JMS QV060
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
        JMS QV039
        JMS QV052
        JCN 0CH,L0011
        JMS QV039
        JMS QV057
        JCN 0CH,L0011
        FIM 0,0A0H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS QV039
        FIM 0,0C0H
        JMS QLDB
        JMS QEQ8
        JCN 0CH,L0016
        JMS QV040
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
        JMS QV039
        FIM 0,0F0H
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV053
        JCN 0AH,L0018
        JMS QV058
        JCN 2,L0020
L0018:
        JMS QV040
L0017:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0020
L0019:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0008
        JMS QV061
        JCN 0CH,L0024
        JMS W0008
        JMS QV062
        JCN 4,L0023
        FIM 0,0F0H
        JMS QLDA
        JMS QV085
        JCN 2,L0023
L0024:
        JMS QV063
L0023:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0008
        JMS QV086
        FIM 0,0E0H
        JMS QV064
        FIM 0,0F0H
        JMS QV045
        FIM 0,0E0H
        JMS QV087
; CH = TEXT(POS);
        JMS QV050
        FIM 0,0F0H
        JMS QSTAC
L0020:
        FIM 0,0F0H
        JMS QLDA
        JMS QV053
        JCN 0AH,L0025
        JMS QV058
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
; BLANKS();
        FIM 6,0AH
        JMS W0009
        JUN L0012
L0026:
; CH = TEXT(POS);
        JMS QV059
        JCN 0AH,L0027
        JMS QV070
        JCN 0AH,L0027
        JMS QV056
        FIM 0,1
        JUN QRETF
L0027:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        JMS QEQ8
        JCN 0CH,L0028
        JMS QV040
        FIM 4,0
        FIM 6,0
        FIM 0,1
        JUN QRETF
L0028:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0006
        FIM 6,0CH
        JMS W0009
        JUN L0012
L0029:
        FIM 4,0
        FIM 6,028H
        JMS W0010
        FIM 6,0EH
        JMS W0011
        JUN NEED
L0030:
        FIM 6,010H
        JMS W0009
        JUN L0012
L0031:
; CH = TEXT(POS);
        JMS QV059
        JCN 0AH,L0033
        JMS QV070
        JCN 0AH,L0033
        JMS QV056
        JMS QV041
        JMS QLDI
        FIM 0,011H
        JMS QSTA
        JUN L0032
L0033:
; ELSE INDEX = NUMBER();
        FIM 6,012H
        JMS W0012
        JUN NUMBE
L0034:
        FIM 0,011H
        JMS QSTA
L0032:
; BLANKS(); NEED(')');
        FIM 6,014H
        JMS W0009
        JUN L0012
L0035:
        FIM 4,0
        FIM 6,029H
        JMS W0010
        FIM 6,016H
        JMS W0011
        JUN NEED
L0036:
; IF (ERROR) RETURN 0;
        JMS W0004
        LD 7
        JCN 4,L0037
        FIM 4,0
        FIM 6,0
        FIM 0,1
        JUN QRETF
L0037:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,011H
        JMS QLDA
        FIM 8,0
        FIM 0AH,0C8H
        JMS QUGE
        JCN 4,L0038
        FIM 4,0
        FIM 6,7
        JMS W0001
        FIM 4,0
        FIM 6,0
        FIM 0,1
        JUN QRETF
L0038:
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
        FIM 6,018H
        JMS W0009
        JUN L0012
L0039:
; CH = TEXT(POS);
        JMS QV039
        FIM 0,051H
        JMS QSTAC
; IF ((CH >= 'A' && CH <= 'Z') ?? CH == '@') VALUE = VARS(DESTINATION())
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0043
        JMS QV070
        JCN 2,L0042
L0043:
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,L0041
L0042:
        FIM 6,01AH
        JMS W0013
        JUN DESTI
L0044:
        JMS QV041
        JMS QLDI
        FIM 0,041H
        JMS QSTA
        JUN L0040
L0041:
; ELSE VALUE = NUMBER();
        FIM 6,01CH
        JMS W0012
        JUN NUMBE
L0045:
        FIM 0,041H
        JMS QSTA
L0040:
; BLANKS();
        FIM 6,01EH
        JMS W0009
        JUN L0012
L0046:
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
        FIM 6,020H
        FIM 0,031H
        JMS QSTAC
        JUN ATOM
L0047:
        JMS W0014
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0049
L0048:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,0A1H
        JMS QV087
        FIM 0,0A1H
        JMS QLDA
        JMS QV050
        FIM 0,091H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,022H
        FIM 0,031H
        JMS QSTAC
        JUN ATOM
L0052:
        FIM 0,081H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,091H
        JMS QLDA
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,L0054
        JMS QV076
        JMS QMUL
        JMS W0014
        JUN L0053
L0054:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,081H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0056
        FIM 4,0
        FIM 6,3
        JMS W0001
        JUN L0055
L0056:
; ELSE VALUE = VALUE / RIGHT;
        JMS QV076
        JMS QUDIV
        JMS W0014
L0055:
L0053:
L0049:
        JMS W0004
        LD 7
        JCN 0CH,L0057
        JMS QV039
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,$+4
        JUN L0048
        JMS QV039
        FIM 0AH,02FH
        JMS QEQ8
        JCN 4,$+4
        JUN L0048
L0057:
; RETURN VALUE;
        JMS W0015
        FIM 0,061H
        JUN QRETF
EXPRE:
; EXPRESSION
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = PRODUCT();
        FIM 6,024H
        FIM 0,061H
        JMS QSTAC
        JUN PRODU
L0058:
        JMS W0016
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0060
L0059:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,0F1H
        JMS QV087
        FIM 0,0F1H
        JMS QLDA
        JMS QV050
        FIM 0,0E1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,026H
        FIM 0,061H
        JMS QSTAC
        JUN PRODU
L0063:
        FIM 0,0D1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0E1H
        JMS QLDA
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,L0065
        JMS QV077
        JMS QADD
        JMS W0016
        JUN L0064
L0065:
; ELSE VALUE = VALUE - RIGHT;
        JMS QV077
        JMS QSUB
        JMS W0016
L0064:
L0060:
        JMS W0004
        LD 7
        JCN 0CH,L0066
        JMS QV039
        FIM 0AH,02BH
        JMS QEQ8
        JCN 0CH,L0059
        JMS QV039
        FIM 0AH,02DH
        JMS QEQ8
        JCN 0CH,L0059
L0066:
; RETURN VALUE;
        JMS W0017
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
        JUN L0068
L0067:
        FIM 0,022H
        JMS QINCC
L0068:
        JMS QV088
        JCN 2,L0071
        JMS QV089
        FIM 0,012H
        JMS QLDB
        JMS QNE
        JCN 0CH,L0067
L0071:
; IF (I == COUNT) ERROR = 4;
        FIM 0,022H
        JMS QLDA
        JMS W0018
        JMS QEQ8
        JCN 4,L0072
        FIM 4,0
        FIM 6,4
        JMS W0001
L0072:
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
        FIM 6,028H
        JMS W0011
        JUN NEED
L0073:
        JMS QV078
        FIM 6,02AH
        JMS W0011
        JUN NEED
L0074:
        JMS QV047
        FIM 6,02CH
        JMS W0011
        JUN NEED
L0075:
        JMS QV043
        FIM 6,02EH
        JMS W0011
        JUN NEED
L0076:
; BLANKS();
        FIM 6,030H
        JMS W0009
        JUN L0012
L0077:
; IF (TEXT(POS) == '"') (
        JMS QV039
        FIM 0AH,022H
        JMS QEQ8
        JCN 4,L0079
; POS++;
        JMS QV067
; WHILE (CH && CH != '"') (
        JUN L0081
L0080:
; PUTCHAR(CH);
        FIM 0,052H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS QV067
L0081:
        LD 7
        JCN 0CH,L0085
        LD 6
        JCN 4,L0084
L0085:
        FIM 0AH,022H
        JMS QEQ8
        JCN 4,L0080
L0084:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0010
        FIM 6,032H
        JMS W0011
        JUN NEED
L0086:
        JUN L0078
L0079:
; VALUE = EXPRESSION();
        FIM 6,034H
        JMS W0019
        JUN EXPRE
L0087:
        FIM 0,042H
        JMS QV071
        LD 7
        JCN 0CH,L0088
        FIM 0,042H
        JMS QLDA
        JMS QPRTU
L0088:
L0078:
; BLANKS();
        FIM 6,036H
        JMS W0009
        JUN L0012
L0089:
; IF (TEXT(POS) == ';') POS++;
        JMS QV039
        FIM 0AH,03BH
        JMS QEQ8
        JCN 4,L0091
        JMS W0006
        JUN L0090
L0091:
; ELSE PUTCHAR(10);
        JMS QV060
L0090:
        FIM 0,032H
        JUN QRETF
INPUT:
; INPUTVAR
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; NEED('N'); NEED('P'); NEED('U'); NEED('T'); BLANKS();
        JMS QV047
        FIM 6,038H
        JMS W0011
        JUN NEED
L0092:
        FIM 4,0
        FIM 6,050H
        JMS W0010
        FIM 6,03AH
        JMS W0011
        JUN NEED
L0093:
        JMS QV079
        FIM 6,03CH
        JMS W0011
        JUN NEED
L0094:
        JMS QV043
        FIM 6,03EH
        JMS W0011
        JUN NEED
L0095:
        FIM 6,040H
        JMS W0009
        JUN L0012
L0096:
; VARIABLE = DESTINATION();
        FIM 6,042H
        JMS W0013
        JUN DESTI
L0097:
        FIM 0,082H
        JMS QV071
        LD 7
        JCN 4,$+4
        JUN L0098
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,092H
        JMS QSTA
; PUTCHAR('?'); PUTCHAR(' ');
        FIM 4,0
        FIM 6,03FH
        JMS QPUTC
        JMS QV080
; CH = GETCHAR();
        JMS QV066
; WHILE (CH <= ' ') CH = GETCHAR();
        JUN L0100
L0099:
        JMS QV066
L0100:
        FIM 0AH,020H
        JMS QLE8
        JCN 2,L0099
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV053
        JCN 0AH,L0104
        JMS QV058
        JCN 2,L0106
L0104:
        JMS QV040
L0103:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0106
L0105:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0021
        JMS QV061
        JCN 0CH,L0110
        JMS W0021
        JMS QV062
        JCN 4,L0109
        JMS W0022
        JMS QV085
        JCN 2,L0109
L0110:
        JMS QV063
L0109:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0021
        JMS QV086
        FIM 0,092H
        JMS QV064
        FIM 0,072H
        JMS QV045
        FIM 0,092H
        JMS QSTA
; CH = GETCHAR();
        JMS QV066
L0106:
        JMS W0022
        JMS QV053
        JCN 0AH,L0113
        JMS QV058
        JCN 2,L0105
L0111:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0113
L0112:
        JMS QV066
L0113:
        JMS QV052
        JCN 0CH,L0112
        JMS QV057
        JCN 0CH,L0112
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV054
        JCN 4,$+4
        JUN L0116
        JMS QV055
        JCN 4,$+4
        JUN L0116
        JMS QV040
L0116:
; IF (!ERROR) VARS(VARIABLE) = VALUE;
        JMS W0004
        LD 7
        JCN 0CH,L0117
        FIM 0,082H
        JMS QV090
        FIM 0,092H
        JMS QV072
L0117:
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 4,L0118
        JUN L0120
L0119:
        JMS QV066
L0120:
        JMS W0022
        JMS QV054
        JCN 0CH,L0123
        JMS QV055
        JCN 4,L0119
L0123:
L0118:
L0098:
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
        FIM 6,044H
        JMS W0011
        JUN NEED
L0124:
; BLANKS();
        FIM 6,046H
        JMS W0009
        JUN L0012
L0125:
; LEFT = EXPRESSION();
        FIM 6,048H
        JMS W0019
        JUN EXPRE
L0126:
        FIM 0,0B2H
        JMS QSTA
; OP = TEXT(POS);
        JMS QV039
        FIM 0,0E2H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0004
        LD 7
        JCN 0CH,L0128
        JMS W0023
        LD 7
        JCN 0CH,L0127
        LD 6
        JCN 0CH,L0127
L0128:
        JMS QV040
        FIM 0,0A2H
        JUN QRETF
L0127:
; POS++;
        JMS W0006
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0F2H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS QV081
        JCN 0CH,L0130
        JMS QV091
        JCN 4,L0129
L0130:
        JMS QV039
        FIM 0AH,03DH
        JMS QEQ8
        JCN 4,L0129
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,0F2H
        JMS QSTAC
; POS++;
        JMS W0006
L0129:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0023
        FIM 0AH,03DH
        JMS QEQ8
        JCN 0CH,L0131
        FIM 0AH,03CH
        JMS QEQ8
        JCN 0CH,L0131
        JMS QV091
        JCN 0CH,L0131
        JMS QV040
L0131:
; RIGHT = EXPRESSION();
        FIM 6,04AH
        JMS W0019
        JUN EXPRE
L0132:
        FIM 0,0C2H
        JMS QSTA
; NEED('T'); NEED('H'); NEED('E'); NEED('N');
        JMS QV043
        FIM 6,04CH
        JMS W0011
        JUN NEED
L0133:
        FIM 4,0
        FIM 6,048H
        JMS W0010
        FIM 6,04EH
        JMS W0011
        JUN NEED
L0134:
        JMS QV048
        FIM 6,050H
        JMS W0011
        JUN NEED
L0135:
        JMS QV047
        FIM 6,052H
        JMS W0011
        JUN NEED
L0136:
; BLANKS();
        FIM 6,054H
        JMS W0009
        JUN L0012
L0137:
; TARGET = NUMBER();
        FIM 6,056H
        JMS W0012
        JUN NUMBE
L0138:
        FIM 0,0D2H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS QV092
        JMS QEQ
        JMS QV093
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS QV081
        JCN 4,L0139
        JMS QV092
        JMS QULT
        JCN 0CH,L0142
        FIM 0,0F2H
        JMS QLDA
        LD 7
        JCN 4,L0140
        JMS W0027
        LD 7
        JCN 4,L0140
L0142:
        LDM 1
        JUN L0141
L0140:
        LDM 0
L0141:
        JMS QV093
L0139:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0023
        JMS QV091
        JCN 0CH,$+4
        JUN L0143
        JMS QV092
        JMS QUGT
        JCN 4,$+4
        JUN L0146
        FIM 0,0F2H
        JMS QLDA
        LD 7
        JCN 4,L0144
        JMS W0027
        LD 7
        JCN 4,L0144
L0146:
        LDM 1
        JUN L0145
L0144:
        LDM 0
L0145:
        JMS QV093
L0143:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0004
        LD 7
        JCN 0CH,L0147
        JMS W0027
        LD 7
        JCN 4,L0147
        FIM 0,0D2H
        JMS QV082
        FIM 6,058H
        FIM 0,2
        JMS QSTAC
        JUN FINDL
L0148:
        JMS W0005
L0147:
        FIM 0,0A2H
        JUN QRETF
F0013:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,05AH
        JMS W0009
        JUN L0012
L0149:
; CH = TEXT(POS);
        JMS QV039
        FIM 0,023H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0150
        LD 6
        JCN 0CH,L0150
        JMS QV040
        FIM 0,013H
        JUN QRETF
L0150:
; POS++;
        JMS W0006
; IF (CH == 'P') PRINTLINE();
        FIM 0,023H
        JMS QLDA
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0152
        FIM 6,05CH
        FIM 0,032H
        JMS QSTAC
        JUN PRINT
L0153:
        JUN L0151
L0152:
; ELSE IF (CH == 'I' && TEXT(POS) == 'F') BRANCH();
        JMS QV094
        JCN 4,L0155
        JMS QV039
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0155
        FIM 6,05EH
        FIM 0,0A2H
        JMS QSTAC
        JUN BRANC
L0156:
        JUN L0154
L0155:
; ELSE IF (CH == 'I') INPUTVAR();
        FIM 0,023H
        JMS QLDA
        JMS QV094
        JCN 4,L0158
        FIM 6,060H
        FIM 0,062H
        JMS QSTAC
        JUN INPUT
L0159:
        JUN L0157
L0158:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0161
; NEED('O'); NEED('T'); NEED('O');
        JMS QV083
        FIM 6,062H
        JMS W0011
        JUN NEED
L0162:
        JMS QV043
        FIM 6,064H
        JMS W0011
        JUN NEED
L0163:
        JMS QV083
        FIM 6,066H
        JMS W0011
        JUN NEED
L0164:
; BLANKS();
        FIM 6,068H
        JMS W0009
        JUN L0012
L0165:
; VALUE = NUMBER();
        FIM 6,06AH
        JMS W0012
        JUN NUMBE
L0166:
        FIM 0,043H
        JMS QV071
        LD 7
        JCN 0CH,L0167
        FIM 0,043H
        JMS QV082
        FIM 6,06CH
        FIM 0,2
        JMS QSTAC
        JUN FINDL
L0168:
        JMS W0005
L0167:
        JUN L0160
L0161:
; ) ELSE IF (CH == 'L') (
        JMS QV095
        JCN 0CH,$+4
        JUN L0170
; NEED('E'); NEED('T');
        JMS QV048
        FIM 6,06EH
        JMS W0011
        JUN NEED
L0171:
        JMS QV043
        FIM 6,070H
        JMS W0011
        JUN NEED
L0172:
; BLANKS();
        FIM 6,072H
        JMS W0009
        JUN L0012
L0173:
; VARIABLE = DESTINATION();
        FIM 6,074H
        JMS W0013
        JUN DESTI
L0174:
        FIM 0,033H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,076H
        JMS W0009
        JUN L0012
L0175:
        FIM 4,0
        FIM 6,03DH
        JMS W0010
        FIM 6,078H
        JMS W0011
        JUN NEED
L0176:
; VALUE = EXPRESSION();
        FIM 6,07AH
        JMS W0019
        JUN EXPRE
L0177:
        FIM 0,043H
        JMS QV071
        LD 7
        JCN 0CH,L0169
        FIM 0,033H
        JMS QV090
        FIM 0,043H
        JMS QV072
L0178:
        JUN L0169
L0170:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0180
; NEED('N'); NEED('D');
        JMS QV047
        FIM 6,07CH
        JMS W0011
        JUN NEED
L0181:
        FIM 4,0
        FIM 6,044H
        JMS W0010
        FIM 6,07EH
        JMS W0011
        JUN NEED
L0182:
; DONE = 1;
        FIM 4,0
        FIM 6,1
        JMS W0002
        JUN L0179
L0180:
; ) ELSE IF (CH == 'R') (
        JMS QV073
        JCN 4,L0184
; NEED('E'); NEED('M');
        JMS QV048
        FIM 6,080H
        JMS W0011
        JUN NEED
L0185:
        FIM 4,0
        FIM 6,04DH
        JMS W0010
        FIM 6,082H
        JMS W0011
        JUN NEED
L0186:
; WHILE (TEXT(POS)) POS++;
        JUN L0188
L0187:
        JMS W0006
L0188:
        JMS QV039
        LD 7
        JCN 0CH,L0187
        LD 6
        JCN 0CH,L0187
        JUN L0183
L0184:
; ) ELSE ERROR = 1;
        JMS QV040
L0183:
L0179:
L0169:
L0160:
L0157:
L0154:
L0151:
; BLANKS();
        FIM 6,084H
        JMS W0009
        JUN L0012
L0191:
; IF (TEXT(POS)) ERROR = 1;
        JMS QV039
        LD 7
        JCN 0CH,L0193
        LD 6
        JCN 4,L0192
L0193:
        JMS QV040
L0192:
        FIM 0,013H
        JUN QRETF
RUNPR:
; RUNPROGRAM
; WHILE (!ERROR && !DONE && LINE < COUNT) (
        JUN L0195
L0194:
; POS = OFFSETS(LINE++);
        FIM 0,030H
        JMS QLDA
        FIM 0,063H
        JMS QSTA
        FIM 0,030H
        JMS QINCC
        FIM 0,063H
        JMS QV068
; STATEMENT();
        FIM 6,086H
        FIM 0,013H
        JMS QSTAC
        JUN F0013
L0198:
L0195:
        JMS W0004
        LD 7
        JCN 0CH,L0199
        FIM 0,070H
        JMS QLDA
        LD 7
        JCN 0CH,L0199
        FIM 0,030H
        JMS QLDA
        JMS QV088
        JCN 0AH,L0194
L0199:
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
        JUN L0201
L0200:
; CH = COMMAND(I); COMMAND(I) = TEXT(I); TEXT(I) = CH;
        JMS W0029
        JMS QV044
        JMS QLDIC
        FIM 0,093H
        JMS QSTAC
        JMS W0029
        JMS QV050
        FIM 0,0A3H
        JMS QSTA
        JMS W0029
        JMS QV044
        FIM 0,0A3H
        JMS QV074
        JMS W0029
        JMS QSHL1
        FIM 0,093H
        JMS QV074
        FIM 0,083H
        JMS QINCC
L0201:
        JMS QV053
        JCN 0AH,L0200
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
        JUN L0205
L0204:
        FIM 0,0C3H
        JMS QV090
        FIM 8,0
        FIM 0AH,0
        JMS QSTI
        FIM 0,0C3H
        JMS QINCV
L0205:
        FIM 8,0
        FIM 0AH,0E2H
        JMS QULT
        JCN 4,$+4
        JUN L0204
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
        JUN L0209
L0208:
; IF (LENGTH < 47) COMMAND(LENGTH++) = CH;
        FIM 0,0F3H
        JMS QLDA
        FIM 0AH,02FH
        JMS QGE8
        JCN 2,L0213
        JMS W0030
        FIM 0,0F3H
        JMS QINCC
        JMS W0031
        JMS QV044
        FIM 0,0E3H
        JMS QV074
        JUN L0212
L0213:
; ELSE ERROR = 6;
        JMS QV065
L0212:
; CH = GETCHAR();
        JMS QGETC
        JMS W0032
L0209:
        JMS W0033
        JMS QV054
        JCN 0CH,L0214
        JMS QV055
        JCN 4,L0208
L0214:
; COMMAND(LENGTH) = 0;
        FIM 0,0F3H
        JMS QLDA
        JMS QV044
        JMS QV084
; IF (ERROR) RETURN 0;
        JMS W0004
        LD 7
        JCN 4,L0215
        FIM 4,0
        FIM 6,0
        FIM 0,0D3H
        JUN QRETF
L0215:
; SWAPLINE();
        FIM 6,088H
        FIM 0,073H
        JMS QSTAC
        JUN F0015
L0216:
; POS = 0; CH = TEXT(POS++); ACTION = CH;
        FIM 4,0
        FIM 6,0
        JMS W0028
        JMS QV069
        JMS W0032
        FIM 0,014H
        JMS QSTAC
; IF (CH == 'R' && TEXT(POS) == 'U') ( NEED('U'); NEED('N'); )
        JMS W0033
        JMS QV073
        JCN 4,L0218
        JMS QV039
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0218
        JMS QV079
        FIM 6,08AH
        JMS W0011
        JUN NEED
L0219:
        JMS QV047
        FIM 6,08CH
        JMS W0011
        JUN NEED
L0220:
        JUN L0217
L0218:
; ELSE IF (CH == 'N') ( NEED('E'); NEED('W'); )
        JMS W0033
        JMS QV096
        JCN 4,L0222
        JMS QV048
        FIM 6,08EH
        JMS W0011
        JUN NEED
L0223:
        FIM 4,0
        FIM 6,057H
        JMS W0010
        FIM 6,090H
        JMS W0011
        JUN NEED
L0224:
        JUN L0221
L0222:
; ELSE IF (CH == 'B') ( NEED('Y'); NEED('E'); )
        FIM 0AH,042H
        JMS QEQ8
        JCN 4,L0226
        FIM 4,0
        FIM 6,059H
        JMS W0010
        FIM 6,092H
        JMS W0011
        JUN NEED
L0227:
        JMS QV048
        FIM 6,094H
        JMS W0011
        JUN NEED
L0228:
        JUN L0225
L0226:
; ELSE IF (CH == 'L' && TEXT(POS) == 'I') ( NEED('I'); NEED('S'); NEED('
        JMS QV095
        JCN 4,L0230
        JMS QV039
        JMS QV094
        JCN 4,L0230
        JMS QV078
        FIM 6,096H
        JMS W0011
        JUN NEED
L0231:
        FIM 4,0
        FIM 6,053H
        JMS W0010
        FIM 6,098H
        JMS W0011
        JUN NEED
L0232:
        JMS QV043
        FIM 6,09AH
        JMS W0011
        JUN NEED
L0233:
        JUN L0229
L0230:
; POS--; ACTION = 0; LINE = COUNT;
        FIM 0,020H
        JMS QDECV
        FIM 4,0
        FIM 6,0
        FIM 0,014H
        JMS QSTAC
        JMS W0034
        JMS W0005
; STATEMENT();
        FIM 6,09CH
        FIM 0,013H
        JMS QSTAC
        JUN F0013
L0234:
L0229:
L0225:
L0221:
L0217:
; BLANKS(); IF (TEXT(POS)) ERROR = 1;
        FIM 6,09EH
        JMS W0009
        JUN L0012
L0235:
        JMS QV039
        LD 7
        JCN 4,$+4
        JUN L0237
        LD 6
        JCN 4,L0236
L0237:
        JMS QV040
L0236:
; SWAPLINE();
        FIM 6,0A0H
        FIM 0,073H
        JMS QSTAC
        JUN F0015
L0238:
; IF (!ERROR) (
        JMS W0004
        LD 7
        JCN 0CH,L0239
; IF (ACTION == 'R') RETURN 1;
        FIM 0,014H
        JMS QLDA
        JMS QV073
        JCN 4,L0240
        FIM 4,0
        FIM 6,1
        FIM 0,0D3H
        JUN QRETF
L0240:
; IF (ACTION == 'B') ( QUITTING = 1; RETURN 1; )
        FIM 0AH,042H
        JMS QEQ8
        JCN 4,L0241
        FIM 4,0
        FIM 6,1
        FIM 0,040H
        JMS QSTAC
        FIM 4,0
        FIM 6,1
        FIM 0,0D3H
        JUN QRETF
L0241:
; IF (ACTION == 'N') ( USED = 0; COUNT = 0; CLEARVARS(); )
        JMS QV096
        JCN 4,L0243
        FIM 4,0
        FIM 6,0
        FIM 0,010H
        JMS QSTA
        FIM 4,0
        FIM 6,0
        FIM 0,050H
        JMS QSTAC
        FIM 6,0A2H
        FIM 0,0B3H
        JMS QSTAC
        JUN CLEAR
L0244:
        JUN L0242
L0243:
; ELSE IF (ACTION == 'L') (
        JMS QV095
        JCN 4,L0246
; FOR (I = 0; I < COUNT; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,4
        JMS QSTAC
        JUN L0248
L0247:
; PRINTF("%U ", LABELS(I)); POS = OFFSETS(I);
        FIM 0,4
        JMS QLDA
        JMS QV089
        JMS QPRTU
        JMS QV080
        FIM 0,4
        JMS QV068
; WHILE (TEXT(POS)) PUTCHAR(TEXT(POS++));
        JUN L0252
L0251:
        JMS W0007
        JMS QV069
        JMS QPUTC
L0252:
        JMS QV039
        LD 7
        JCN 0CH,L0251
        LD 6
        JCN 0CH,L0251
; PUTCHAR(10);
        JMS QV060
        FIM 0,4
        JMS QINCC
L0248:
        JMS QV088
        JCN 0AH,L0247
        JUN L0245
L0246:
; ) ELSE RUNPROGRAM();
        FIM 6,0A4H
        FIM 0,053H
        JMS QSTAC
        JUN L0195
L0255:
L0245:
L0242:
L0239:
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
        JUN L0257
L0256:
; DONE = 0; MARK = USED;
        JMS QV075
        JMS W0035
        FIM 0,064H
        JMS QSTA
; DO (
L0260:
; IF (INTERACTIVE) PRINTF("> ");
        JMS W0003
        LD 7
        JCN 4,L0263
        FIM 0,S0004 AND 0FFH
        JMS QS1
L0263:
; CH = GETCHAR();
        JMS QV051
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0265
L0264:
        JMS QV051
L0265:
        JMS QV052
        JCN 0CH,L0264
        JMS QV057
        JCN 0CH,L0264
        JMS QV054
        JCN 0CH,L0260
        JMS QV055
        JCN 0CH,L0260
; IF (INTERACTIVE && CH >= 'A' && CH <= 'Z') (
        JMS W0003
        LD 7
        JCN 4,L0268
        JMS W0037
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0268
        JMS QV070
        JCN 0AH,L0268
; IF (CONSOLELINE(CH)) RETURN;
        JMS W0032
        FIM 6,0A6H
        FIM 0,0D3H
        JMS QSTAC
        JUN CONSO
L0270:
        LD 7
        JCN 4,L0269
        FIM 0,034H
        JUN QRETF
L0269:
; CONTINUE;
        JUN L0258
L0268:
; IF (CH == 'R') (
        JMS W0037
        JMS QV073
        JCN 0CH,$+4
        JUN L0271
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0273
        JMS QGETC
        JMS QV096
        JCN 0CH,L0272
L0273:
        JMS QV040
L0272:
; CH = GETCHAR();
        JMS QV051
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0275
L0274:
        JMS QV051
L0275:
        JMS QV052
        JCN 0CH,L0274
        JMS QV057
        JCN 0CH,L0274
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV054
        JCN 0CH,L0278
        JMS QV055
        JCN 0CH,L0278
        JMS QV040
L0278:
; RETURN;
        FIM 0,034H
        JUN QRETF
L0271:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,054H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0037
        JMS QV053
        JCN 0AH,L0280
        JMS QV058
        JCN 2,L0282
L0280:
        JMS QV040
L0279:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0282
L0281:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0038
        JMS QV061
        JCN 0CH,L0286
        JMS W0038
        JMS QV062
        JCN 4,L0285
        JMS W0037
        JMS QV085
        JCN 2,L0285
L0286:
        JMS QV063
L0285:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0038
        JMS QV086
        FIM 0,054H
        JMS QV064
        FIM 0,044H
        JMS QV045
        FIM 0,054H
        JMS QSTA
; CH = GETCHAR();
        JMS QV051
L0282:
        JMS W0037
        JMS QV053
        JCN 0AH,L0287
        JMS QV058
        JCN 2,L0281
L0287:
; IF (!ERROR && CH != ' ' && CH != 9) ERROR = 1;
        JMS W0004
        LD 7
        JCN 0CH,L0288
        JMS W0037
        JMS QV052
        JCN 0CH,L0288
        JMS QV057
        JCN 0CH,L0288
        JMS QV040
L0288:
; IF (!ERROR && (!LABEL ?? COUNT == LINES ?? (COUNT && LABEL <= LABELS(C
        JMS W0004
        LD 7
        JCN 0CH,L0289
        JMS W0038
        JMS QTST
        JCN 4,L0290
        JMS W0034
        JMS QV052
        JCN 0CH,L0290
        LD 7
        JCN 0CH,L0291
        LD 6
        JCN 4,L0289
L0291:
        JMS QDEC
        JMS QV089
        JMS QXAB
        JMS W0038
        JMS QULE
        JCN 4,L0289
L0290:
        FIM 4,0
        FIM 6,5
        JMS W0001
L0289:
; IF (ERROR) (
        JMS W0004
        LD 7
        JCN 4,L0300
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 4,L0293
        JUN L0295
L0294:
        JMS QV051
L0295:
        JMS W0037
        JMS QV054
        JCN 0CH,L0298
        JMS QV055
        JCN 4,L0294
L0298:
L0293:
; RETURN;
        FIM 0,034H
        JUN QRETF
L0292:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0300
L0299:
        JMS QV051
L0300:
        JMS W0037
        JMS QV052
        JCN 0CH,L0299
        JMS QV057
        JCN 0CH,L0299
; LABELS(COUNT) = LABEL;
        JMS W0034
        JMS QV042
        FIM 0,054H
        JMS QV072
; OFFSETS(COUNT) = USED;
        JMS W0034
        JMS QV046
        FIM 0,010H
        JMS QV072
; WHILE (CH != 13 && CH != 10) (
        JUN L0304
L0303:
; IF (USED >= SPACE-1) ERROR = 6;
        JMS W0035
        FIM 8,1
        FIM 0AH,07FH
        JMS QUGE
        JCN 4,L0308
        JMS QV065
        JUN L0307
L0308:
; ELSE TEXT(USED++) = CH;
        JMS QV049
        FIM 0,044H
        JMS QV074
L0307:
; CH = GETCHAR();
        JMS QV051
L0304:
        JMS W0037
        JMS QV054
        JCN 0CH,L0309
        JMS QV055
        JCN 0CH,$+4
        JUN L0303
L0309:
; IF (USED >= SPACE) ERROR = 6;
        JMS W0035
        FIM 8,1
        FIM 0AH,080H
        JMS QUGE
        JCN 4,L0310
        JMS QV065
L0310:
; IF (ERROR) ( USED = MARK; RETURN; )
        JMS W0004
        LD 7
        JCN 4,L0311
        FIM 0,064H
        JMS QLDA
        FIM 0,010H
        JMS QSTA
        FIM 0,034H
        JUN QRETF
L0311:
; TEXT(USED++) = 0;
        JMS QV049
        JMS QV084
; COUNT++;
        FIM 0,050H
        JMS QINCC
L0258:
L0257:
        JMS W0004
        LD 7
        JCN 0CH,$+4
        JUN L0256
        FIM 0,034H
        JUN QRETF
        ORG 0A3EH
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
        ORG 0A9CH
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
        ORG 0AF1H
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
        ORG 0B00H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0005
        JUN L0008
        JUN L0009
        JUN L0026
        JUN L0029
        JUN L0030
        JUN L0031
        JUN L0034
        JUN L0035
        JUN L0036
        JUN L0039
        JUN L0044
        JUN L0045
        JUN L0046
        JUN L0047
        JUN L0052
        JUN L0058
        JUN L0063
        JUN L0073
        JUN L0074
        JUN L0075
        JUN L0076
        JUN L0077
        JUN L0086
        JUN L0087
        JUN L0089
        JUN L0092
        JUN L0093
        JUN L0094
        JUN L0095
        JUN L0096
        JUN L0097
        JUN L0124
        JUN L0125
        JUN L0126
        JUN L0132
        JUN L0133
        JUN L0134
        JUN L0135
        JUN L0136
        JUN L0137
        JUN L0138
        JUN L0148
        JUN L0149
        JUN L0153
        JUN L0156
        JUN L0159
        JUN L0162
        JUN L0163
        JUN L0164
        JUN L0165
        JUN L0166
        JUN L0168
        JUN L0171
        JUN L0172
        JUN L0173
        JUN L0174
        JUN L0175
        JUN L0176
        JUN L0177
        JUN L0181
        JUN L0182
        JUN L0185
        JUN L0186
        JUN L0191
        JUN L0198
        JUN L0216
        JUN L0219
        JUN L0220
        JUN L0223
        JUN L0224
        JUN L0227
        JUN L0228
        JUN L0231
        JUN L0232
        JUN L0233
        JUN L0234
        JUN L0235
        JUN L0238
        JUN L0244
        JUN L0255
        JUN L0270
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0BB0H
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
        ORG 0BEFH
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
        ORG 0D3CH
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
        ORG 0D4EH
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
        ORG 0D5EH
QV049:  JMS W0035
        FIM 0,074H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,074H
        JMS QLDA
        JUN QSHL1
        ORG 0D6EH
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
        ORG 0D7CH
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
        ORG 0D89H
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
        ORG 0D95H
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
        ORG 0DA1H
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
        ORG 0DADH
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
        ORG 0DB9H
QV056:  JMS W0006
        FIM 0,021H
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JUN QSUB
        ORG 0DC5H
QV041:  JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JUN QADD
        ORG 0DCFH
QV042:  JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,0
        JUN QADD
        ORG 0DD9H
QV045:  JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JUN QSUB
        ORG 0DE3H
QV046:  JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,080H
        JUN QADD
        ORG 0DEDH
QV059:  JMS QV039
        FIM 0,021H
        JMS QSTAC
        FIM 0AH,041H
        JUN QGE8
        ORG 0DF7H
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0E00H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0E08H
QV044:  JMS QSHL1
        FIM 8,7
        FIM 0AH,088H
        JUN QADD
        ORG 0E10H
QV067:  JMS W0006
        JMS QV050
        FIM 0,052H
        JUN QSTAC
        ORG 0E18H
QV068:  JMS QLDA
        JMS QV046
        JMS QLDI
        JUN W0028
        ORG 0E20H
QV069:  JMS W0030
        JMS W0006
        JMS W0031
        JUN QV050
        ORG 0E28H
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0
        ORG 0E2FH
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0
        ORG 0E36H
; DECREMENT THE INT AT R0R1, LEAVING IT IN A.
QDECV:  JMS QLDA
        JMS QDEC
        JUN QSTA
        ORG 0E3CH
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0E42H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0E48H
QV039:  JMS W0007
        JMS QSHL1
        JUN QLDIC
        ORG 0E4EH
QV040:  FIM 4,0
        FIM 6,1
        JUN W0001
        ORG 0E54H
QV043:  FIM 4,0
        FIM 6,054H
        JUN W0010
        ORG 0E5AH
QV047:  FIM 4,0
        FIM 6,04EH
        JUN W0010
        ORG 0E60H
QV048:  FIM 4,0
        FIM 6,045H
        JUN W0010
        ORG 0E66H
QV060:  FIM 4,0
        FIM 6,0AH
        JUN QPUTC
        ORG 0E6CH
QV061:  FIM 8,019H
        FIM 0AH,099H
        JUN QUGT
        ORG 0E72H
QV062:  FIM 8,019H
        FIM 0AH,099H
        JUN QEQ
        ORG 0E78H
QV063:  FIM 4,0
        FIM 6,2
        JUN W0001
        ORG 0E7EH
QV064:  JMS QLDB
        JMS QADD
        JUN QSHL1
        ORG 0E84H
QV065:  FIM 4,0
        FIM 6,6
        JUN W0001
        ORG 0E8AH
QV075:  FIM 4,0
        FIM 6,0
        JUN W0002
        ORG 0E90H
QV076:  JMS W0015
        FIM 0,081H
        JUN QLDB
        ORG 0E96H
QV077:  JMS W0017
        FIM 0,0D1H
        JUN QLDB
        ORG 0E9CH
QV078:  FIM 4,0
        FIM 6,049H
        JUN W0010
        ORG 0EA2H
QV079:  FIM 4,0
        FIM 6,055H
        JUN W0010
        ORG 0EA8H
QV080:  FIM 4,0
        FIM 6,020H
        JUN QPUTC
        ORG 0EAEH
QV081:  JMS W0023
        FIM 0AH,03CH
        JUN QEQ8
        ORG 0EB4H
QV082:  JMS QLDA
        FIM 0,012H
        JUN QSTA
        ORG 0EBAH
QV083:  FIM 4,0
        FIM 6,04FH
        JUN W0010
        ORG 0EC0H
QV084:  FIM 8,0
        FIM 0AH,0
        JUN QSTIC
        ORG 0EC6H
W0001: FIM 0,060H
        JUN QSTAC
        ORG 0ECAH
W0002: FIM 0,070H
        JUN QSTAC
        ORG 0ECEH
W0003: FIM 0,080H
        JUN QLDA
        ORG 0ED2H
W0004: FIM 0,060H
        JUN QLDA
        ORG 0ED6H
W0005: FIM 0,030H
        JUN QSTAC
        ORG 0EDAH
W0006: FIM 0,020H
        JUN QINCV
        ORG 0EDEH
W0007: FIM 0,020H
        JUN QLDA
        ORG 0EE2H
W0008: FIM 0,0E0H
        JUN QLDA
        ORG 0EE6H
W0009: FIM 0,0A0H
        JUN QSTAC
        ORG 0EEAH
W0010: FIM 0,0C0H
        JUN QSTAC
        ORG 0EEEH
W0011: FIM 0,0B0H
        JUN QSTAC
        ORG 0EF2H
W0012: FIM 0,0D0H
        JUN QSTAC
        ORG 0EF6H
W0013: FIM 0,1
        JUN QSTAC
        ORG 0EFAH
W0014: FIM 0,071H
        JUN QSTA
        ORG 0EFEH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0F00H
W0015: FIM 0,071H
        JUN QLDA
        ORG 0F04H
W0016: FIM 0,0C1H
        JUN QSTA
        ORG 0F08H
W0017: FIM 0,0C1H
        JUN QLDA
        ORG 0F0CH
W0018: FIM 0,050H
        JUN QLDB
        ORG 0F10H
W0019: FIM 0,0B1H
        JUN QSTAC
        ORG 0F14H
W0020: FIM 0,072H
        JUN QSTAC
        ORG 0F18H
W0021: FIM 0,092H
        JUN QLDA
        ORG 0F1CH
W0022: FIM 0,072H
        JUN QLDA
        ORG 0F20H
W0023: FIM 0,0E2H
        JUN QLDA
        ORG 0F24H
W0024: FIM 0,0B2H
        JUN QLDA
        ORG 0F28H
W0025: FIM 0,0C2H
        JUN QLDB
        ORG 0F2CH
W0026: FIM 0,3
        JUN QSTAC
        ORG 0F30H
W0027: FIM 0,3
        JUN QLDA
        ORG 0F34H
W0028: FIM 0,020H
        JUN QSTA
        ORG 0F38H
W0029: FIM 0,083H
        JUN QLDA
        ORG 0F3CH
W0030: FIM 0,024H
        JUN QSTA
        ORG 0F40H
W0031: FIM 0,024H
        JUN QLDA
        ORG 0F44H
W0032: FIM 0,0E3H
        JUN QSTAC
        ORG 0F48H
W0033: FIM 0,0E3H
        JUN QLDA
        ORG 0F4CH
W0034: FIM 0,050H
        JUN QLDA
        ORG 0F50H
W0035: FIM 0,010H
        JUN QLDA
        ORG 0F54H
W0036: FIM 0,044H
        JUN QSTAC
        ORG 0F58H
W0037: FIM 0,044H
        JUN QLDA
        ORG 0F5CH
W0038: FIM 0,054H
        JUN QLDA
        ORG 0F60H
QV050:  JMS QSHL1
        JUN QLDIC
        ORG 0F64H
QV051:  JMS QGETC
        JUN W0036
        ORG 0F68H
QV052:  FIM 0AH,020H
        JUN QEQ8
        ORG 0F6CH
QV053:  FIM 0AH,030H
        JUN QGE8
        ORG 0F70H
QV054:  FIM 0AH,0DH
        JUN QEQ8
        ORG 0F74H
QV055:  FIM 0AH,0AH
        JUN QEQ8
        ORG 0F78H
QV057:  FIM 0AH,9
        JUN QEQ8
        ORG 0F7CH
QV058:  FIM 0AH,039H
        JUN QLE8
        ORG 0F80H
QV066:  JMS QGETC
        JUN W0020
        ORG 0F84H
QV070:  FIM 0AH,05AH
        JUN QLE8
        ORG 0F88H
QV071:  JMS QSTA
        JUN W0004
        ORG 0F8CH
QV072:  JMS QLDB
        JUN QSTI
        ORG 0F90H
QV073:  FIM 0AH,052H
        JUN QEQ8
        ORG 0F94H
QV074:  JMS QLDB
        JUN QSTIC
        ORG 0F98H
QV085:  FIM 0AH,035H
        JUN QLE8
        ORG 0F9CH
QV086:  JMS QSHL1
        JUN QSHL1
        ORG 0FA0H
QV087:  JMS QSTA
        JUN W0006
        ORG 0FA4H
QV088:  JMS W0018
        JUN QGE8
        ORG 0FA8H
QV089:  JMS QV042
        JUN QLDI
        ORG 0FACH
QV090:  JMS QLDA
        JUN QV041
        ORG 0FB0H
QV091:  FIM 0AH,03EH
        JUN QEQ8
        ORG 0FB4H
QV092:  JMS W0024
        JUN W0025
        ORG 0FB8H
QV093:  JMS QBOOL
        JUN W0026
        ORG 0FBCH
QV094:  FIM 0AH,049H
        JUN QEQ8
        ORG 0FC0H
QV095:  FIM 0AH,04CH
        JUN QEQ8
        ORG 0FC4H
QV096:  FIM 0AH,04EH
        JUN QEQ8
        END
