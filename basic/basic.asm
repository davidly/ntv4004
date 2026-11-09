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
        JUN F0014
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
        JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,080H
        JMS QADD
        JMS QLDI
        FIM 0,020H
        JMS QSTA
; STATEMENT();
        FIM 6,6
        FIM 0,3
        JMS QSTAC
        JUN F0013
L0006:
L0004:
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
L0005:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0002
        LD 7
        JCN 4,L0008
        FIM 0,S0002 AND 0FFH
        JMS QS1
        JMS W0002
        JMS QPRTU
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
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
L0011:
L0010:
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0013
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0009
L0013:
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0014
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0009
L0014:
L0012:
        FIM 0,090H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0,0B0H
        JMS QLDB
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0017
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0016
L0017:
        FIM 4,0
        FIM 6,1
        JMS W0006
        JUN L0015
L0016:
; ELSE POS++;
        JMS W0004
L0015:
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
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0,0E0H
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0019
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0018
L0019:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0018:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0021
L0020:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0007
        FIM 8,019H
        FIM 0AH,099H
        JMS QUGT
        JCN 4,$+4
        JUN L0025
        JMS W0007
        FIM 8,019H
        FIM 0AH,099H
        JMS QEQ
        JCN 0CH,$+4
        JUN L0024
        FIM 0,0E0H
        JMS QLDA
        FIM 0AH,035H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0024
L0025:
        FIM 4,0
        FIM 6,2
        JMS W0006
L0024:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0007
        JMS QSHL1
        JMS QSHL1
        FIM 0,0D0H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        FIM 0,0E0H
        JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JMS QSUB
        FIM 0,0D0H
        JMS QSTA
; POS++;
        JMS W0004
; CH = TEXT(POS);
        JMS QSHL1
        JMS QLDIC
        FIM 0,0E0H
        JMS QSTAC
L0022:
L0021:
        FIM 0,0E0H
        JMS QLDA
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0026
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,$+4
        JUN L0020
L0026:
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
        JUN BLANK
L0027:
; CH = TEXT(POS);
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0,011H
        JMS QSTAC
; IF (CH >= 'A' && CH <= 'Z') ( POS++; RETURN CH-'A'; )
        FIM 0AH,041H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0028
        FIM 0AH,05AH
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,L0028
        JMS W0004
        FIM 0,011H
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JMS QSUB
        FIM 0,0F0H
        JUN QRETF
L0028:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0030
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0029
L0030:
        FIM 4,0
        FIM 6,1
        JMS W0006
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0029:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0004
        FIM 6,0AH
        JMS W0008
        JUN BLANK
L0031:
        FIM 4,0
        FIM 6,028H
        JMS W0009
        FIM 6,0CH
        JMS W0010
        JUN NEED
L0032:
        FIM 6,0EH
        JMS W0008
        JUN BLANK
L0033:
; CH = TEXT(POS);
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0,011H
        JMS QSTAC
; IF (CH >= 'A' && CH <= 'Z') ( POS++; INDEX = VARS(CH-'A'); )
        FIM 0AH,041H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0035
        FIM 0AH,05AH
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,$+4
        JUN L0035
        JMS W0004
        FIM 0,011H
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JMS QSUB
        JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JMS QADD
        JMS QLDI
        FIM 0,1
        JMS QSTA
        JUN L0034
L0035:
; ELSE INDEX = NUMBER();
        FIM 6,010H
        JMS W0011
        JUN NUMBE
L0036:
        FIM 0,1
        JMS QSTA
L0034:
; BLANKS(); NEED(')');
        FIM 6,012H
        JMS W0008
        JUN BLANK
L0037:
        FIM 4,0
        FIM 6,029H
        JMS W0009
        FIM 6,014H
        JMS W0010
        JUN NEED
L0038:
; IF (ERROR) RETURN 0;
        JMS W0002
        LD 7
        JCN 4,L0039
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0039:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,0C8H
        JMS QUGE
        JCN 4,L0040
        FIM 4,0
        FIM 6,7
        JMS W0006
        FIM 4,0
        FIM 6,0
        FIM 0,0F0H
        JUN QRETF
