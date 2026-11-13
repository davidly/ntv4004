; BYTE: COMPILED FROM C BY CC4.PY
        ORG 0
; CLEAR THE RAM
        LDM 8
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; PUTS("BASIC4B");
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
        JMS QV072
; IF (INTERACTIVE) PUTS("READY (UPPERCASE)");
        JMS W0003
        LD 7
        JCN 4,L0004
        FIM 0,S0002 AND 0FFH
        JMS QS1
L0004:
; LOAD();
        FIM 6,4
        FIM 0,054H
        JMS QSTAC
        JUN L0263
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
        FIM 0,0D3H
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
        FIM 0,073H
        JMS QSTAC
        JUN L0199
L0009:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0004
        LD 7
        JCN 4,L0010
        FIM 0,S0003 AND 0FFH
        JMS QS1
        JMS W0004
        JMS QPRTU
        JMS QV058
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
        JMS QV037
        JMS QV052
        JCN 0CH,L0011
        JMS QV037
        JMS QV053
        JCN 0CH,L0011
        FIM 0,0B0H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS QV037
        FIM 0,0D0H
        JMS QLDB
        JMS QEQ8
        JCN 0CH,L0016
        JMS QV038
        JUN L0015
L0016:
; ELSE POS++;
        JMS W0006
L0015:
        FIM 0,0C0H
        JUN QRETF
NUMBE:
; NUMBER
; UNSIGNED VALUE;
; CHAR CH;
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JMS QSTA
; CH = TEXT(POS);
        JMS QV037
        FIM 0,1
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS QV063
        JCN 0AH,L0018
        JMS QV068
        JCN 2,L0020
L0018:
        JMS QV038
L0017:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0020
L0019:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0008
        JMS QV073
        JCN 0CH,L0024
        JMS W0008
        JMS QV074
        JCN 4,L0023
        FIM 0,1
        JMS QLDA
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0023
L0024:
        JMS QV075
L0023:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0008
        JMS QSHL1
        JMS QSHL1
        FIM 0,0F0H
        JMS QV076
        FIM 0,1
        JMS QV055
        FIM 0,0F0H
        JMS QV085
; CH = TEXT(POS);
        JMS QV049
        FIM 0,1
        JMS QSTAC
L0020:
        FIM 0,1
        JMS QLDA
        JMS QV063
        JCN 0AH,L0025
        JMS QV068
        JCN 2,L0019
L0025:
; RETURN VALUE;
        JMS W0008
        FIM 0,0E0H
        JUN QRETF
DESTI:
; DESTINATION
; UNSIGNED INDEX;
; CHAR CH;
; CH = TEXT(POS);
        JMS QV056
        NOP
        JCN 2,$+4
        JUN L0026
        JMS QV069
        JCN 0AH,L0026
; POS++;
        JMS W0006
; RETURN CH+(CELLS-'A');
        FIM 0,031H
        JMS QLDA
        FIM 8,0
        FIM 0AH,087H
        JMS QADD
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        FIM 0,011H
        JUN QRETF
L0026:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        JMS QEQ8
        JCN 0CH,L0027
        JMS QV038
        FIM 4,0
        FIM 6,0
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        FIM 0,011H
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
        JMS QV056
        JCN 0AH,L0032
        JMS QV069
        JCN 0AH,L0032
        JMS W0006
        FIM 0,031H
        JMS QV057
        FIM 0,021H
        JMS QSTA
        JUN L0031
L0032:
; ELSE INDEX = NUMBER();
        FIM 6,010H
        JMS W0012
        JUN NUMBE
L0033:
        FIM 0,021H
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
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        FIM 0,011H
        JUN QRETF
L0036:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,021H
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
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        FIM 0,011H
        JUN QRETF
L0037:
; RETURN INDEX;
        FIM 0,021H
        JMS QLDA
        LDM 0
        XCH 4
        LDM 0
        XCH 5
        FIM 0,011H
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
        JMS QV037
        FIM 0,061H
        JMS QSTAC
; IF (CH >= 'A' && CH <= 'Z') ( POS++; VALUE = VARS(CH-'A'); )
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0040
        JMS QV069
        JCN 0AH,L0040
        JMS W0006
        FIM 0,061H
        JMS QV057
        JMS W0013
        JUN L0039
