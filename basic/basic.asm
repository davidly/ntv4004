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
; LOAD();
        FIM 6,4
        FIM 0,043H
        JMS QSTAC
        JUN L0186
L0001:
; LINE = 0;
        FIM 4,0
        FIM 6,0
        JMS W0001
; WHILE (!ERROR && !DONE && LINE < COUNT) (
        JUN L0003
L0002:
; POS = OFFSETS(LINE++);
        FIM 0,030H
        JMS QLDA
        FIM 0,080H
        JMS QSTA
        FIM 0,030H
        JMS QINCV
        FIM 0,080H
        JMS QLDA
        JMS QV044
        JMS QLDI
        FIM 0,020H
        JMS QSTA
; STATEMENT();
        FIM 6,6
        FIM 0,3
        JMS QSTAC
        JUN F0013
L0006:
L0003:
        JMS W0002
        LD 7
        JCN 0CH,L0007
        FIM 0,060H
        JMS QLDA
        LD 7
        JCN 0CH,L0007
        FIM 0,030H
        JMS QLDA
        JMS W0003
        JMS QULT
        JCN 0CH,L0002
L0007:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0002
        LD 7
        JCN 4,L0008
        FIM 0,S0002 AND 0FFH
        JMS QS1
        JMS W0002
        JMS QPRTU
        JMS QV057
L0008:
; RETURN 0;
        FIM 4,0
        FIM 6,0
        JUN QEXIT
BLANK:
; BLANKS
; WHILE (TEXT(POS) == ' ' ?? TEXT(POS) == 9) POS++;
        JUN L0010
L0009:
        JMS W0004
L0010:
        JMS QV030
        JMS QV038
        JCN 0CH,L0009
        JMS QV030
        JMS QV041
        JCN 0CH,L0009
        FIM 0,090H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS QV030
        FIM 0,0B0H
        JMS QLDB
        JMS QEQ8
        JCN 0CH,L0014
        JMS QV031
        JUN L0013
L0014:
; ELSE POS++;
        JMS W0004
L0013:
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
        JMS QV030
        FIM 0,0E0H
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV042
        JCN 0AH,L0016
        JMS QV043
        JCN 2,L0018
L0016:
        JMS QV031
L0015:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0018
L0017:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0007
        JMS QV047
        JCN 0CH,L0022
        JMS W0007
        JMS QV048
        JCN 4,L0021
        FIM 0,0E0H
        JMS QV058
        JCN 2,L0021
L0022:
        JMS QV049
L0021:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0007
        JMS QV066
        FIM 0,0D0H
        JMS QV050
        FIM 0,0E0H
        JMS QV033
        FIM 0,0D0H
        JMS QV067
; CH = TEXT(POS);
        JMS QSHL1
        JMS QLDIC
        FIM 0,0E0H
        JMS QSTAC
L0018:
        FIM 0,0E0H
        JMS QLDA
        JMS QV042
        JCN 0AH,L0023
        JMS QV043
        JCN 2,L0017
L0023:
; RETURN VALUE;
        JMS W0007
        FIM 0,0C0H
        JUN QRETF
DESTI:
; DESTINATION
; UNSIGNED INDEX;
; CHAR CH;
; BLANKS();
        FIM 6,8
        JMS W0008
        JUN L0010
L0024:
; CH = TEXT(POS);
        JMS QV045
        JCN 0AH,L0025
        JMS QV068
        JCN 0AH,L0025
        JMS QV040
        FIM 0,0F0H
        JUN QRETF
L0025:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,$+4
        JUN L0026
        JMS QV031
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0026:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0004
        FIM 6,0AH
        JMS W0008
        JUN L0010
L0027:
        FIM 4,0
        FIM 6,028H
        JMS W0009
        FIM 6,0CH
        JMS W0010
        JUN NEED
L0028:
        FIM 6,0EH
        JMS W0008
        JUN L0010
L0029:
; CH = TEXT(POS);
        JMS QV045
        JCN 0AH,L0031
        JMS QV068
        JCN 0AH,L0031
        JMS QV040
        JMS QV032
        JMS QLDI
        FIM 0,1
        JMS QSTA
        JUN L0030
L0031:
; ELSE INDEX = NUMBER();
        FIM 6,010H
        JMS W0011
        JUN NUMBE
L0032:
        FIM 0,1
        JMS QSTA
L0030:
; BLANKS(); NEED(')');
        FIM 6,012H
        JMS W0008
        JUN L0010
L0033:
        FIM 4,0
        FIM 6,029H
        JMS W0009
        FIM 6,014H
        JMS W0010
        JUN NEED
L0034:
; IF (ERROR) RETURN 0;
        JMS W0002
        LD 7
        JCN 4,L0035
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0035:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,0C8H
        JMS QUGE
        JCN 4,L0036
        FIM 4,0
        FIM 6,7
        JMS W0006
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0036:
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
        JMS W0008
        JUN L0010
L0037:
; CH = TEXT(POS);
        JMS QV030
        FIM 0,041H
        JMS QSTAC
; IF ((CH >= 'A' && CH <= 'Z') ?? CH == '@') VALUE = VARS(DESTINATION())
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0041
        JMS QV068
        JCN 2,L0040
L0041:
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,L0039
L0040:
        FIM 6,018H
        JMS W0012
        JUN DESTI
L0042:
        JMS QV032
        JMS QLDI
        FIM 0,031H
        JMS QSTA
        JUN L0038
L0039:
; ELSE VALUE = NUMBER();
        FIM 6,01AH
        JMS W0011
        JUN NUMBE
L0043:
        FIM 0,031H
        JMS QSTA
L0038:
; BLANKS();
        FIM 6,01CH
        JMS W0008
        JUN L0010
L0044:
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
L0045:
        JMS W0013
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0047
L0046:
; OP = TEXT(POS++);
        JMS W0005
        FIM 0,091H
        JMS QV067
        FIM 0,091H
        JMS QV059
        FIM 0,081H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,020H
        FIM 0,021H
        JMS QSTAC
        JUN ATOM
L0050:
        FIM 0,071H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,081H
        JMS QLDA
        FIM 0AH,02AH
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0052
        JMS QV060
        JMS QMUL
        JMS W0013
        JUN L0051
L0052:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,071H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0054
        FIM 4,0
        FIM 6,3
        JMS W0006
        JUN L0053
L0054:
; ELSE VALUE = VALUE / RIGHT;
        JMS QV060
        JMS QUDIV
        JMS W0013
L0053:
L0051:
L0047:
        JMS W0002
        LD 7
        JCN 0CH,L0055
        JMS QV030
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,$+4
        JUN L0046
        JMS QV030
        FIM 0AH,02FH
        JMS QEQ8
        JCN 4,$+4
        JUN L0046
L0055:
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
L0056:
        JMS W0015
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0058
L0057:
; OP = TEXT(POS++);
        JMS W0005
        FIM 0,0E1H
        JMS QV067
        FIM 0,0E1H
        JMS QV059
        FIM 0,0D1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,024H
        FIM 0,051H
        JMS QSTAC
        JUN PRODU
L0061:
        FIM 0,0C1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0D1H
        JMS QLDA
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,L0063
        JMS QV061
        JMS QADD
        JMS W0015
        JUN L0062
L0063:
; ELSE VALUE = VALUE - RIGHT;
        JMS QV061
        JMS QSUB
        JMS W0015
L0062:
L0058:
        JMS W0002
        LD 7
        JCN 0CH,L0064
        JMS QV030
        FIM 0AH,02BH
        JMS QEQ8
        JCN 0CH,L0057
        JMS QV030
        FIM 0AH,02DH
        JMS QEQ8
        JCN 0CH,L0057
L0064:
; RETURN VALUE;
        JMS W0016
        FIM 0,0A1H
        JUN QRETF
FINDL:
; FINDLINE
; CHAR I;
; I = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,012H
        JMS QSTAC
; WHILE (I < COUNT && LABELS(I) != TARGET) I++;
        JUN L0066
L0065:
        FIM 0,012H
        JMS QINCC
L0066:
        JMS W0003
        JMS QGE8
        JCN 2,L0069
        JMS QV034
        JMS QLDI
        FIM 0,2
        JMS QLDB
        JMS QNE
        JCN 0CH,L0065
L0069:
; IF (I == COUNT) ERROR = 4;
        FIM 0,012H
        JMS QLDA
        JMS W0003
        JMS QEQ8
        JCN 4,L0070
        FIM 4,0
        FIM 6,4
        JMS W0006
L0070:
; RETURN I;
        FIM 0,012H
        JMS QLDA
        FIM 0,0F1H
        JUN QRETF
PRINT:
; PRINTLINE
; UNSIGNED VALUE;
; CHAR CH;
; NEED('R'); NEED('I'); NEED('N'); NEED('T');
        FIM 4,0
        FIM 6,052H
        JMS W0009
        FIM 6,026H
        JMS W0010
        JUN NEED
L0071:
        FIM 4,0
        FIM 6,049H
        JMS W0009
        FIM 6,028H
        JMS W0010
        JUN NEED
L0072:
        JMS QV037
        FIM 6,02AH
        JMS W0010
        JUN NEED
L0073:
        JMS QV035
        FIM 6,02CH
        JMS W0010
        JUN NEED
L0074:
; BLANKS();
        FIM 6,02EH
        JMS W0008
        JUN L0010
L0075:
; IF (TEXT(POS) == '"') (
        JMS QV030
        FIM 0AH,022H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0077
; POS++;
        JMS QV046
; WHILE (CH && CH != '"') (
        JUN L0079
L0078:
; PUTCHAR(CH);
        FIM 0,042H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS QV046
L0079:
        LD 7
        JCN 0CH,L0083
        LD 6
        JCN 4,L0082
L0083:
        FIM 0AH,022H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0078
L0082:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0009
        FIM 6,030H
        JMS W0010
        JUN NEED
L0084:
        JUN L0076
L0077:
; VALUE = EXPRESSION();
        FIM 6,032H
        JMS W0017
        JUN EXPRE
L0085:
        FIM 0,032H
        JMS QV052
        LD 7
        JCN 0CH,L0086
        FIM 0,032H
        JMS QLDA
        JMS QPRTU
L0086:
L0076:
; BLANKS();
        FIM 6,034H
        JMS W0008
        JUN L0010
L0087:
; IF (TEXT(POS) == ';') POS++;
        JMS QV030
        FIM 0AH,03BH
        JMS QEQ8
        JCN 4,L0089
        JMS W0004
        JUN L0088
L0089:
; ELSE PUTCHAR(10);
        JMS QV057
L0088:
        FIM 0,022H
        JUN QRETF
INPUT:
; INPUTVAR
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; NEED('N'); NEED('P'); NEED('U'); NEED('T'); BLANKS();
        JMS QV037
        FIM 6,036H
        JMS W0010
        JUN NEED
L0090:
        FIM 4,0
        FIM 6,050H
        JMS W0009
        FIM 6,038H
        JMS W0010
        JUN NEED
L0091:
        FIM 4,0
        FIM 6,055H
        JMS W0009
        FIM 6,03AH
        JMS W0010
        JUN NEED
L0092:
        JMS QV035
        FIM 6,03CH
        JMS W0010
        JUN NEED
L0093:
        FIM 6,03EH
        JMS W0008
        JUN L0010
L0094:
; VARIABLE = DESTINATION();
        FIM 6,040H
        JMS W0012
        JUN DESTI
L0095:
        FIM 0,072H
        JMS QV052
        LD 7
        JCN 4,$+4
        JUN L0096
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,082H
        JMS QSTA
; PUTCHAR('?'); PUTCHAR(' ');
        FIM 4,0
        FIM 6,03FH
        JMS QPUTC
        FIM 4,0
        FIM 6,020H
        JMS QPUTC
; CH = GETCHAR();
        JMS QV053
; WHILE (CH <= ' ') CH = GETCHAR();
        JUN L0098
L0097:
        JMS QV053
L0098:
        FIM 0AH,020H
        JMS QLE8
        JCN 2,L0097
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV042
        JCN 0AH,L0102
        JMS QV043
        JCN 2,L0104
L0102:
        JMS QV031
L0101:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0104
L0103:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0019
        JMS QV047
        JCN 0CH,L0108
        JMS W0019
        JMS QV048
        JCN 4,L0107
        FIM 0,062H
        JMS QV058
        JCN 2,L0107
L0108:
        JMS QV049
L0107:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0019
        JMS QV066
        FIM 0,082H
        JMS QV050
        FIM 0,062H
        JMS QV033
        FIM 0,082H
        JMS QSTA
; CH = GETCHAR();
        JMS QV053
L0104:
        FIM 0,062H
        JMS QLDA
        JMS QV042
        JCN 0AH,L0111
        JMS QV043
        JCN 2,L0103
L0109:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0111
L0110:
        JMS QV053
L0111:
        JMS QV038
        JCN 0CH,L0110
        JMS QV041
        JCN 0CH,L0110
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV054
        JCN 0CH,L0114
        JMS QV055
        JCN 0CH,L0114
        JMS QV031
L0114:
; VARS(VARIABLE) = VALUE;
        FIM 0,072H
        JMS QLDA
        JMS QV032
        FIM 0,082H
        JMS QV056
L0096:
        FIM 0,052H
        JUN QRETF
BRANC:
; BRANCH
; UNSIGNED LEFT, RIGHT, TARGET;
; CHAR OP, EQUAL, YES;
; NEED('F');
        FIM 4,0
        FIM 6,046H
        JMS W0009
        FIM 6,042H
        JMS W0010
        JUN NEED
L0115:
; BLANKS();
        FIM 6,044H
        JMS W0008
        JUN L0010
L0116:
; LEFT = EXPRESSION();
        FIM 6,046H
        JMS W0017
        JUN EXPRE
L0117:
        FIM 0,0A2H
        JMS QSTA
; OP = TEXT(POS);
        JMS QV030
        FIM 0,0D2H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0002
        LD 7
        JCN 0CH,L0119
        JMS W0020
        LD 7
        JCN 0CH,L0118
        LD 6
        JCN 0CH,L0118
L0119:
        JMS QV031
        FIM 0,092H
        JUN QRETF
L0118:
; POS++;
        JMS W0004
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0E2H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS QV062
        JCN 0CH,L0121
        JMS QV069
        JCN 4,L0120
L0121:
        JMS QV030
        FIM 0AH,03DH
        JMS QEQ8
        JCN 4,L0120
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,0E2H
        JMS QSTAC
; POS++;
        JMS W0004
L0120:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0020
        FIM 0AH,03DH
        JMS QEQ8
        JCN 0CH,L0122
        FIM 0AH,03CH
        JMS QEQ8
        JCN 0CH,L0122
        JMS QV069
        JCN 0CH,L0122
        JMS QV031
L0122:
; RIGHT = EXPRESSION();
        FIM 6,048H
        JMS W0017
        JUN EXPRE
L0123:
        FIM 0,0B2H
        JMS QSTA
; NEED('T'); NEED('H'); NEED('E'); NEED('N');
        JMS QV035
        FIM 6,04AH
        JMS W0010
        JUN NEED
L0124:
        FIM 4,0
        FIM 6,048H
        JMS W0009
        FIM 6,04CH
        JMS W0010
        JUN NEED
L0125:
        JMS QV051
        FIM 6,04EH
        JMS W0010
        JUN NEED
L0126:
        JMS QV037
        FIM 6,050H
        JMS W0010
        JUN NEED
L0127:
; BLANKS();
        FIM 6,052H
        JMS W0008
        JUN L0010
L0128:
; TARGET = NUMBER();
        FIM 6,054H
        JMS W0011
        JUN NUMBE
L0129:
        FIM 0,0C2H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS QV070
        JMS QEQ
        JMS QV071
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS QV062
        JCN 4,L0130
        JMS QV070
        JMS QULT
        JCN 0CH,L0133
        FIM 0,0E2H
        JMS QLDA
        LD 7
        JCN 4,L0131
        JMS W0024
        LD 7
        JCN 4,L0131
L0133:
        LDM 1
        JUN L0132
L0131:
        LDM 0
L0132:
        JMS QV071
L0130:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0020
        JMS QV069
        JCN 0CH,$+4
        JUN L0134
        JMS QV070
        JMS QUGT
        JCN 4,$+4
        JUN L0137
        FIM 0,0E2H
        JMS QLDA
        LD 7
        JCN 0CH,$+4
        JUN L0135
        JMS W0024
        LD 7
        JCN 0CH,$+4
        JUN L0135
L0137:
        LDM 1
        JUN L0136
L0135:
        LDM 0
L0136:
        JMS QV071
L0134:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0002
        LD 7
        JCN 4,$+4
        JUN L0138
        JMS W0024
        LD 7
        JCN 0CH,$+4
        JUN L0138
        FIM 0,0C2H
        JMS QV063
        FIM 6,056H
        FIM 0,0F1H
        JMS QSTAC
        JUN FINDL
L0139:
        JMS W0001
L0138:
        FIM 0,092H
        JUN QRETF
F0013:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,058H
        JMS W0008
        JUN L0010
L0140:
; CH = TEXT(POS);
        JMS QV030
        FIM 0,013H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0141
        LD 6
        JCN 0CH,L0141
        JMS QV031
        FIM 0,3
        JUN QRETF
L0141:
; POS++;
        JMS W0004
; IF (CH == 'P') PRINTLINE();
        FIM 0,013H
        JMS QLDA
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0143
        FIM 6,05AH
        FIM 0,022H
        JMS QSTAC
        JUN PRINT
L0144:
        JUN L0142
L0143:
; ELSE IF (CH == 'I' && TEXT(POS) == 'F') BRANCH();
        FIM 0AH,049H
        JMS QEQ8
        JCN 4,L0146
        JMS QV030
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0146
        FIM 6,05CH
        FIM 0,092H
        JMS QSTAC
        JUN BRANC
L0147:
        JUN L0145
L0146:
; ELSE IF (CH == 'I') INPUTVAR();
        FIM 0,013H
        JMS QLDA
        FIM 0AH,049H
        JMS QEQ8
        JCN 4,L0149
        FIM 6,05EH
        FIM 0,052H
        JMS QSTAC
        JUN INPUT
L0150:
        JUN L0148
L0149:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        JMS QEQ8
        JCN 4,L0152
; NEED('O'); NEED('T'); NEED('O');
        JMS QV064
        FIM 6,060H
        JMS W0010
        JUN NEED
L0153:
        JMS QV035
        FIM 6,062H
        JMS W0010
        JUN NEED
L0154:
        JMS QV064
        FIM 6,064H
        JMS W0010
        JUN NEED
L0155:
; BLANKS();
        FIM 6,066H
        JMS W0008
        JUN L0010
L0156:
; VALUE = NUMBER();
        FIM 6,068H
        JMS W0011
        JUN NUMBE
L0157:
        FIM 0,033H
        JMS QV052
        LD 7
        JCN 0CH,L0158
        FIM 0,033H
        JMS QV063
        FIM 6,06AH
        FIM 0,0F1H
        JMS QSTAC
        JUN FINDL
L0159:
        JMS W0001
L0158:
        JUN L0151
L0152:
; ) ELSE IF (CH == 'L') (
        FIM 0AH,04CH
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0161
; NEED('E'); NEED('T');
        JMS QV051
        FIM 6,06CH
        JMS W0010
        JUN NEED
L0162:
        JMS QV035
        FIM 6,06EH
        JMS W0010
        JUN NEED
L0163:
; BLANKS();
        FIM 6,070H
        JMS W0008
        JUN L0010
L0164:
; VARIABLE = DESTINATION();
        FIM 6,072H
        JMS W0012
        JUN DESTI
L0165:
        FIM 0,023H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,074H
        JMS W0008
        JUN L0010
L0166:
        FIM 4,0
        FIM 6,03DH
        JMS W0009
        FIM 6,076H
        JMS W0010
        JUN NEED
L0167:
; VALUE = EXPRESSION();
        FIM 6,078H
        JMS W0017
        JUN EXPRE
L0168:
        FIM 0,033H
        JMS QV052
        LD 7
        JCN 0CH,L0160
        FIM 0,023H
        JMS QLDA
        JMS QV032
        FIM 0,033H
        JMS QV056
L0169:
        JUN L0160
L0161:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0171
; NEED('N'); NEED('D');
        JMS QV037
        FIM 6,07AH
        JMS W0010
        JUN NEED
L0172:
        FIM 4,0
        FIM 6,044H
        JMS W0009
        FIM 6,07CH
        JMS W0010
        JUN NEED
L0173:
; DONE = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,060H
        JMS QSTAC
        JUN L0170
L0171:
; ) ELSE IF (CH == 'R') (
        FIM 0AH,052H
        JMS QEQ8
        JCN 4,L0175
; NEED('E'); NEED('M');
        JMS QV051
        FIM 6,07EH
        JMS W0010
        JUN NEED
L0176:
        FIM 4,0
        FIM 6,04DH
        JMS W0009
        FIM 6,080H
        JMS W0010
        JUN NEED
L0177:
; WHILE (TEXT(POS)) POS++;
        JUN L0179
L0178:
        JMS W0004
L0179:
        JMS QV030
        LD 7
        JCN 0CH,L0178
        LD 6
        JCN 0CH,L0178
        JUN L0174
L0175:
; ) ELSE ERROR = 1;
        JMS QV031
L0174:
L0170:
L0160:
L0151:
L0148:
L0145:
L0142:
; BLANKS();
        FIM 6,082H
        JMS W0008
        JUN L0010
L0182:
; IF (TEXT(POS)) ERROR = 1;
        JMS QV030
        LD 7
        JCN 0CH,L0184
        LD 6
        JCN 4,L0183
L0184:
        JMS QV031
L0183:
        FIM 0,3
        JUN QRETF
F0014:
; LOAD
; CHAR CH;
; UNSIGNED LABEL;
; WHILE (!ERROR) (
        JUN L0186
L0185:
; CH = GETCHAR();
        JMS QV039
; WHILE (CH == 13 ?? CH == 10 ?? CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0190
L0189:
        JMS QV039
L0190:
        JMS QV054
        JCN 0CH,L0189
        JMS QV055
        JCN 0CH,L0189
        JMS QV038
        JCN 0CH,L0189
        JMS QV041
        JCN 0CH,L0189
; IF (CH == 'R') (
        FIM 0AH,052H
        JMS QEQ8
        JCN 4,L0193
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0195
        JMS QGETC
        FIM 0AH,04EH
        JMS QEQ8
        JCN 0CH,L0194
L0195:
        JMS QV031
L0194:
; CH = GETCHAR();
        JMS QV039
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0197
L0196:
        JMS QV039
L0197:
        JMS QV038
        JCN 0CH,L0196
        JMS QV041
        JCN 0CH,L0196
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV054
        JCN 0CH,L0200
        JMS QV055
        JCN 0CH,L0200
        JMS QV031
L0200:
; RETURN;
        FIM 0,043H
        JUN QRETF
L0193:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,063H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0026
        JMS QV042
        JCN 0AH,L0202
        JMS QV043
        JCN 2,L0201
L0202:
        JMS QV031
L0201:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0204
L0203:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0027
        JMS QV047
        JCN 0CH,L0208
        JMS W0027
        JMS QV048
        JCN 4,L0207
        JMS W0026
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0207
L0208:
        JMS QV049
L0207:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0027
        JMS QV066
        FIM 0,063H
        JMS QV050
        FIM 0,053H
        JMS QV033
        FIM 0,063H
        JMS QSTA
; CH = GETCHAR();
        JMS QV039
L0204:
        JMS W0026
        JMS QV042
        JCN 2,$+4
        JUN L0209
        JMS QV043
        JCN 0AH,$+4
        JUN L0203
L0209:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0210
        FIM 0,043H
        JUN QRETF
L0210:
; IF (CH != ' ' && CH != 9) ERROR = 1;
        JMS W0026
        JMS QV038
        JCN 0CH,L0211
        JMS QV041
        JCN 0CH,L0211
        JMS QV031
L0211:
; IF (!LABEL ?? COUNT == LINES ?? (COUNT && LABEL <= LABELS(COUNT-1))) E
        JMS W0027
        JMS QTST
        JCN 4,L0213
        JMS W0028
        JMS QV038
        JCN 0CH,L0213
        LD 7
        JCN 0CH,L0214
        LD 6
        JCN 4,L0212
L0214:
        JMS QDEC
        JMS QV034
        JMS QLDI
        JMS QXAB
        JMS W0027
        JMS QULE
        JCN 4,L0212
L0213:
        FIM 4,0
        FIM 6,5
        JMS W0006
L0212:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0217
        FIM 0,043H
        JUN QRETF
L0215:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0217
L0216:
        JMS QV039
L0217:
        JMS W0026
        JMS QV038
        JCN 0CH,L0216
        JMS QV041
        JCN 0CH,L0216
; LABELS(COUNT) = LABEL;
        JMS W0028
        JMS QV034
        FIM 0,063H
        JMS QV056
; OFFSETS(COUNT) = USED;
        JMS W0028
        JMS QV044
        FIM 0,010H
        JMS QV056
; WHILE (CH != 13 && CH != 10) (
        JUN L0221
L0220:
; IF (USED >= SPACE-1) ( ERROR = 6; RETURN; )
        JMS W0029
        FIM 8,1
        FIM 0AH,07FH
        JMS QUGE
        JCN 4,L0224
        JMS QV065
        FIM 0,043H
        JUN QRETF
L0224:
; TEXT(USED++) = CH;
        JMS QV036
        FIM 0,053H
        JMS QLDB
        JMS QSTIC
; CH = GETCHAR();
        JMS QV039
L0221:
        JMS W0026
        JMS QV054
        JCN 0CH,L0225
        JMS QV055
        JCN 4,L0220
L0225:
; IF (USED >= SPACE) ( ERROR = 6; RETURN; )
        JMS W0029
        FIM 8,1
        FIM 0AH,080H
        JMS QUGE
        JCN 4,L0226
        JMS QV065
        FIM 0,043H
        JUN QRETF
L0226:
; TEXT(USED++) = 0;
        JMS QV036
        FIM 8,0
        FIM 0AH,0
        JMS QSTIC
; COUNT++;
        FIM 0,040H
        JMS QINCC
L0186:
        JMS W0002
        LD 7
        JCN 0CH,$+4
        JUN L0185
        FIM 0,043H
        JUN QRETF
        ORG 07C0H
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
        ORG 0800H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0006
        JUN L0024
        JUN L0027
        JUN L0028
        JUN L0029
        JUN L0032
        JUN L0033
        JUN L0034
        JUN L0037
        JUN L0042
        JUN L0043
        JUN L0044
        JUN L0045
        JUN L0050
        JUN L0056
        JUN L0061
        JUN L0071
        JUN L0072
        JUN L0073
        JUN L0074
        JUN L0075
        JUN L0084
        JUN L0085
        JUN L0087
        JUN L0090
        JUN L0091
        JUN L0092
        JUN L0093
        JUN L0094
        JUN L0095
        JUN L0115
        JUN L0116
        JUN L0117
        JUN L0123
        JUN L0124
        JUN L0125
        JUN L0126
        JUN L0127
        JUN L0128
        JUN L0129
        JUN L0139
        JUN L0140
        JUN L0144
        JUN L0147
        JUN L0150
        JUN L0153
        JUN L0154
        JUN L0155
        JUN L0156
        JUN L0157
        JUN L0159
        JUN L0162
        JUN L0163
        JUN L0164
        JUN L0165
        JUN L0166
        JUN L0167
        JUN L0168
        JUN L0172
        JUN L0173
        JUN L0176
        JUN L0177
        JUN L0182
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 088CH
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
        ORG 08EAH
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
        ORG 098BH
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
        ORG 09BCH
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
        ORG 09E8H
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
        ORG 09FDH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
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
        DB 042H,041H,053H,049H,043H,034H,0AH,0
S0002:
        DB 03FH,045H,052H,052H,04FH,052H,020H,0
        ORG 0A24H
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
        ORG 0A40H
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
        ORG 0A54H
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
        ORG 0A67H
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
        ORG 0A79H
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
        ORG 0A8AH
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
        ORG 0A9AH
QV036:  JMS W0029
        FIM 0,073H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,073H
        JMS QLDA
        JUN QSHL1
        ORG 0AAAH
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
        ORG 0AB8H
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
        ORG 0AC6H
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
        ORG 0AD3H
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
        ORG 0ADFH
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
        ORG 0AEBH
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
        ORG 0AF7H
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
        ORG 0B0CH
QV040:  JMS W0004
        FIM 0,011H
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JUN QSUB
        ORG 0B18H
QV032:  JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JUN QADD
        ORG 0B22H
QV033:  JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JUN QSUB
        ORG 0B2CH
QV034:  JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,0
        JUN QADD
        ORG 0B36H
QV044:  JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,080H
        JUN QADD
        ORG 0B40H
QV045:  JMS QV030
        FIM 0,011H
        JMS QSTAC
        FIM 0AH,041H
        JUN QGE8
        ORG 0B4AH
QV046:  JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,042H
        JUN QSTAC
        ORG 0B54H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0B5CH
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0
        ORG 0B63H
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0
        ORG 0B6AH
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0B70H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0B76H
QV030:  JMS W0005
        JMS QSHL1
        JUN QLDIC
        ORG 0B7CH
QV031:  FIM 4,0
        FIM 6,1
        JUN W0006
        ORG 0B82H
QV035:  FIM 4,0
        FIM 6,054H
        JUN W0009
        ORG 0B88H
QV037:  FIM 4,0
        FIM 6,04EH
        JUN W0009
        ORG 0B8EH
QV047:  FIM 8,019H
        FIM 0AH,099H
        JUN QUGT
        ORG 0B94H
QV048:  FIM 8,019H
        FIM 0AH,099H
        JUN QEQ
        ORG 0B9AH
QV049:  FIM 4,0
        FIM 6,2
        JUN W0006
        ORG 0BA0H
QV050:  JMS QLDB
        JMS QADD
        JUN QSHL1
        ORG 0BA6H
QV051:  FIM 4,0
        FIM 6,045H
        JUN W0009
        ORG 0BACH
QV057:  FIM 4,0
        FIM 6,0AH
        JUN QPUTC
        ORG 0BB2H
QV058:  JMS QLDA
        FIM 0AH,035H
        JUN QLE8
        ORG 0BB8H
QV059:  JMS QLDA
        JMS QSHL1
        JUN QLDIC
        ORG 0BBEH
QV060:  JMS W0014
        FIM 0,071H
        JUN QLDB
        ORG 0BC4H
QV061:  JMS W0016
        FIM 0,0C1H
        JUN QLDB
        ORG 0BCAH
QV062:  JMS W0020
        FIM 0AH,03CH
        JUN QEQ8
        ORG 0BD0H
QV063:  JMS QLDA
        FIM 0,2
        JUN QSTA
        ORG 0BD6H
QV064:  FIM 4,0
        FIM 6,04FH
        JUN W0009
        ORG 0BDCH
QV065:  FIM 4,0
        FIM 6,6
        JUN W0006
        ORG 0BE2H
W0001: FIM 0,030H
        JUN QSTA
        ORG 0BE6H
W0002: FIM 0,050H
        JUN QLDA
        ORG 0BEAH
W0003: FIM 0,040H
        JUN QLDB
        ORG 0BEEH
W0004: FIM 0,020H
        JUN QINCV
        ORG 0BF2H
W0005: FIM 0,020H
        JUN QLDA
        ORG 0BF6H
W0006: FIM 0,050H
        JUN QSTAC
        ORG 0BFAH
W0007: FIM 0,0D0H
        JUN QLDA
        ORG 0C00H
W0008: FIM 0,090H
        JUN QSTAC
        ORG 0C04H
W0009: FIM 0,0B0H
        JUN QSTAC
        ORG 0C08H
W0010: FIM 0,0A0H
        JUN QSTAC
        ORG 0C0CH
W0011: FIM 0,0C0H
        JUN QSTAC
        ORG 0C10H
W0012: FIM 0,0F0H
        JUN QSTAC
        ORG 0C14H
W0013: FIM 0,061H
        JUN QSTA
        ORG 0C18H
W0014: FIM 0,061H
        JUN QLDA
        ORG 0C1CH
W0015: FIM 0,0B1H
        JUN QSTA
        ORG 0C20H
W0016: FIM 0,0B1H
        JUN QLDA
        ORG 0C24H
W0017: FIM 0,0A1H
        JUN QSTAC
        ORG 0C28H
W0018: FIM 0,062H
        JUN QSTAC
        ORG 0C2CH
W0019: FIM 0,082H
        JUN QLDA
        ORG 0C30H
W0020: FIM 0,0D2H
        JUN QLDA
        ORG 0C34H
W0021: FIM 0,0A2H
        JUN QLDA
        ORG 0C38H
W0022: FIM 0,0B2H
        JUN QLDB
        ORG 0C3CH
W0023: FIM 0,0F2H
        JUN QSTAC
        ORG 0C40H
W0024: FIM 0,0F2H
        JUN QLDA
        ORG 0C44H
W0025: FIM 0,053H
        JUN QSTAC
        ORG 0C48H
W0026: FIM 0,053H
        JUN QLDA
        ORG 0C4CH
W0027: FIM 0,063H
        JUN QLDA
        ORG 0C50H
W0028: FIM 0,040H
        JUN QLDA
        ORG 0C54H
W0029: FIM 0,010H
        JUN QLDA
        ORG 0C58H
QV038:  FIM 0AH,020H
        JUN QEQ8
        ORG 0C5CH
QV039:  JMS QGETC
        JUN W0025
        ORG 0C60H
QV041:  FIM 0AH,9
        JUN QEQ8
        ORG 0C64H
QV042:  FIM 0AH,030H
        JUN QGE8
        ORG 0C68H
QV043:  FIM 0AH,039H
        JUN QLE8
        ORG 0C6CH
QV052:  JMS QSTA
        JUN W0002
        ORG 0C70H
QV053:  JMS QGETC
        JUN W0018
        ORG 0C74H
QV054:  FIM 0AH,0DH
        JUN QEQ8
        ORG 0C78H
QV055:  FIM 0AH,0AH
        JUN QEQ8
        ORG 0C7CH
QV056:  JMS QLDB
        JUN QSTI
        ORG 0C80H
QV066:  JMS QSHL1
        JUN QSHL1
        ORG 0C84H
QV067:  JMS QSTA
        JUN W0004
        ORG 0C88H
QV068:  FIM 0AH,05AH
        JUN QLE8
        ORG 0C8CH
QV069:  FIM 0AH,03EH
        JUN QEQ8
        ORG 0C90H
QV070:  JMS W0021
        JUN W0022
        ORG 0C94H
QV071:  JMS QBOOL
        JUN W0023
        END