L0040:
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
        JUN BLANK
L0041:
; CH = TEXT(POS);
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0,041H
        JMS QSTAC
; IF ((CH >= 'A' && CH <= 'Z') ?? CH == '@') VALUE = VARS(DESTINATION())
        FIM 0AH,041H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0045
        FIM 0AH,05AH
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0044
L0045:
        FIM 0AH,040H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0043
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0043
L0044:
        FIM 6,018H
        JMS W0012
        JUN DESTI
L0046:
        JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JMS QADD
        JMS QLDI
        FIM 0,031H
        JMS QSTA
        JUN L0042
L0043:
; ELSE VALUE = NUMBER();
        FIM 6,01AH
        JMS W0011
        JUN NUMBE
L0047:
        FIM 0,031H
        JMS QSTA
L0042:
; BLANKS();
        FIM 6,01CH
        JMS W0008
        JUN BLANK
L0048:
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
L0049:
        JMS W0013
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0051
L0050:
; OP = TEXT(POS++);
        JMS W0005
        FIM 0,091H
        JMS QSTA
        JMS W0004
        FIM 0,091H
        JMS QLDA
        JMS QSHL1
        JMS QLDIC
        FIM 0,081H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,020H
        FIM 0,021H
        JMS QSTAC
        JUN ATOM
L0054:
        FIM 0,071H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,081H
        JMS QLDA
        FIM 0AH,02AH
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0056
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0056
        JMS W0014
        FIM 0,071H
        JMS QLDB
        JMS QMUL
        JMS W0013
        JUN L0055
L0056:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,071H
        JMS QLDA
        JMS QTST
        JCN 4,$+4
        JUN L0058
        FIM 4,0
        FIM 6,3
        JMS W0006
        JUN L0057
L0058:
; ELSE VALUE = VALUE / RIGHT;
        JMS W0014
        FIM 0,071H
        JMS QLDB
        JMS QUDIV
        JMS W0013
L0057:
L0055:
L0052:
L0051:
        JMS W0002
        LD 7
        JCN 0CH,L0059
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0060
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0050
L0060:
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02FH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0061
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0050
L0061:
L0059:
L0053:
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
L0062:
        JMS W0015
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0064
L0063:
; OP = TEXT(POS++);
        JMS W0005
        FIM 0,0E1H
        JMS QSTA
        JMS W0004
        FIM 0,0E1H
        JMS QLDA
        JMS QSHL1
        JMS QLDIC
        FIM 0,0D1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,024H
        FIM 0,051H
        JMS QSTAC
        JUN PRODU
L0067:
        FIM 0,0C1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0D1H
        JMS QLDA
        FIM 0AH,02BH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0069
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0069
        JMS W0016
        FIM 0,0C1H
        JMS QLDB
        JMS QADD
        JMS W0015
        JUN L0068
L0069:
; ELSE VALUE = VALUE - RIGHT;
        JMS W0016
        FIM 0,0C1H
        JMS QLDB
        JMS QSUB
        JMS W0015
L0068:
L0065:
L0064:
        JMS W0002
        LD 7
        JCN 0CH,L0070
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02BH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0071
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0063
L0071:
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0072
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0063
L0072:
L0070:
L0066:
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
        JUN L0074
L0073:
        FIM 0,012H
        JMS QINCC
L0075:
L0074:
        JMS W0003
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,$+4
        JUN L0077
        JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,0
        JMS QADD
        JMS QLDI
        FIM 0,2
        JMS QLDB
        JMS QNE
        JCN 4,$+4
        JUN L0073
L0077:
L0076:
; IF (I == COUNT) ERROR = 4;
        FIM 0,012H
        JMS QLDA
        JMS W0003
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0078
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0078
        FIM 4,0
        FIM 6,4
        JMS W0006