L0040:
; ELSE IF (CH == '@') (
        FIM 0AH,040H
        JMS QEQ8
        JCN 4,L0042
; VALUE = CELLS(DESTINATION());
        FIM 6,018H
        JMS W0014
        JUN DESTI
L0043:
        JMS QV043
        JMS QLDIC
        JMS W0013
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
        FIM 0,051H
        JMS QLDA
        FIM 0,041H
        JUN QRETF
PRODU:
; PRODUCT
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = ATOM();
        FIM 6,01EH
        FIM 0,041H
        JMS QSTAC
        JUN ATOM
L0046:
        JMS W0015
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0048
L0047:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,0B1H
        JMS QV085
        FIM 0,0B1H
        JMS QLDA
        JMS QV049
        FIM 0,0A1H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,020H
        FIM 0,041H
        JMS QSTAC
        JUN ATOM
L0051:
        FIM 0,091H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,0A1H
        JMS QLDA
        FIM 0AH,02AH
        JMS QEQ8
        JCN 4,L0053
        JMS QV077
        JMS QMUL
        JMS W0015
        JUN L0052
L0053:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,091H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0055
        FIM 4,0
        FIM 6,3
        JMS W0001
        JUN L0054
L0055:
; ELSE VALUE = VALUE / RIGHT;
        JMS QV077
        JMS QUDIV
        JMS W0015
L0054:
L0052:
L0048:
        JMS W0004
        LD 7
        JCN 0CH,L0056
        JMS QV037
        FIM 0AH,02AH
        JMS QEQ8
        JCN 0CH,L0047
        JMS QV037
        FIM 0AH,02FH
        JMS QEQ8
        JCN 0CH,L0047
L0056:
; RETURN VALUE;
        JMS W0016
        FIM 0,071H
        JUN QRETF
EXPRE:
; EXPRESSION
; UNSIGNED VALUE, RIGHT;
; CHAR OP;
; VALUE = PRODUCT();
        FIM 6,022H
        FIM 0,071H
        JMS QSTAC
        JUN PRODU
L0057:
        JMS W0017
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0059
L0058:
; OP = TEXT(POS++);
        JMS W0007
        FIM 0,2
        JMS QV085
        FIM 0,2
        JMS QLDA
        JMS QV049
        FIM 0,0F1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,024H
        FIM 0,071H
        JMS QSTAC
        JUN PRODU
L0062:
        FIM 0,0E1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0F1H
        JMS QLDA
        FIM 0AH,02BH
        JMS QEQ8
        JCN 4,L0064
        JMS QV078
        JMS QADD
        JMS W0017
        JUN L0063
L0064:
; ELSE VALUE = VALUE - RIGHT;
        JMS QV078
        JMS QSUB
        JMS W0017
L0063:
L0059:
        JMS W0004
        LD 7
        JCN 0CH,L0065
        JMS QV037
        FIM 0AH,02BH
        JMS QEQ8
        JCN 0CH,L0058
        JMS QV037
        FIM 0AH,02DH
        JMS QEQ8
        JCN 0CH,L0058
L0065:
; RETURN VALUE;
        JMS W0018
        FIM 0,0C1H
        JUN QRETF
FINDL:
; FINDLINE
; CHAR I;
; I = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,032H
        JMS QSTAC
; WHILE (I < COUNT && LABELS(I) != TARGET) I++;
        JUN L0067
L0066:
        FIM 0,032H
        JMS QINCC
L0067:
        JMS QV086
        JCN 2,L0070
        JMS QV087
        FIM 0,022H
        JMS QLDB
        JMS QNE
        JCN 0CH,L0066
L0070:
; IF (I == COUNT) ERROR = 4;
        FIM 0,032H
        JMS QLDA
        JMS W0019
        JMS QEQ8
        JCN 4,L0071
        FIM 4,0
        FIM 6,4
        JMS W0001
L0071:
; RETURN I;
        FIM 0,032H
        JMS QLDA
        FIM 0,012H
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
        JMS QV079
        FIM 6,028H
        JMS W0011
        JUN NEED
L0073:
        JMS QV046
        FIM 6,02AH
        JMS W0011
        JUN NEED
L0074:
        JMS QV042
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
        JMS QV037
        FIM 0AH,022H
        JMS QEQ8
        JCN 4,L0078
; POS++;
        JMS QV065
; WHILE (CH && CH != '"') (
        JUN L0080
L0079:
; PUTCHAR(CH);
        FIM 0,062H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS QV065
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
        FIM 0,052H
        JMS QV064
        LD 7
        JCN 0CH,L0087
        FIM 0,052H
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
        JMS QV037
        FIM 0AH,03BH
        JMS QEQ8
        JCN 4,L0090
        JMS W0006
        JUN L0089
L0090:
; ELSE PUTCHAR(10);
        JMS QV058
L0089:
        FIM 0,042H
        JUN QRETF
READN:
; READNUMBER
; UNSIGNED VALUE;
; VALUE = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,082H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0021
        JMS QV063
        JCN 0AH,L0092
        JMS QV068
        JCN 2,L0094
L0092:
        JMS QV038
L0091:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0094
L0093:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0022
        JMS QV073
        JCN 0CH,L0098
        JMS W0022
        JMS QV074
        JCN 4,L0097
        JMS W0021
        FIM 0AH,035H
        JMS QLE8
        JCN 2,L0097
L0098:
        JMS QV075
L0097:
; VALUE = VALUE*10 + CH-'0';
        JMS W0022
        JMS QSHL1
        JMS QSHL1
        FIM 0,082H
        JMS QV076
        FIM 0,090H
        JMS QV055
        FIM 0,082H
        JMS QSTA
; CH = GETCHAR();
        JMS QV041
L0094:
        JMS W0021
        JMS QV063
        JCN 0AH,L0099
        JMS QV068
        JCN 2,L0093
L0099:
; RETURN VALUE;
        JMS W0022
        FIM 0,072H
        JUN QRETF
INPUT:
; INPUTVAR
; UNSIGNED VARIABLE, VALUE;
; NEED('N'); NEED('P'); NEED('U'); NEED('T'); BLANKS();
        JMS QV046
        FIM 6,036H
        JMS W0011
        JUN NEED
L0100:
        FIM 4,0
        FIM 6,050H
        JMS W0010
        FIM 6,038H
        JMS W0011
        JUN NEED
L0101:
        JMS QV080
        FIM 6,03AH
        JMS W0011
        JUN NEED
L0102:
        JMS QV042
        FIM 6,03CH
        JMS W0011
        JUN NEED
L0103:
        FIM 6,03EH
        JMS W0009
        JUN L0012
L0104:
; VARIABLE = DESTINATION();
        FIM 6,040H
        JMS W0014
        JUN DESTI
L0105:
        FIM 0,0A2H
        JMS QV064
        LD 7
        JCN 4,$+4
        JUN L0106
; PUTCHAR('?'); PUTCHAR(' ');
        FIM 4,0
        FIM 6,03FH
        JMS QPUTC
        JMS QV081
; CH = GETCHAR();
        JMS QV041
; WHILE (CH <= ' ') CH = GETCHAR();
        JUN L0108
L0107:
        JMS QV041
L0108:
        FIM 0AH,020H
        JMS QLE8
        JCN 2,L0107
; VALUE = READNUMBER();
        FIM 6,042H
        FIM 0,072H
        JMS QSTAC
        JUN READN
L0111:
        FIM 0,0B2H
        JMS QSTA
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0113
L0112:
        JMS QV041
L0113:
        JMS QV088
        JCN 0CH,L0112
        JMS QV053
        JCN 0CH,L0112
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV050
        JCN 0CH,L0116
        JMS QV051
        JCN 0CH,L0116
        JMS QV038
L0116:
; IF (!ERROR) (
        JMS W0004
        LD 7
        JCN 0CH,L0117
; IF (VARIABLE < CELLS) CELLS(VARIABLE) = VALUE;
        FIM 0,0A2H
        JMS QV059
        JCN 2,L0119
        JMS QV043
        FIM 0,0B2H
        JMS QV054
        JUN L0118
L0119:
; ELSE VARS(VARIABLE-CELLS) = VALUE;
        JMS QV060
        FIM 0,0B2H
        JMS QV070
L0118:
L0117:
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 4,L0120
        JUN L0122
L0121:
        JMS QV041
L0122:
        JMS QV089
        JCN 0CH,L0125
        JMS QV051
        JCN 4,L0121
L0125:
L0120:
L0106:
        FIM 0,092H
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
L0126:
; BLANKS();
        FIM 6,046H
        JMS W0009
        JUN L0012
L0127:
; LEFT = EXPRESSION();
        FIM 6,048H
        JMS W0020
        JUN EXPRE
L0128:
        FIM 0,0D2H
        JMS QSTA
; OP = TEXT(POS);
        JMS QV037
        FIM 0,3
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0004
        LD 7
        JCN 0CH,L0130
        JMS W0024
        LD 7
        JCN 0CH,L0129
        LD 6
        JCN 0CH,L0129
L0130:
        JMS QV038
        FIM 0,0C2H
        JUN QRETF
L0129:
; POS++;
        JMS W0006
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,013H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS QV082
        JCN 0CH,L0132
        JMS QV090
        JCN 4,L0131
L0132:
        JMS QV037
        FIM 0AH,03DH
        JMS QEQ8
        JCN 4,L0131
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,013H
        JMS QSTAC
; POS++;
        JMS W0006
L0131:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0024
        FIM 0AH,03DH
        JMS QEQ8
        JCN 0CH,L0133
        FIM 0AH,03CH
        JMS QEQ8
        JCN 0CH,L0133
        JMS QV090
        JCN 0CH,L0133
        JMS QV038
L0133:
; RIGHT = EXPRESSION();
        FIM 6,04AH
        JMS W0020
        JUN EXPRE
L0134:
        FIM 0,0E2H
        JMS QSTA
; NEED('T'); NEED('H'); NEED('E'); NEED('N');
        JMS QV042
        FIM 6,04CH
        JMS W0011
        JUN NEED
L0135:
        FIM 4,0
        FIM 6,048H
        JMS W0010
        FIM 6,04EH
        JMS W0011
        JUN NEED
L0136:
        JMS QV047
        FIM 6,050H
        JMS W0011
        JUN NEED
L0137:
        JMS QV046
        FIM 6,052H
        JMS W0011
        JUN NEED
L0138:
; BLANKS();
        FIM 6,054H
        JMS W0009
        JUN L0012
L0139:
; TARGET = NUMBER();
        FIM 6,056H
        JMS W0012
        JUN NUMBE
L0140:
        FIM 0,0F2H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS QV091
        JMS QEQ
        JMS QV092
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS QV082
        JCN 4,L0141
        JMS QV091
        JMS QULT
        JCN 0CH,L0144
        FIM 0,013H
        JMS QLDA
        LD 7
        JCN 4,L0142
        JMS W0028
        LD 7
        JCN 4,L0142
L0144:
        LDM 1
        JUN L0143
L0142:
        LDM 0
L0143:
        JMS QV092
L0141:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0024
        JMS QV090
        JCN 4,L0145
        JMS QV091
        JMS QUGT
        JCN 0CH,L0148
        FIM 0,013H
        JMS QLDA
        LD 7
        JCN 4,L0146
        JMS W0028
        LD 7
        JCN 4,L0146
L0148:
        LDM 1
        JUN L0147
L0146:
        LDM 0
L0147:
        JMS QV092
L0145:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0004
        LD 7
        JCN 0CH,L0149
        JMS W0028
        LD 7
        JCN 4,L0149
        FIM 0,0F2H
        JMS QV083
        FIM 6,058H
        FIM 0,012H
        JMS QSTAC
        JUN FINDL
L0150:
        JMS W0005
L0149:
        FIM 0,0C2H
        JUN QRETF
F0014:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,05AH
        JMS W0009
        JUN L0012
L0151:
; CH = TEXT(POS);
        JMS QV037
        FIM 0,043H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0152
        LD 6
        JCN 0CH,L0152
        JMS QV038
        FIM 0,033H
        JUN QRETF
L0152:
; POS++;
        JMS W0006
; IF (CH == 'P') PRINTLINE();
        FIM 0,043H
        JMS QLDA
        FIM 0AH,050H
        JMS QEQ8
        JCN 4,L0154
        FIM 6,05CH
        FIM 0,042H
        JMS QSTAC
        JUN PRINT
L0155:
        JUN L0153
L0154:
; ELSE IF (CH == 'I' && TEXT(POS) == 'F') BRANCH();
        JMS QV093
        JCN 4,L0157
        JMS QV037
        FIM 0AH,046H
        JMS QEQ8
        JCN 4,L0157
        FIM 6,05EH
        FIM 0,0C2H
        JMS QSTAC
        JUN BRANC
L0158:
        JUN L0156
L0157:
; ELSE IF (CH == 'I') INPUTVAR();
        FIM 0,043H
        JMS QLDA
        JMS QV093
        JCN 4,L0160
        FIM 6,060H
        FIM 0,092H
        JMS QSTAC
        JUN INPUT
L0161:
        JUN L0159
L0160:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0163
; NEED('O'); NEED('T'); NEED('O');
        JMS QV084
        FIM 6,062H
        JMS W0011
        JUN NEED
L0164:
        JMS QV042
        FIM 6,064H
        JMS W0011
        JUN NEED
L0165:
        JMS QV084
        FIM 6,066H
        JMS W0011
        JUN NEED
L0166:
; BLANKS();
        FIM 6,068H
        JMS W0009
        JUN L0012
L0167:
; VALUE = NUMBER();
        FIM 6,06AH
        JMS W0012
        JUN NUMBE
L0168:
        FIM 0,063H
        JMS QV064
        LD 7
        JCN 4,$+4
        JUN L0162
        FIM 0,063H
        JMS QV083
        FIM 6,06CH
        FIM 0,012H
        JMS QSTAC
        JUN FINDL
L0170:
        JMS W0005
L0169:
        JUN L0162
L0163:
; ) ELSE IF (CH == 'L') (
        JMS QV094
        JCN 4,L0172
; NEED('E'); NEED('T');
        JMS QV047
        FIM 6,06EH
        JMS W0011
        JUN NEED
L0173:
        JMS QV042
        FIM 6,070H
        JMS W0011
        JUN NEED
L0174:
; BLANKS();
        FIM 6,072H
        JMS W0009
        JUN L0012
L0175:
; VARIABLE = DESTINATION();
        FIM 6,074H
        JMS W0014
        JUN DESTI
L0176:
        FIM 0,053H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,076H
        JMS W0009
        JUN L0012
L0177:
        FIM 4,0
        FIM 6,03DH
        JMS W0010
        FIM 6,078H
        JMS W0011
        JUN NEED
L0178:
; VALUE = EXPRESSION();
        FIM 6,07AH
        JMS W0020
        JUN EXPRE
L0179:
        FIM 0,063H
        JMS QV064
        LD 7
        JCN 0CH,L0171
; IF (VARIABLE < CELLS) CELLS(VARIABLE) = VALUE;
        FIM 0,053H
        JMS QV059
        JCN 2,L0182
        JMS QV043
        FIM 0,063H
        JMS QV054
        JUN L0171
L0182:
; ELSE VARS(VARIABLE-CELLS) = VALUE;
        JMS QV060
        FIM 0,063H
        JMS QV070
L0180:
        JUN L0171
L0172:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        JMS QEQ8
        JCN 4,L0184
; NEED('N'); NEED('D');
        JMS QV046
        FIM 6,07CH
        JMS W0011
        JUN NEED
L0185:
        FIM 4,0
        FIM 6,044H
        JMS W0010
        FIM 6,07EH
        JMS W0011
        JUN NEED
L0186:
; DONE = 1;
        FIM 4,0
        FIM 6,1
        JMS W0002
        JUN L0183
L0184:
; ) ELSE IF (CH == 'R') (
        JMS QV071
        JCN 4,L0188
; NEED('E'); NEED('M');
        JMS QV047
        FIM 6,080H
        JMS W0011
        JUN NEED
L0189:
        FIM 4,0
        FIM 6,04DH
        JMS W0010
        FIM 6,082H
        JMS W0011
        JUN NEED
L0190:
; WHILE (TEXT(POS)) POS++;
        JUN L0192
L0191:
        JMS W0006
L0192:
        JMS QV037
        LD 7
        JCN 0CH,L0191
        LD 6
        JCN 0CH,L0191
        JUN L0187
L0188:
; ) ELSE ERROR = 1;
        JMS QV038
L0187:
L0183:
L0171:
L0162:
L0159:
L0156:
L0153:
; BLANKS();
        FIM 6,084H
        JMS W0009
        JUN L0012
L0195:
; IF (TEXT(POS)) ERROR = 1;
        JMS QV037
        LD 7
        JCN 0CH,L0197
        LD 6
        JCN 4,L0196
L0197:
        JMS QV038
L0196:
        FIM 0,033H
        JUN QRETF
RUNPR:
; RUNPROGRAM
; WHILE (!ERROR && !DONE && LINE < COUNT) (
        JUN L0199
L0198:
; POS = OFFSETS(LINE++);
        FIM 0,030H
        JMS QLDA
        FIM 0,083H
        JMS QSTA
        FIM 0,030H
        JMS QINCC
        FIM 0,083H
        JMS QV066
; STATEMENT();
        FIM 6,086H
        FIM 0,033H
        JMS QSTAC
        JUN F0014
L0202:
L0199:
        JMS W0004
        LD 7
        JCN 0CH,L0203
        FIM 0,070H
        JMS QLDA
        LD 7
        JCN 0CH,L0203
        FIM 0,030H
        JMS QLDA
        JMS QV086
        JCN 0AH,L0198
L0203:
        FIM 0,073H
        JUN QRETF
F0016:
; SWAPLINE
; CHAR I, CH;
; FOR (I = 0; I < 48; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,0A3H
        JMS QSTAC
        JUN L0205
L0204:
; CH = COMMAND(I); COMMAND(I) = TEXT(I); TEXT(I) = CH;
        JMS W0030
        JMS QV044
        JMS QLDIC
        FIM 0,0B3H
        JMS QSTAC
        JMS W0030
        JMS QV049
        FIM 0,0C3H
        JMS QSTA
        JMS W0030
        JMS QV044
        FIM 0,0C3H
        JMS QV054
        JMS W0030
        JMS QSHL1
        FIM 0,0B3H
        JMS QV054
        FIM 0,0A3H
        JMS QINCC
L0205:
        JMS QV063
        JCN 2,$+4
        JUN L0204
        FIM 0,093H
        JUN QRETF
CLEAR:
; CLEARVARS
; CHAR I;
; FOR (I = 0; I < 26+CELLS; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,0E3H
        JMS QSTAC
        JUN L0209
L0208:
; IF (I < CELLS) CELLS(I) = 0;
        FIM 0,0E3H
        JMS QV059
        JCN 2,L0213
        JMS QV043
        JMS QV061
        JUN L0212
L0213:
; ELSE VARS(I-CELLS) = 0;
        JMS QV060
        FIM 8,0
        FIM 0AH,0
        JMS QSTI
L0212:
        FIM 0,0E3H
        JMS QINCC
L0209:
        FIM 0AH,0E2H
        JMS QGE8
        JCN 0AH,L0208
        FIM 0,0D3H
        JUN QRETF
CONSO:
; CONSOLELINE
; CHAR LENGTH, I, ACTION;
; LENGTH = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,014H
        JMS QSTAC
; WHILE (CH != 13 && CH != 10) (
        JUN L0215
L0214:
; IF (LENGTH < 47) COMMAND(LENGTH++) = CH;
        FIM 0,014H
        JMS QLDA
        FIM 0AH,02FH
        JMS QGE8
        JCN 2,L0219
        JMS W0031
        FIM 0,014H
        JMS QINCC
        JMS W0032
        JMS QV044
        FIM 0,4
        JMS QV054
        JUN L0218
L0219:
; ELSE ERROR = 6;
        JMS QV062
L0218:
; CH = GETCHAR();
        JMS QGETC
        JMS W0033
L0215:
        JMS W0034
        JMS QV050
        JCN 0CH,L0220
        JMS QV051
        JCN 4,L0214
L0220:
; COMMAND(LENGTH) = 0;
        FIM 0,014H
        JMS QLDA
        JMS QV044
        JMS QV061
; IF (ERROR) RETURN 0;
        JMS W0004
        LD 7
        JCN 4,L0221
        FIM 4,0
        FIM 6,0
        FIM 0,0F3H
        JUN QRETF
L0221:
; SWAPLINE();
        FIM 6,088H
        FIM 0,093H
        JMS QSTAC
        JUN F0016
L0222:
; POS = 0; CH = TEXT(POS++); ACTION = CH;
        FIM 4,0
        FIM 6,0
        JMS W0029
        JMS QV067
        JMS W0033
        FIM 0,034H
        JMS QSTAC
; IF (CH == 'R' && TEXT(POS) == 'U') ( NEED('U'); NEED('N'); )
        JMS W0034
        JMS QV071
        JCN 4,L0224
        JMS QV037
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0224
        JMS QV080
        FIM 6,08AH
        JMS W0011
        JUN NEED
L0225:
        JMS QV046
        FIM 6,08CH
        JMS W0011
        JUN NEED
L0226:
        JUN L0223
L0224:
; ELSE IF (CH == 'N') ( NEED('E'); NEED('W'); )
        JMS W0034
        JMS QV095
        JCN 4,L0228
        JMS QV047
        FIM 6,08EH
        JMS W0011
        JUN NEED
L0229:
        FIM 4,0
        FIM 6,057H
        JMS W0010
        FIM 6,090H
        JMS W0011
        JUN NEED
L0230:
        JUN L0227
L0228:
; ELSE IF (CH == 'B') ( NEED('Y'); NEED('E'); )
        FIM 0AH,042H
        JMS QEQ8
        JCN 0CH,$+4
        JUN L0232
        FIM 4,0
        FIM 6,059H
        JMS W0010
        FIM 6,092H
        JMS W0011
        JUN NEED
L0233:
        JMS QV047
        FIM 6,094H
        JMS W0011
        JUN NEED
L0234:
        JUN L0231
L0232:
; ELSE IF (CH == 'L' && TEXT(POS) == 'I') ( NEED('I'); NEED('S'); NEED('
        JMS QV094
        JCN 4,L0236
        JMS QV037
        JMS QV093
        JCN 4,L0236
        JMS QV079
        FIM 6,096H
        JMS W0011
        JUN NEED
L0237:
        FIM 4,0
        FIM 6,053H
        JMS W0010
        FIM 6,098H
        JMS W0011
        JUN NEED
L0238:
        JMS QV042
        FIM 6,09AH
        JMS W0011
        JUN NEED
L0239:
        JUN L0235
L0236:
; POS--; ACTION = 0; LINE = COUNT;
        FIM 0,020H
        JMS QDECV
        FIM 4,0
        FIM 6,0
        FIM 0,034H
        JMS QSTAC
        JMS W0035
        JMS W0005
; STATEMENT();
        FIM 6,09CH
        FIM 0,033H
        JMS QSTAC
        JUN F0014
L0240:
L0235:
L0231:
L0227:
L0223:
; BLANKS(); IF (TEXT(POS)) ERROR = 1;
        FIM 6,09EH
        JMS W0009
        JUN L0012
L0241:
        JMS QV037
        LD 7
        JCN 0CH,L0243
        LD 6
        JCN 4,L0242
L0243:
        JMS QV038
L0242:
; SWAPLINE();
        FIM 6,0A0H
        FIM 0,093H
        JMS QSTAC
        JUN F0016
L0244:
; IF (!ERROR) (
        JMS W0004
        LD 7
        JCN 0CH,L0245
; IF (ACTION == 'R') RETURN 1;
        FIM 0,034H
        JMS QLDA
        JMS QV071
        JCN 4,L0246
        FIM 4,0
        FIM 6,1
        FIM 0,0F3H
        JUN QRETF
L0246:
; IF (ACTION == 'B') ( QUITTING = 1; RETURN 1; )
        FIM 0AH,042H
        JMS QEQ8
        JCN 4,L0247
        FIM 4,0
        FIM 6,1
        FIM 0,040H
        JMS QSTAC
        FIM 4,0
        FIM 6,1
        FIM 0,0F3H
        JUN QRETF
L0247:
; IF (ACTION == 'N') ( USED = 0; COUNT = 0; CLEARVARS(); )
        JMS QV095
        JCN 4,L0249
        FIM 4,0
        FIM 6,0
        FIM 0,010H
        JMS QSTA
        FIM 4,0
        FIM 6,0
        FIM 0,050H
        JMS QSTAC
        FIM 6,0A2H
        FIM 0,0D3H
        JMS QSTAC
        JUN CLEAR
L0250:
        JUN L0248
L0249:
; ELSE IF (ACTION == 'L') (
        JMS QV094
        JCN 4,L0252
; FOR (I = 0; I < COUNT; I++) (
        FIM 4,0
        FIM 6,0
        FIM 0,024H
        JMS QSTAC
        JUN L0254
L0253:
; PRINTF("%U ", LABELS(I)); POS = OFFSETS(I);
        FIM 0,024H
        JMS QLDA
        JMS QV087
        JMS QPRTU
        JMS QV081
        FIM 0,024H
        JMS QV066
; WHILE (TEXT(POS)) PUTCHAR(TEXT(POS++));
        JUN L0258
L0257:
        JMS W0007
        JMS QV067
        JMS QPUTC
L0258:
        JMS QV037
        LD 7
        JCN 0CH,L0257
        LD 6
        JCN 0CH,L0257
; PUTCHAR(10);
        JMS QV058
        FIM 0,024H
        JMS QINCC
L0254:
        JMS QV086
        JCN 0AH,L0253
        JUN L0251
L0252:
; ) ELSE RUNPROGRAM();
        FIM 6,0A4H
        FIM 0,073H
        JMS QSTAC
        JUN L0199
L0261:
L0251:
L0248:
L0245:
; RETURN 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0F3H
        JUN QRETF
F0019:
; LOAD
; UNSIGNED LABEL, MARK;
; WHILE (!ERROR) (
        JUN L0263
L0262:
; DONE = 0; MARK = USED;
        JMS QV072
        JMS W0036
        FIM 0,074H
        JMS QSTA
; DO (
L0266:
; IF (INTERACTIVE) PRINTF("> ");
        JMS W0003
        LD 7
        JCN 0CH,$+4
        JUN L0269
        FIM 0,S0004 AND 0FFH
        JMS QS1
L0269:
; CH = GETCHAR();
        JMS QV041
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0271
L0270:
        JMS QV041
L0271:
        JMS QV052
        JCN 0CH,L0270
        JMS QV053
        JCN 0CH,L0270
        JMS QV050
        JCN 4,$+4
        JUN L0266
        JMS QV051
        JCN 4,$+4
        JUN L0266
; IF (INTERACTIVE && CH >= 'A' && CH <= 'Z') (
        JMS W0003
        LD 7
        JCN 4,L0274
        JMS W0021
        FIM 0AH,041H
        JMS QGE8
        JCN 0AH,L0274
        JMS QV069
        JCN 0AH,L0274
; IF (CONSOLELINE(CH)) RETURN;
        JMS W0033
        FIM 6,0A6H
        FIM 0,0F3H
        JMS QSTAC
        JUN CONSO
L0276:
        LD 7
        JCN 4,L0275
        FIM 0,054H
        JUN QRETF
L0275:
; CONTINUE;
        JUN L0264
L0274:
; IF (CH == 'R') (
        JMS W0021
        JMS QV071
        JCN 4,L0277
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        JMS QEQ8
        JCN 4,L0279
        JMS QGETC
        JMS QV095
        JCN 0CH,L0278
L0279:
        JMS QV038
L0278:
; CH = GETCHAR();
        JMS QV041
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0281
L0280:
        JMS QV041
L0281:
        JMS QV052
        JCN 0CH,L0280
        JMS QV053
        JCN 0CH,L0280
; IF (CH != 13 && CH != 10) ERROR = 1;
        JMS QV050
        JCN 0CH,L0284
        JMS QV051
        JCN 0CH,L0284
        JMS QV038
L0284:
; RETURN;
        FIM 0,054H
        JUN QRETF
L0277:
; LABEL = READNUMBER();
        FIM 6,0A8H
        FIM 0,072H
        JMS QSTAC
        JUN READN
L0285:
        FIM 0,064H
        JMS QV064
        LD 7
        JCN 0CH,L0286
        JMS QV088
        JCN 0CH,L0286
        JMS QV053
        JCN 0CH,L0286
        JMS QV038
L0286:
; IF (!ERROR && (!LABEL ?? COUNT == LINES ?? (COUNT && LABEL <= LABELS(C
        JMS W0004
        LD 7
        JCN 0CH,L0287
        FIM 0,064H
        JMS QLDA
        JMS QTST
        JCN 4,L0288
        JMS W0035
        FIM 0AH,030H
        JMS QEQ8
        JCN 0CH,L0288
        LD 7
        JCN 0CH,L0289
        LD 6
        JCN 4,L0287
L0289:
        JMS QDEC
        JMS QV087
        JMS QXAB
        FIM 0,064H
        JMS QLDA
        JMS QULE
        JCN 4,L0287
L0288:
        FIM 4,0
        FIM 6,5
        JMS W0001
L0287:
; IF (ERROR) (
        JMS W0004
        LD 7
        JCN 4,L0298
; IF (INTERACTIVE) WHILE (CH != 13 && CH != 10) CH = GETCHAR();
        JMS W0003
        LD 7
        JCN 4,L0291
        JUN L0293
L0292:
        JMS QV041
L0293:
        JMS QV089
        JCN 0CH,L0296
        JMS QV051
        JCN 4,L0292
L0296:
L0291:
; RETURN;
        FIM 0,054H
        JUN QRETF
L0290:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0298
L0297:
        JMS QV041
L0298:
        JMS QV088
        JCN 0CH,L0297
        JMS QV053
        JCN 0CH,L0297
; LABELS(COUNT) = LABEL;
        JMS W0035
        JMS QV040
        FIM 0,064H
        JMS QV070
; OFFSETS(COUNT) = USED;
        JMS W0035
        JMS QV045
        FIM 0,010H
        JMS QV070
; WHILE (CH != 13 && CH != 10) (
        JUN L0302
L0301:
; IF (USED >= SPACE-1) ERROR = 6;
        JMS W0036
        FIM 8,1
        FIM 0AH,0FFH
        JMS QUGE
        JCN 4,L0306
        JMS QV062
        JUN L0305
L0306:
; ELSE TEXT(USED++) = CH;
        JMS QV048
        FIM 0,090H
        JMS QV054
L0305:
; CH = GETCHAR();
        JMS QV041
L0302:
        JMS QV089
        JCN 0CH,L0307
        JMS QV051
        JCN 0CH,$+4
        JUN L0301
L0307:
; IF (USED >= SPACE) ERROR = 6;
        JMS W0036
        FIM 8,2
        FIM 0AH,0
        JMS QUGE
        JCN 4,L0308
        JMS QV062
L0308:
; IF (ERROR) ( USED = MARK; RETURN; )
        JMS W0004
        LD 7
        JCN 4,L0309
        FIM 0,074H
        JMS QLDA
        FIM 0,010H
        JMS QSTA
        FIM 0,054H
        JUN QRETF
L0309:
; TEXT(USED++) = 0;
        JMS QV048
        JMS QV061
; COUNT++;
        FIM 0,050H
        JMS QINCC
L0264:
L0263:
        JMS W0004
        LD 7
        JCN 0CH,$+4
        JUN L0262
        FIM 0,054H
        JUN QRETF
        ORG 0A4FH
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
        ORG 0AADH
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
        ORG 0AECH
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
        JUN L0100
        JUN L0101
        JUN L0102
        JUN L0103
        JUN L0104
        JUN L0105
        JUN L0111
        JUN L0126
        JUN L0127
        JUN L0128
        JUN L0134
        JUN L0135
        JUN L0136
        JUN L0137
        JUN L0138
        JUN L0139
        JUN L0140
        JUN L0150
        JUN L0151
        JUN L0155
        JUN L0158
        JUN L0161
        JUN L0164
        JUN L0165
        JUN L0166
        JUN L0167
        JUN L0168
        JUN L0170
        JUN L0173
        JUN L0174
        JUN L0175
        JUN L0176
        JUN L0177
        JUN L0178
        JUN L0179
        JUN L0185
        JUN L0186
        JUN L0189
        JUN L0190
        JUN L0195
        JUN L0202
        JUN L0222
        JUN L0225
        JUN L0226
        JUN L0229
        JUN L0230
        JUN L0233
        JUN L0234
        JUN L0237
        JUN L0238
        JUN L0239
        JUN L0240
        JUN L0241
        JUN L0244
        JUN L0250
        JUN L0261
        JUN L0276
        JUN L0285
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0BB2H
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
        DB 042H,041H,053H,049H,043H,034H,042H,0AH,0
S0002:
        DB 052H,045H,041H,044H,059H,020H,028H,055H,050H,050H,045H,052H
        DB 043H,041H,053H,045H,029H,0AH,0
S0003:
        DB 03FH,045H,052H,052H,04FH,052H,020H,0
S0004:
        DB 03EH,020H,0
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
        ORG 0C55H
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
        ORG 0C8BH
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
        ORG 0CBCH
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
        ORG 0CE8H
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
        ORG 0CFEH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0D00H
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
        ORG 0D1CH
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
        ORG 0D31H
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
        ORG 0D43H
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
        ORG 0D54H
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
        ORG 0D64H
QV048:  JMS W0036
        FIM 0,084H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,084H
        JMS QLDA
        JUN QSHL1
        ORG 0D74H
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
        ORG 0D82H
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
        ORG 0D90H
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
        ORG 0D9DH
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
        ORG 0DA9H
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
        ORG 0DB5H
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
        ORG 0DC1H
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
        ORG 0DCDH
QV039:  JMS QSUB
        JMS QSHL1
        JMS QSHL1
        FIM 8,5
        FIM 0AH,080H
        JUN QADD
        ORG 0DD9H
QV040:  JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JUN QADD
        ORG 0DE3H
QV045:  JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0C0H
        JUN QADD
        ORG 0DEDH
QV055:  JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JUN QSUB
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
QV056:  JMS QV037
        FIM 0,031H
        JMS QSTAC
        FIM 0AH,041H
        JUN QGE8
        ORG 0E0AH
QV057:  JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JMS QV039
        JUN QLDI
        ORG 0E14H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0E1CH
QV043:  JMS QSHL1
        FIM 8,5
        FIM 0AH,0E8H
        JUN QADD
        ORG 0E24H
QV044:  JMS QSHL1
        FIM 8,7
        FIM 0AH,078H
        JUN QADD
        ORG 0E2CH
QV065:  JMS W0006
        JMS QV049
        FIM 0,062H
        JUN QSTAC
        ORG 0E34H
QV066:  JMS QLDA
        JMS QV045
        JMS QLDI
        JUN W0029
        ORG 0E3CH
QV067:  JMS W0031
        JMS W0006
        JMS W0032
        JUN QV049
        ORG 0E44H
; THE CARRY IS 1 IF A >= B, COMPARING LOW BYTES.
QGE8:   CLC
        LD 7
        SUB 11
        CMC
        LD 6
        SUB 10
        BBL 0
        ORG 0E4BH
; THE CARRY IS 1 IF A <= B, COMPARING LOW BYTES.
QLE8:   CLC
        LD 11
        SUB 7
        CMC
        LD 10
        SUB 6
        BBL 0
        ORG 0E52H
; DECREMENT THE INT AT R0R1, LEAVING IT IN A.
QDECV:  JMS QLDA
        JMS QDEC
        JUN QSTA
        ORG 0E58H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0E5EH
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0E64H
QV037:  JMS W0007
        JMS QSHL1
        JUN QLDIC
        ORG 0E6AH
QV038:  FIM 4,0
        FIM 6,1
        JUN W0001
        ORG 0E70H
QV042:  FIM 4,0
        FIM 6,054H
        JUN W0010
        ORG 0E76H
QV046:  FIM 4,0
        FIM 6,04EH
        JUN W0010
        ORG 0E7CH
QV047:  FIM 4,0
        FIM 6,045H
        JUN W0010
        ORG 0E82H
QV058:  FIM 4,0
        FIM 6,0AH
        JUN QPUTC
        ORG 0E88H
QV059:  JMS QLDA
        FIM 0AH,0C8H
        JUN QGE8
        ORG 0E8EH
QV060:  FIM 8,0
        FIM 0AH,0C8H
        JUN QV039
        ORG 0E94H
QV061:  FIM 8,0
        FIM 0AH,0
        JUN QSTIC
        ORG 0E9AH
QV062:  FIM 4,0
        FIM 6,6
        JUN W0001
        ORG 0EA0H
QV072:  FIM 4,0
        FIM 6,0
        JUN W0002
        ORG 0EA6H
QV073:  FIM 8,019H
        FIM 0AH,099H
        JUN QUGT
        ORG 0EACH
QV074:  FIM 8,019H
        FIM 0AH,099H
        JUN QEQ
        ORG 0EB2H
QV075:  FIM 4,0
        FIM 6,2
        JUN W0001
        ORG 0EB8H
QV076:  JMS QLDB
        JMS QADD
        JUN QSHL1
        ORG 0EBEH
QV077:  JMS W0016
        FIM 0,091H
        JUN QLDB
        ORG 0EC4H
QV078:  JMS W0018
        FIM 0,0E1H
        JUN QLDB
        ORG 0ECAH
QV079:  FIM 4,0
        FIM 6,049H
        JUN W0010
        ORG 0ED0H
QV080:  FIM 4,0
        FIM 6,055H
        JUN W0010
        ORG 0ED6H
QV081:  FIM 4,0
        FIM 6,020H
        JUN QPUTC
        ORG 0EDCH
QV082:  JMS W0024
        FIM 0AH,03CH
        JUN QEQ8
        ORG 0EE2H
QV083:  JMS QLDA
        FIM 0,022H
        JUN QSTA
        ORG 0EE8H
QV084:  FIM 4,0
        FIM 6,04FH
        JUN W0010
        ORG 0EEEH
W0001: FIM 0,060H
        JUN QSTAC
        ORG 0EF2H
W0002: FIM 0,070H
        JUN QSTAC
        ORG 0EF6H
W0003: FIM 0,080H
        JUN QLDA
        ORG 0EFAH
W0004: FIM 0,060H
        JUN QLDA
        ORG 0F00H
W0005: FIM 0,030H
        JUN QSTAC
        ORG 0F04H
W0006: FIM 0,020H
        JUN QINCV
        ORG 0F08H
W0007: FIM 0,020H
        JUN QLDA
        ORG 0F0CH
W0008: FIM 0,0F0H
        JUN QLDA
        ORG 0F10H
W0009: FIM 0,0B0H
        JUN QSTAC
        ORG 0F14H
W0010: FIM 0,0D0H
        JUN QSTAC
        ORG 0F18H
W0011: FIM 0,0C0H
        JUN QSTAC
        ORG 0F1CH
W0012: FIM 0,0E0H
        JUN QSTAC
        ORG 0F20H
W0013: FIM 0,051H
        JUN QSTA
        ORG 0F24H
W0014: FIM 0,011H
        JUN QSTAC
        ORG 0F28H
W0015: FIM 0,081H
        JUN QSTA
        ORG 0F2CH
W0016: FIM 0,081H
        JUN QLDA
        ORG 0F30H
W0017: FIM 0,0D1H
        JUN QSTA
        ORG 0F34H
W0018: FIM 0,0D1H
        JUN QLDA
        ORG 0F38H
W0019: FIM 0,050H
        JUN QLDB
        ORG 0F3CH
W0020: FIM 0,0C1H
        JUN QSTAC
        ORG 0F40H
W0021: FIM 0,090H
        JUN QLDA
        ORG 0F44H
W0022: FIM 0,082H
        JUN QLDA
        ORG 0F48H
W0023: FIM 0,090H
        JUN QSTAC
        ORG 0F4CH
W0024: FIM 0,3
        JUN QLDA
        ORG 0F50H
W0025: FIM 0,0D2H
        JUN QLDA
        ORG 0F54H
W0026: FIM 0,0E2H
        JUN QLDB
        ORG 0F58H
W0027: FIM 0,023H
        JUN QSTAC
        ORG 0F5CH
W0028: FIM 0,023H
        JUN QLDA
        ORG 0F60H
W0029: FIM 0,020H
        JUN QSTA
        ORG 0F64H
W0030: FIM 0,0A3H
        JUN QLDA
        ORG 0F68H
W0031: FIM 0,044H
        JUN QSTA
        ORG 0F6CH
W0032: FIM 0,044H
        JUN QLDA
        ORG 0F70H
W0033: FIM 0,4
        JUN QSTAC
        ORG 0F74H
W0034: FIM 0,4
        JUN QLDA
        ORG 0F78H
W0035: FIM 0,050H
        JUN QLDA
        ORG 0F7CH
W0036: FIM 0,010H
        JUN QLDA
        ORG 0F80H
QV041:  JMS QGETC
        JUN W0023
        ORG 0F84H
QV049:  JMS QSHL1
        JUN QLDIC
        ORG 0F88H
QV050:  FIM 0AH,0DH
        JUN QEQ8
        ORG 0F8CH
QV051:  FIM 0AH,0AH
        JUN QEQ8
        ORG 0F90H
QV052:  FIM 0AH,020H
        JUN QEQ8
        ORG 0F94H
QV053:  FIM 0AH,9
        JUN QEQ8
        ORG 0F98H
QV054:  JMS QLDB
        JUN QSTIC
        ORG 0F9CH
QV063:  FIM 0AH,030H
        JUN QGE8
        ORG 0FA0H
QV064:  JMS QSTA
        JUN W0004
        ORG 0FA4H
QV068:  FIM 0AH,039H
        JUN QLE8
        ORG 0FA8H
QV069:  FIM 0AH,05AH
        JUN QLE8
        ORG 0FACH
QV070:  JMS QLDB
        JUN QSTI
        ORG 0FB0H
QV071:  FIM 0AH,052H
        JUN QEQ8
        ORG 0FB4H
QV085:  JMS QSTA
        JUN W0006
        ORG 0FB8H
QV086:  JMS W0019
        JUN QGE8
        ORG 0FBCH
QV087:  JMS QV040
        JUN QLDI
        ORG 0FC0H
QV088:  JMS W0021
        JUN QV052
        ORG 0FC4H
QV089:  JMS W0021
        JUN QV050
        ORG 0FC8H
QV090:  FIM 0AH,03EH
        JUN QEQ8
        ORG 0FCCH
QV091:  JMS W0025
        JUN W0026
        ORG 0FD0H
QV092:  JMS QBOOL
        JUN W0027
        ORG 0FD4H
QV093:  FIM 0AH,049H
        JUN QEQ8
        ORG 0FD8H
QV094:  FIM 0AH,04CH
        JUN QEQ8
        ORG 0FDCH
QV095:  FIM 0AH,04EH
        JUN QEQ8
        END