L0078:
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
L0079:
        FIM 4,0
        FIM 6,049H
        JMS W0009
        FIM 6,028H
        JMS W0010
        JUN NEED
L0080:
        FIM 4,0
        FIM 6,04EH
        JMS W0009
        FIM 6,02AH
        JMS W0010
        JUN NEED
L0081:
        FIM 4,0
        FIM 6,054H
        JMS W0009
        FIM 6,02CH
        JMS W0010
        JUN NEED
L0082:
; BLANKS();
        FIM 6,02EH
        JMS W0008
        JUN BLANK
L0083:
; IF (TEXT(POS) == '"') (
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,022H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0085
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0085
; POS++;
        JMS W0004
; CH = TEXT(POS);
        JMS QSHL1
        JMS QLDIC
        FIM 0,042H
        JMS QSTAC
; WHILE (CH && CH != '"') (
        JUN L0087
L0086:
; PUTCHAR(CH);
        FIM 0,042H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS W0004
; CH = TEXT(POS);
        JMS QSHL1
        JMS QLDIC
        FIM 0,042H
        JMS QSTAC
L0088:
L0087:
        LD 7
        JCN 0CH,L0091
        LD 6
        JCN 4,L0090
L0091:
        FIM 0AH,022H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0086
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0086
L0090:
L0089:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0009
        FIM 6,030H
        JMS W0010
        JUN NEED
L0092:
        JUN L0084
L0085:
; VALUE = EXPRESSION();
        FIM 6,032H
        JMS W0017
        JUN EXPRE
L0093:
        FIM 0,032H
        JMS QSTA
; IF (!ERROR) PRINTF("%U", VALUE);
        JMS W0002
        LD 7
        JCN 0CH,L0094
        FIM 0,032H
        JMS QLDA
        JMS QPRTU
L0094:
L0084:
; BLANKS();
        FIM 6,034H
        JMS W0008
        JUN BLANK
L0095:
; IF (TEXT(POS) == ';') POS++;
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,03BH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0097
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0097
        JMS W0004
        JUN L0096
L0097:
; ELSE PUTCHAR(10);
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
L0096:
        FIM 0,022H
        JUN QRETF
INPUT:
; INPUTVAR
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; NEED('N'); NEED('P'); NEED('U'); NEED('T'); BLANKS();
        FIM 4,0
        FIM 6,04EH
        JMS W0009
        FIM 6,036H
        JMS W0010
        JUN NEED
L0098:
        FIM 4,0
        FIM 6,050H
        JMS W0009
        FIM 6,038H
        JMS W0010
        JUN NEED
L0099:
        FIM 4,0
        FIM 6,055H
        JMS W0009
        FIM 6,03AH
        JMS W0010
        JUN NEED
L0100:
        FIM 4,0
        FIM 6,054H
        JMS W0009
        FIM 6,03CH
        JMS W0010
        JUN NEED
L0101:
        FIM 6,03EH
        JMS W0008
        JUN BLANK
L0102:
; VARIABLE = DESTINATION();
        FIM 6,040H
        JMS W0012
        JUN DESTI
L0103:
        FIM 0,072H
        JMS QSTA
; IF (!ERROR) (
        JMS W0002
        LD 7
        JCN 4,$+4
        JUN L0104
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
        JMS QGETC
        JMS W0018
; WHILE (CH <= ' ') CH = GETCHAR();
        JUN L0106
L0105:
        JMS QGETC
        JMS W0018
L0107:
L0106:
        FIM 0AH,020H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0105
L0108:
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0110
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0109
L0110:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0109:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0112
L0111:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0019
        FIM 8,019H
        FIM 0AH,099H
        JMS QUGT
        JCN 0CH,L0116
        JMS W0019
        FIM 8,019H
        FIM 0AH,099H
        JMS QEQ
        JCN 4,L0115
        FIM 0,062H
        JMS QLDA
        FIM 0AH,035H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0115
L0116:
        FIM 4,0
        FIM 6,2
        JMS W0006
L0115:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0019
        JMS QSHL1
        JMS QSHL1
        FIM 0,082H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        FIM 0,062H
        JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JMS QSUB
        FIM 0,082H
        JMS QSTA
; CH = GETCHAR();
        JMS QGETC
        JMS W0018
L0113:
L0112:
        FIM 0,062H
        JMS QLDA
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0117
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0111
L0117:
L0114:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0119
L0118:
        JMS QGETC
        JMS W0018
L0120:
L0119:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0122
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0118
L0122:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0123
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0118
L0123:
L0121:
; IF (CH != 13 && CH != 10) ERROR = 1;
        FIM 0AH,0DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0125
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0124
L0125:
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0126
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0124
L0126:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0124:
; VARS(VARIABLE) = VALUE;
        FIM 0,072H
        JMS QLDA
        JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JMS QADD
        FIM 0,082H
        JMS QLDB
        JMS QSTI
L0104:
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
L0127:
; BLANKS();
        FIM 6,044H
        JMS W0008
        JUN BLANK
L0128:
; LEFT = EXPRESSION();
        FIM 6,046H
        JMS W0017
        JUN EXPRE
L0129:
        FIM 0,0A2H
        JMS QSTA
; OP = TEXT(POS);
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0,0D2H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0002
        LD 7
        JCN 0CH,L0131
        JMS W0020
        LD 7
        JCN 0CH,L0130
        LD 6
        JCN 0CH,L0130
L0131:
        FIM 4,0
        FIM 6,1
        JMS W0006
        FIM 0,092H
        JUN QRETF
L0130:
; POS++;
        JMS W0004
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0E2H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS W0020
        FIM 0AH,03CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0134
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0133
L0134:
        FIM 0AH,03EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0132
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0132
L0133:
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,03DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0132
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0132
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,0E2H
        JMS QSTAC
; POS++;
        JMS W0004
L0132:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0020
        FIM 0AH,03DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0136
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0135
L0136:
        FIM 0AH,03CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0137
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0135
L0137:
        FIM 0AH,03EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0138
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0135
L0138:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0135:
; RIGHT = EXPRESSION();
        FIM 6,048H
        JMS W0017
        JUN EXPRE
L0139:
        FIM 0,0B2H
        JMS QSTA
; NEED('T'); NEED('H'); NEED('E'); NEED('N');
        FIM 4,0
        FIM 6,054H
        JMS W0009
        FIM 6,04AH
        JMS W0010
        JUN NEED
L0140:
        FIM 4,0
        FIM 6,048H
        JMS W0009
        FIM 6,04CH
        JMS W0010
        JUN NEED
L0141:
        FIM 4,0
        FIM 6,045H
        JMS W0009
        FIM 6,04EH
        JMS W0010
        JUN NEED
L0142:
        FIM 4,0
        FIM 6,04EH
        JMS W0009
        FIM 6,050H
        JMS W0010
        JUN NEED
L0143:
; BLANKS();
        FIM 6,052H
        JMS W0008
        JUN BLANK
L0144:
; TARGET = NUMBER();
        FIM 6,054H
        JMS W0011
        JUN NUMBE
L0145:
        FIM 0,0C2H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS W0021
        JMS W0022
        JMS QEQ
        JMS QBOOL
        JMS W0023
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS W0020
        FIM 0AH,03CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0146
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0146
        JMS W0021
        JMS W0022
        JMS QULT
        JCN 0CH,L0149
        FIM 0,0E2H
        JMS QLDA
        LD 7
        JCN 4,L0147
        JMS W0024
        LD 7
        JCN 4,L0147
L0149:
        LDM 1
        JUN L0148
L0147:
        LDM 0
L0148:
        JMS QBOOL
        JMS W0023
L0146:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0020
        FIM 0AH,03EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0150
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0150
        JMS W0021
        JMS W0022
        JMS QUGT
        JCN 0CH,L0153
        FIM 0,0E2H
        JMS QLDA
        LD 7
        JCN 4,L0151
        JMS W0024
        LD 7
        JCN 4,L0151
L0153:
        LDM 1
        JUN L0152
L0151:
        LDM 0
L0152:
        JMS QBOOL
        JMS W0023
L0150:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0002
        LD 7
        JCN 0CH,L0154
        JMS W0024
        LD 7
        JCN 4,L0154
        FIM 0,0C2H
        JMS QLDA
        FIM 0,2
        JMS QSTA
        FIM 6,056H
        FIM 0,0F1H
        JMS QSTAC
        JUN FINDL
L0155:
        JMS W0001
L0154:
        FIM 0,092H
        JUN QRETF
F0013:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,058H
        JMS W0008
        JUN BLANK
L0156:
; CH = TEXT(POS);
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0,013H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 0CH,L0157
        LD 6
        JCN 0CH,L0157
        FIM 4,0
        FIM 6,1
        JMS W0006
        FIM 0,3
        JUN QRETF
L0157:
; POS++;
        JMS W0004
; IF (CH == 'P') PRINTLINE();
        FIM 0,013H
        JMS QLDA
        FIM 0AH,050H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0159
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0159
        FIM 6,05AH
        FIM 0,022H
        JMS QSTAC
        JUN PRINT
L0160:
        JUN L0158
L0159:
; ELSE IF (CH == 'I' && TEXT(POS) == 'F') BRANCH();
        FIM 0AH,049H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0162
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0162
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,046H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0162
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0162
        FIM 6,05CH
        FIM 0,092H
        JMS QSTAC
        JUN BRANC
L0163:
        JUN L0161
L0162:
; ELSE IF (CH == 'I') INPUTVAR();
        FIM 0,013H
        JMS QLDA
        FIM 0AH,049H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0165
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0165
        FIM 6,05EH
        FIM 0,052H
        JMS QSTAC
        JUN INPUT
L0166:
        JUN L0164
L0165:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0168
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0168
; NEED('O'); NEED('T'); NEED('O');
        FIM 4,0
        FIM 6,04FH
        JMS W0009
        FIM 6,060H
        JMS W0010
        JUN NEED
L0169:
        FIM 4,0
        FIM 6,054H
        JMS W0009
        FIM 6,062H
        JMS W0010
        JUN NEED
L0170:
        FIM 4,0
        FIM 6,04FH
        JMS W0009
        FIM 6,064H
        JMS W0010
        JUN NEED
L0171:
; BLANKS();
        FIM 6,066H
        JMS W0008
        JUN BLANK
L0172:
; VALUE = NUMBER();
        FIM 6,068H
        JMS W0011
        JUN NUMBE
L0173:
        FIM 0,033H
        JMS QSTA
; IF (!ERROR) LINE = FINDLINE(VALUE);
        JMS W0002
        LD 7
        JCN 0CH,L0174
        FIM 0,033H
        JMS QLDA
        FIM 0,2
        JMS QSTA
        FIM 6,06AH
        FIM 0,0F1H
        JMS QSTAC
        JUN FINDL
L0175:
        JMS W0001
L0174:
        JUN L0167
L0168:
; ) ELSE IF (CH == 'L') (
        FIM 0AH,04CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0177
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0177
; NEED('E'); NEED('T');
        FIM 4,0
        FIM 6,045H
        JMS W0009
        FIM 6,06CH
        JMS W0010
        JUN NEED
L0178:
        FIM 4,0
        FIM 6,054H
        JMS W0009
        FIM 6,06EH
        JMS W0010
        JUN NEED
L0179:
; BLANKS();
        FIM 6,070H
        JMS W0008
        JUN BLANK
L0180:
; VARIABLE = DESTINATION();
        FIM 6,072H
        JMS W0012
        JUN DESTI
L0181:
        FIM 0,023H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,074H
        JMS W0008
        JUN BLANK
L0182:
        FIM 4,0
        FIM 6,03DH
        JMS W0009
        FIM 6,076H
        JMS W0010
        JUN NEED
L0183:
; VALUE = EXPRESSION();
        FIM 6,078H
        JMS W0017
        JUN EXPRE
L0184:
        FIM 0,033H
        JMS QSTA
; IF (!ERROR) VARS(VARIABLE) = VALUE;
        JMS W0002
        LD 7
        JCN 0CH,L0185
        FIM 0,023H
        JMS QLDA
        JMS QSHL1
        JMS QSHL1
        FIM 8,4
        FIM 0AH,0
        JMS QADD
        FIM 0,033H
        JMS QLDB
        JMS QSTI
L0185:
        JUN L0176
L0177:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0187
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0187
; NEED('N'); NEED('D');
        FIM 4,0
        FIM 6,04EH
        JMS W0009
        FIM 6,07AH
        JMS W0010
        JUN NEED
L0188:
        FIM 4,0
        FIM 6,044H
        JMS W0009
        FIM 6,07CH
        JMS W0010
        JUN NEED
L0189:
; DONE = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,060H
        JMS QSTAC
        JUN L0186
L0187:
; ) ELSE IF (CH == 'R') (
        FIM 0AH,052H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0191
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0191
; NEED('E'); NEED('M');
        FIM 4,0
        FIM 6,045H
        JMS W0009
        FIM 6,07EH
        JMS W0010
        JUN NEED
L0192:
        FIM 4,0
        FIM 6,04DH
        JMS W0009
        FIM 6,080H
        JMS W0010
        JUN NEED
L0193:
; WHILE (TEXT(POS)) POS++;
        JUN L0195
L0194:
        JMS W0004
L0196:
L0195:
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        LD 7
        JCN 0CH,L0194
        LD 6
        JCN 0CH,L0194
L0197:
        JUN L0190
L0191:
; ) ELSE ERROR = 1;
        FIM 4,0
        FIM 6,1
        JMS W0006
L0190:
L0186:
L0176:
L0167:
L0164:
L0161:
L0158:
; BLANKS();
        FIM 6,082H
        JMS W0008
        JUN BLANK
L0198:
; IF (TEXT(POS)) ERROR = 1;
        JMS W0005
        JMS QSHL1
        JMS QLDIC
        LD 7
        JCN 0CH,L0200
        LD 6
        JCN 4,L0199
L0200:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0199:
        FIM 0,3
        JUN QRETF
F0014:
; LOAD
; CHAR CH;
; UNSIGNED LABEL;
; WHILE (!ERROR) (
        JUN L0202
L0201:
; CH = GETCHAR();
        JMS QGETC
        JMS W0025
; WHILE (CH == 13 ?? CH == 10 ?? CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0206
L0205:
        JMS QGETC
        JMS W0025
L0207:
L0206:
        FIM 0AH,0DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0209
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0205
L0209:
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0210
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0205
L0210:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0211
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0205
L0211:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0212
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0205
L0212:
L0208:
; IF (CH == 'R') (
        FIM 0AH,052H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0213
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0213
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0215
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0215
        JMS QGETC
        FIM 0AH,04EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0216
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0214
L0216:
L0215:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0214:
; CH = GETCHAR();
        JMS QGETC
        JMS W0025
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0218
L0217:
        JMS QGETC
        JMS W0025
L0219:
L0218:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0221
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0217
L0221:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0222
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0217
L0222:
L0220:
; IF (CH != 13 && CH != 10) ERROR = 1;
        FIM 0AH,0DH
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0224
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0223
L0224:
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0225
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0223
L0225:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0223:
; RETURN;
        FIM 0,043H
        JUN QRETF
L0213:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,063H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0026
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0227
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0226
L0227:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0226:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0229
L0228:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0027
        FIM 8,019H
        FIM 0AH,099H
        JMS QUGT
        JCN 0CH,L0233
        JMS W0027
        FIM 8,019H
        FIM 0AH,099H
        JMS QEQ
        JCN 4,L0232
        JMS W0026
        FIM 0AH,035H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0232
L0233:
        FIM 4,0
        FIM 6,2
        JMS W0006
L0232:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0027
        JMS QSHL1
        JMS QSHL1
        FIM 0,063H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        FIM 0,053H
        JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JMS QSUB
        FIM 0,063H
        JMS QSTA
; CH = GETCHAR();
        JMS QGETC
        JMS W0025
L0230:
L0229:
        JMS W0026
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0234
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0228
L0234:
L0231:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0235
        FIM 0,043H
        JUN QRETF
L0235:
; IF (CH != ' ' && CH != 9) ERROR = 1;
        JMS W0026
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0237
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0236
L0237:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0238
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0236
L0238:
        FIM 4,0
        FIM 6,1
        JMS W0006
L0236:
; IF (!LABEL ?? COUNT == LINES ?? (COUNT && LABEL <= LABELS(COUNT-1))) E
        JMS W0027
        JMS QTST
        JCN 0CH,$+4
        JUN L0240
        JMS W0028
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0241
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0240
L0241:
        LD 7
        NOP
        JCN 4,$+4
        JUN L0242
        LD 6
        JCN 0CH,$+4
        JUN L0239
L0242:
        JMS QDEC
        JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,0
        JMS QADD
        JMS QLDI
        JMS QXAB
        JMS W0027
        JMS QULE
        JCN 4,L0239
L0240:
        FIM 4,0
        FIM 6,5
        JMS W0006
L0239:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0243
        FIM 0,043H
        JUN QRETF
L0243:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0245
L0244:
        JMS QGETC
        JMS W0025
L0246:
L0245:
        JMS W0026
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0248
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0244
L0248:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0249
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0244
L0249:
L0247:
; LABELS(COUNT) = LABEL;
        JMS W0028
        JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,0
        JMS QADD
        FIM 0,063H
        JMS QLDB
        JMS QSTI
; OFFSETS(COUNT) = USED;
        JMS W0028
        JMS QSHL1
        JMS QSHL1
        FIM 8,3
        FIM 0AH,080H
        JMS QADD
        FIM 0,010H
        JMS QLDB
        JMS QSTI
; WHILE (CH != 13 && CH != 10) (
        JUN L0251
L0250:
; IF (USED >= SPACE-1) ( ERROR = 6; RETURN; )
        JMS W0029
        FIM 8,1
        FIM 0AH,07FH
        JMS QUGE
        JCN 4,L0254
        FIM 4,0
        FIM 6,6
        JMS W0006
        FIM 0,043H
        JUN QRETF
L0254:
; TEXT(USED++) = CH;
        JMS W0029
        FIM 0,073H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,073H
        JMS QLDA
        JMS QSHL1
        FIM 0,053H
        JMS QLDB
        JMS QSTIC
; CH = GETCHAR();
        JMS QGETC
        JMS W0025
L0252:
L0251:
        JMS W0026
        FIM 0AH,0DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0256
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0255
L0256:
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0250
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0250
L0255:
L0253:
; IF (USED >= SPACE) ( ERROR = 6; RETURN; )
        JMS W0029
        FIM 8,1
        FIM 0AH,080H
        JMS QUGE
        JCN 4,L0257
        FIM 4,0
        FIM 6,6
        JMS W0006
        FIM 0,043H
        JUN QRETF
L0257:
; TEXT(USED++) = 0;
        JMS W0029
        FIM 0,073H
        JMS QSTA
        FIM 0,010H
        JMS QINCV
        FIM 0,073H
        JMS QLDA
        JMS QSHL1
        FIM 8,0
        FIM 0AH,0
        JMS QSTIC
; COUNT++;
        FIM 0,040H
        JMS QINCC
L0203:
L0202:
        JMS W0002
        LD 7
        JCN 0CH,$+4
        JUN L0201
L0204:
        FIM 0,043H
        JUN QRETF
        ORG 0BF7H
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0C00H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0006
        JUN L0027
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
        JUN L0062
        JUN L0067
        JUN L0079
        JUN L0080
        JUN L0081
        JUN L0082
        JUN L0083
        JUN L0092
        JUN L0093
        JUN L0095
        JUN L0098
        JUN L0099
        JUN L0100
        JUN L0101
        JUN L0102
        JUN L0103
        JUN L0127
        JUN L0128
        JUN L0129
        JUN L0139
        JUN L0140
        JUN L0141
        JUN L0142
        JUN L0143
        JUN L0144
        JUN L0145
        JUN L0155
        JUN L0156
        JUN L0160
        JUN L0163
        JUN L0166
        JUN L0169
        JUN L0170
        JUN L0171
        JUN L0172
        JUN L0173
        JUN L0175
        JUN L0178
        JUN L0179
        JUN L0180
        JUN L0181
        JUN L0182
        JUN L0183
        JUN L0184
        JUN L0188
        JUN L0189
        JUN L0192
        JUN L0193
        JUN L0198
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0C8CH
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
        ORG 0CEAH
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
        ORG 0D55H
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
        ORG 0D94H
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
        ORG 0DCAH
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
        ORG 0DFBH
W0001: FIM 0,030H
        JUN QSTA
        ORG 0E00H
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
        ORG 0E2CH
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
        ORG 0E50H
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
        ORG 0E6CH
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
        ORG 0E81H
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
        ORG 0E95H
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
        ORG 0EA8H
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
        ORG 0EBAH
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
        ORG 0ECBH
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
        ORG 0EDBH
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
        ORG 0EE9H
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
        ORG 0EF7H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0F00H
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
        ORG 0F0DH
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
        ORG 0F19H
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
        ORG 0F25H
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
        ORG 0F31H
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0F37H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0F3DH
W0002: FIM 0,050H
        JUN QLDA
        ORG 0F41H
W0003: FIM 0,040H
        JUN QLDB
        ORG 0F45H
W0004: FIM 0,020H
        JUN QINCV
        ORG 0F49H
W0005: FIM 0,020H
        JUN QLDA
        ORG 0F4DH
W0006: FIM 0,050H
        JUN QSTAC
        ORG 0F51H
W0007: FIM 0,0D0H
        JUN QLDA
        ORG 0F55H
W0008: FIM 0,090H
        JUN QSTAC
        ORG 0F59H
W0009: FIM 0,0B0H
        JUN QSTAC
        ORG 0F5DH
W0010: FIM 0,0A0H
        JUN QSTAC
        ORG 0F61H
W0011: FIM 0,0C0H
        JUN QSTAC
        ORG 0F65H
W0012: FIM 0,0F0H
        JUN QSTAC
        ORG 0F69H
W0013: FIM 0,061H
        JUN QSTA
        ORG 0F6DH
W0014: FIM 0,061H
        JUN QLDA
        ORG 0F71H
W0015: FIM 0,0B1H
        JUN QSTA
        ORG 0F75H
W0016: FIM 0,0B1H
        JUN QLDA
        ORG 0F79H
W0017: FIM 0,0A1H
        JUN QSTAC
        ORG 0F7DH
W0018: FIM 0,062H
        JUN QSTAC
        ORG 0F81H
W0019: FIM 0,082H
        JUN QLDA
        ORG 0F85H
W0020: FIM 0,0D2H
        JUN QLDA
        ORG 0F89H
W0021: FIM 0,0A2H
        JUN QLDA
        ORG 0F8DH
W0022: FIM 0,0B2H
        JUN QLDB
        ORG 0F91H
W0023: FIM 0,0F2H
        JUN QSTAC
        ORG 0F95H
W0024: FIM 0,0F2H
        JUN QLDA
        ORG 0F99H
W0025: FIM 0,053H
        JUN QSTAC
        ORG 0F9DH
W0026: FIM 0,053H
        JUN QLDA
        ORG 0FA1H
W0027: FIM 0,063H
        JUN QLDA
        ORG 0FA5H
W0028: FIM 0,040H
        JUN QLDA
        ORG 0FA9H
W0029: FIM 0,010H
        JUN QLDA
        ORG 0FADH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        END
