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
L0008:
L0007:
        JMS QSHL1
        JMS QLDIC
        LD 7
        JCN 0CH,L0006
        LD 6
        JCN 0CH,L0006
L0009:
; LINE++;
        FIM 0,030H
        JMS QINCV
; STATEMENT();
        FIM 6,6
        FIM 0,0B2H
        JMS QSTAC
        JUN F0012
L0010:
L0004:
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
        FIM 0,010H
        JMS QLDB
        JMS QULT
        JCN 0CH,L0002
L0011:
L0005:
; IF (ERROR) PRINTF("?ERROR %U?N", ERROR);
        JMS W0002
        LD 7
        JCN 4,L0012
        FIM 0,S0002 AND 0FFH
        JMS QS1
        JMS W0002
        JMS QPRTU
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
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
L0015:
L0014:
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0017
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0013
L0017:
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0018
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0013
L0018:
L0016:
        FIM 0,080H
        JUN QRETF
NEED:
; NEED
; IF (TEXT(POS) != CH) ERROR = 1;
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,0A0H
        JMS QLDB
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0021
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0020
L0021:
        FIM 4,0
        FIM 6,1
        JMS W0005
        JUN L0019
L0020:
; ELSE POS++;
        JMS W0003
L0019:
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
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,0D0H
        JMS QSTAC
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0023
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0022
L0023:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0022:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0025
L0024:
; IF (VALUE > 6553 ?? (VALUE == 6553 && CH > '5')) ERROR = 2;
        JMS W0006
        FIM 8,019H
        FIM 0AH,099H
        JMS QUGT
        JCN 4,$+4
        JUN L0029
        JMS W0006
        FIM 8,019H
        FIM 0AH,099H
        JMS QEQ
        JCN 4,L0028
        FIM 0,0D0H
        JMS QLDA
        FIM 0AH,035H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0028
L0029:
        FIM 4,0
        FIM 6,2
        JMS W0005
L0028:
; VALUE = VALUE * 10 + CH - '0';
        JMS W0006
        JMS QSHL1
        JMS QSHL1
        FIM 0,0C0H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        FIM 0,0D0H
        JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JMS QSUB
        FIM 0,0C0H
        JMS QSTA
; POS++;
        JMS W0003
; CH = TEXT(POS);
        JMS QSHL1
        JMS QLDIC
        FIM 0,0D0H
        JMS QSTAC
L0026:
L0025:
        FIM 0,0D0H
        JMS QLDA
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0030
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,$+4
        JUN L0024
L0030:
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
        JUN BLANK
L0031:
; CH = TEXT(POS);
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,1
        JMS QSTAC
; IF (CH >= 'A' && CH <= 'Z') ( POS++; RETURN CH-'A'; )
        FIM 0AH,041H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0032
        FIM 0AH,05AH
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,L0032
        JMS W0003
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JMS QSUB
        FIM 0,0E0H
        JUN QRETF
L0032:
; IF (CH != '@') ( ERROR = 1; RETURN 0; )
        FIM 0AH,040H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0034
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0033
L0034:
        FIM 4,0
        FIM 6,1
        JMS W0005
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JUN QRETF
L0033:
; POS++; BLANKS(); NEED('('); BLANKS();
        JMS W0003
        FIM 6,0AH
        JMS W0007
        JUN BLANK
L0035:
        FIM 4,0
        FIM 6,028H
        JMS W0008
        FIM 6,0CH
        JMS W0009
        JUN NEED
L0036:
        FIM 6,0EH
        JMS W0007
        JUN BLANK
L0037:
; CH = TEXT(POS);
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,1
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
        JUN L0039
        FIM 0AH,05AH
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,$+4
        JUN L0039
        JMS W0003
        FIM 0,1
        JMS QLDA
        FIM 8,0
        FIM 0AH,041H
        JMS QSUB
        JMS QSHL1
        JMS QSHL1
        FIM 8,6
        FIM 0AH,080H
        JMS QADD
        JMS QLDI
        FIM 0,0F0H
        JMS QSTA
        JUN L0038
L0039:
; ELSE INDEX = NUMBER();
        FIM 6,010H
        JMS W0010
        JUN NUMBE
L0040:
        FIM 0,0F0H
        JMS QSTA
L0038:
; BLANKS(); NEED(')');
        FIM 6,012H
        JMS W0007
        JUN BLANK
L0041:
        FIM 4,0
        FIM 6,029H
        JMS W0008
        FIM 6,014H
        JMS W0009
        JUN NEED
L0042:
; IF (ERROR) RETURN 0;
        JMS W0002
        LD 7
        JCN 4,L0043
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JUN QRETF
L0043:
; IF (INDEX >= CELLS) ( ERROR = 7; RETURN 0; )
        FIM 0,0F0H
        JMS QLDA
        FIM 8,0
        FIM 0AH,040H
        JMS QUGE
        JCN 4,L0044
        FIM 4,0
        FIM 6,7
        JMS W0005
        FIM 4,0
        FIM 6,0
        FIM 0,0E0H
        JUN QRETF
L0044:
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
        JUN BLANK
L0045:
; CH = TEXT(POS);
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,031H
        JMS QSTAC
; IF ((CH >= 'A' && CH <= 'Z') ?? CH == '@') VALUE = VARS(DESTINATION())
        FIM 0AH,041H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0049
        FIM 0AH,05AH
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0048
L0049:
        FIM 0AH,040H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0047
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0047
L0048:
        FIM 6,018H
        FIM 0,0E0H
        JMS QSTAC
        JUN DESTI
L0050:
        JMS QSHL1
        JMS QSHL1
        FIM 8,6
        FIM 0AH,080H
        JMS QADD
        JMS QLDI
        FIM 0,021H
        JMS QSTA
        JUN L0046
L0047:
; ELSE VALUE = NUMBER();
        FIM 6,01AH
        JMS W0010
        JUN NUMBE
L0051:
        FIM 0,021H
        JMS QSTA
L0046:
; BLANKS();
        FIM 6,01CH
        JMS W0007
        JUN BLANK
L0052:
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
L0053:
        JMS W0011
; WHILE (!ERROR && (TEXT(POS) == '*' ?? TEXT(POS) == '/')) (
        JUN L0055
L0054:
; OP = TEXT(POS++);
        JMS W0004
        FIM 0,081H
        JMS QSTA
        JMS W0003
        FIM 0,081H
        JMS QLDA
        JMS QSHL1
        JMS QLDIC
        FIM 0,071H
        JMS QSTAC
; RIGHT = ATOM();
        FIM 6,020H
        FIM 0,011H
        JMS QSTAC
        JUN ATOM
L0058:
        FIM 0,061H
        JMS QSTA
; IF (OP == '*') VALUE = VALUE * RIGHT;
        FIM 0,071H
        JMS QLDA
        FIM 0AH,02AH
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0060
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0060
        JMS W0012
        FIM 0,061H
        JMS QLDB
        JMS QMUL
        JMS W0011
        JUN L0059
L0060:
; ELSE IF (!RIGHT) ERROR = 3;
        FIM 0,061H
        JMS QLDA
        JMS QTST
        JCN 0CH,L0062
        FIM 4,0
        FIM 6,3
        JMS W0005
        JUN L0061
L0062:
; ELSE VALUE = VALUE / RIGHT;
        JMS W0012
        FIM 0,061H
        JMS QLDB
        JMS QUDIV
        JMS W0011
L0061:
L0059:
L0056:
L0055:
        JMS W0002
        LD 7
        JCN 0CH,L0063
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0064
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0054
L0064:
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02FH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0065
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0054
L0065:
L0063:
L0057:
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
L0066:
        JMS W0013
; WHILE (!ERROR && (TEXT(POS) == '+' ?? TEXT(POS) == '-')) (
        JUN L0068
L0067:
; OP = TEXT(POS++);
        JMS W0004
        FIM 0,0D1H
        JMS QSTA
        JMS W0003
        FIM 0,0D1H
        JMS QLDA
        JMS QSHL1
        JMS QLDIC
        FIM 0,0C1H
        JMS QSTAC
; RIGHT = PRODUCT();
        FIM 6,024H
        FIM 0,041H
        JMS QSTAC
        JUN PRODU
L0071:
        FIM 0,0B1H
        JMS QSTA
; IF (OP == '+') VALUE = VALUE + RIGHT;
        FIM 0,0C1H
        JMS QLDA
        FIM 0AH,02BH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0073
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0073
        JMS W0014
        FIM 0,0B1H
        JMS QLDB
        JMS QADD
        JMS W0013
        JUN L0072
L0073:
; ELSE VALUE = VALUE - RIGHT;
        JMS W0014
        FIM 0,0B1H
        JMS QLDB
        JMS QSUB
        JMS W0013
L0072:
L0069:
L0068:
        JMS W0002
        LD 7
        JCN 0CH,L0074
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02BH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0075
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0067
L0075:
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,02DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0076
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0067
L0076:
L0074:
L0070:
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
        JUN L0078
L0077:
; IF (TEXT(I) == TARGET) RETURN I;
        FIM 0,2
        JMS QLDA
        JMS QSHL1
        JMS QLDIC
        FIM 0,0F1H
        JMS QLDB
        JMS QEQ
        JCN 4,L0081
        FIM 0,2
        JMS QLDA
        FIM 0,0E1H
        JUN QRETF
L0081:
; I++;
        JMS W0015
; WHILE (TEXT(I)) I++;
        JUN L0083
L0082:
        JMS W0015
L0084:
L0083:
        JMS QSHL1
        JMS QLDIC
        LD 7
        JCN 4,$+4
        JUN L0082
        LD 6
        JCN 4,$+4
        JUN L0082
L0085:
; I++;
        JMS W0015
L0079:
L0078:
        FIM 0,010H
        JMS QLDB
        JMS QULT
        JCN 4,$+4
        JUN L0077
L0080:
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
        JUN BLANK
L0086:
; IF (TEXT(POS) == '"') (
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,022H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0088
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0088
; POS++;
        JMS W0003
; CH = TEXT(POS);
        JMS QSHL1
        JMS QLDIC
        FIM 0,032H
        JMS QSTAC
; WHILE (CH && CH != '"') (
        JUN L0090
L0089:
; PUTCHAR(CH);
        FIM 0,032H
        JMS QLDA
        JMS QPUTC
; POS++;
        JMS W0003
; CH = TEXT(POS);
        JMS QSHL1
        JMS QLDIC
        FIM 0,032H
        JMS QSTAC
L0091:
L0090:
        LD 7
        JCN 0CH,L0094
        LD 6
        JCN 4,L0093
L0094:
        FIM 0AH,022H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0089
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0089
L0093:
L0092:
; NEED('"');
        FIM 4,0
        FIM 6,022H
        JMS W0008
        FIM 6,028H
        JMS W0009
        JUN NEED
L0095:
        JUN L0087
L0088:
; VALUE = EXPRESSION();
        FIM 6,02AH
        JMS W0017
        JUN EXPRE
L0096:
        FIM 0,022H
        JMS QSTA
; IF (!ERROR) PRINTF("%U", VALUE);
        JMS W0002
        LD 7
        JCN 0CH,L0097
        FIM 0,022H
        JMS QLDA
        JMS QPRTU
L0097:
L0087:
; BLANKS();
        FIM 6,02CH
        JMS W0007
        JUN BLANK
L0098:
; IF (TEXT(POS) == ';') POS++;
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,03BH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0100
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0100
        JMS W0003
        JUN L0099
L0100:
; ELSE PUTCHAR(10);
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
L0099:
        FIM 0,012H
        JUN QRETF
BRANC:
; BRANCH
; UNSIGNED LEFT, RIGHT, TARGET;
; CHAR OP, EQUAL, YES;
; BLANKS();
        FIM 6,02EH
        JMS W0007
        JUN BLANK
L0101:
; LEFT = EXPRESSION();
        FIM 6,030H
        JMS W0017
        JUN EXPRE
L0102:
        FIM 0,052H
        JMS QSTA
; OP = TEXT(POS);
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,082H
        JMS QSTAC
; IF (ERROR ?? !OP) ( ERROR = 1; RETURN; )
        JMS W0002
        LD 7
        JCN 0CH,L0104
        JMS W0018
        LD 7
        JCN 0CH,L0103
        LD 6
        JCN 0CH,L0103
L0104:
        FIM 4,0
        FIM 6,1
        JMS W0005
        FIM 0,042H
        JUN QRETF
L0103:
; POS++;
        JMS W0003
; EQUAL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,092H
        JMS QSTAC
; IF ((OP == '<' ?? OP == '>') && TEXT(POS) == '=') (
        JMS W0018
        FIM 0AH,03CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0107
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0106
L0107:
        FIM 0AH,03EH
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0105
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0105
L0106:
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0AH,03DH
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0105
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0105
; EQUAL = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,092H
        JMS QSTAC
; POS++;
        JMS W0003
L0105:
; IF (OP != '=' && OP != '<' && OP != '>') ERROR = 1;
        JMS W0018
        FIM 0AH,03DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0109
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0108
L0109:
        FIM 0AH,03CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0110
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0108
L0110:
        FIM 0AH,03EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0111
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0108
L0111:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0108:
; RIGHT = EXPRESSION();
        FIM 6,032H
        JMS W0017
        JUN EXPRE
L0112:
        FIM 0,062H
        JMS QSTA
; NEED(':');
        FIM 4,0
        FIM 6,03AH
        JMS W0008
        FIM 6,034H
        JMS W0009
        JUN NEED
L0113:
; BLANKS();
        FIM 6,036H
        JMS W0007
        JUN BLANK
L0114:
; TARGET = NUMBER();
        FIM 6,038H
        JMS W0010
        JUN NUMBE
L0115:
        FIM 0,072H
        JMS QSTA
; YES = LEFT == RIGHT;
        JMS W0019
        JMS W0020
        JMS QEQ
        JMS QBOOL
        JMS W0021
; IF (OP == '<') YES = LEFT < RIGHT ?? (EQUAL && YES);
        JMS W0018
        FIM 0AH,03CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0116
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0116
        JMS W0019
        JMS W0020
        JMS QULT
        JCN 0CH,L0119
        FIM 0,092H
        JMS QLDA
        LD 7
        JCN 4,L0117
        JMS W0022
        LD 7
        JCN 4,L0117
L0119:
        LDM 1
        JUN L0118
L0117:
        LDM 0
L0118:
        JMS QBOOL
        JMS W0021
L0116:
; IF (OP == '>') YES = LEFT > RIGHT ?? (EQUAL && YES);
        JMS W0018
        FIM 0AH,03EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0120
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0120
        JMS W0019
        JMS W0020
        JMS QUGT
        JCN 0CH,L0123
        FIM 0,092H
        JMS QLDA
        LD 7
        JCN 4,L0121
        JMS W0022
        LD 7
        JCN 4,L0121
L0123:
        LDM 1
        JUN L0122
L0121:
        LDM 0
L0122:
        JMS QBOOL
        JMS W0021
L0120:
; IF (!ERROR && YES) LINE = FINDLINE(TARGET);
        JMS W0002
        LD 7
        JCN 0CH,L0124
        JMS W0022
        LD 7
        JCN 4,L0124
        FIM 0,072H
        JMS QLDA
        FIM 0,0F1H
        JMS QSTA
        FIM 6,03AH
        FIM 0,0E1H
        JMS QSTAC
        JUN FINDL
L0125:
        JMS W0001
L0124:
        FIM 0,042H
        JUN QRETF
F0012:
; STATEMENT
; CHAR CH;
; UNSIGNED VARIABLE, VALUE;
; BLANKS();
        FIM 6,03CH
        JMS W0007
        JUN BLANK
L0126:
; CH = TEXT(POS);
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        FIM 0,0C2H
        JMS QSTAC
; IF (!CH) ( ERROR = 1; RETURN; )
        LD 7
        JCN 4,$+4
        JUN L0127
        LD 6
        JCN 0CH,L0127
        FIM 4,0
        FIM 6,1
        JMS W0005
        FIM 0,0B2H
        JUN QRETF
L0127:
; POS++;
        JMS W0003
; IF (CH == 'P') PRINTLINE();
        FIM 0,0C2H
        JMS QLDA
        FIM 0AH,050H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0129
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0129
        FIM 6,03EH
        FIM 0,012H
        JMS QSTAC
        JUN PRINT
L0130:
        JUN L0128
L0129:
; ELSE IF (CH == 'F') BRANCH();
        FIM 0AH,046H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0132
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0132
        FIM 6,040H
        FIM 0,042H
        JMS QSTAC
        JUN BRANC
L0133:
        JUN L0131
L0132:
; ELSE IF (CH == 'G') (
        FIM 0AH,047H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0135
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0135
; BLANKS();
        FIM 6,042H
        JMS W0007
        JUN BLANK
L0136:
; VALUE = NUMBER();
        FIM 6,044H
        JMS W0010
        JUN NUMBE
L0137:
        FIM 0,0E2H
        JMS QSTA
; IF (!ERROR) LINE = FINDLINE(VALUE);
        JMS W0002
        LD 7
        JCN 0CH,L0138
        FIM 0,0E2H
        JMS QLDA
        FIM 0,0F1H
        JMS QSTA
        FIM 6,046H
        FIM 0,0E1H
        JMS QSTAC
        JUN FINDL
L0139:
        JMS W0001
L0138:
        JUN L0134
L0135:
; ) ELSE IF (CH == 'L') (
        FIM 0AH,04CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0141
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0141
; BLANKS();
        FIM 6,048H
        JMS W0007
        JUN BLANK
L0142:
; VARIABLE = DESTINATION();
        FIM 6,04AH
        FIM 0,0E0H
        JMS QSTAC
        JUN DESTI
L0143:
        FIM 0,0D2H
        JMS QSTA
; BLANKS(); NEED('=');
        FIM 6,04CH
        JMS W0007
        JUN BLANK
L0144:
        FIM 4,0
        FIM 6,03DH
        JMS W0008
        FIM 6,04EH
        JMS W0009
        JUN NEED
L0145:
; VALUE = EXPRESSION();
        FIM 6,050H
        JMS W0017
        JUN EXPRE
L0146:
        FIM 0,0E2H
        JMS QSTA
; IF (!ERROR) VARS(VARIABLE) = VALUE;
        JMS W0002
        LD 7
        JCN 0CH,L0147
        FIM 0,0D2H
        JMS QLDA
        JMS QSHL1
        JMS QSHL1
        FIM 8,6
        FIM 0AH,080H
        JMS QADD
        FIM 0,0E2H
        JMS QLDB
        JMS QSTI
L0147:
        JUN L0140
L0141:
; ) ELSE IF (CH == 'E') (
        FIM 0AH,045H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0149
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0149
; DONE = 1;
        FIM 4,0
        FIM 6,1
        FIM 0,060H
        JMS QSTAC
        JUN L0148
L0149:
; ) ELSE IF (CH == 'R') (
        FIM 0AH,052H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0151
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0151
; WHILE (TEXT(POS)) POS++;
        JUN L0153
L0152:
        JMS W0003
L0154:
L0153:
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        LD 7
        JCN 4,$+4
        JUN L0152
        LD 6
        JCN 4,$+4
        JUN L0152
L0155:
        JUN L0150
L0151:
; ) ELSE ERROR = 1;
        FIM 4,0
        FIM 6,1
        JMS W0005
L0150:
L0148:
L0140:
L0134:
L0131:
L0128:
; BLANKS();
        FIM 6,052H
        JMS W0007
        JUN BLANK
L0156:
; IF (TEXT(POS)) ERROR = 1;
        JMS W0004
        JMS QSHL1
        JMS QLDIC
        LD 7
        JCN 0CH,L0158
        LD 6
        JCN 4,L0157
L0158:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0157:
        FIM 0,0B2H
        JUN QRETF
RNEED:
; RNEED
; IF (GETCHAR() != CH) ERROR = 1;
        JMS QGETC
        FIM 0,3
        JMS QLDB
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0160
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0159
L0160:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0159:
        FIM 0,0F2H
        JUN QRETF
F0014:
; SAVE
; IF (USED >= SPACE) ERROR = 6;
        JMS W0016
        FIM 8,3
        FIM 0AH,040H
        JMS QUGE
        JCN 4,L0162
        FIM 4,0
        FIM 6,6
        JMS W0005
        JUN L0161
L0162:
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
L0161:
        FIM 0,013H
        JUN QRETF
PACKE:
; PACKEDLINE
; CHAR CH, NEXT, QUOTED;
; IF (COMMAND == 'L') ( RNEED('E'); RNEED('T'); )
        JMS W0023
        FIM 0AH,04CH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0164
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0164
        FIM 4,0
        FIM 6,045H
        JMS W0024
        FIM 6,054H
        JMS W0025
        JUN RNEED
L0165:
        FIM 4,0
        FIM 6,054H
        JMS W0024
        FIM 6,056H
        JMS W0025
        JUN RNEED
L0166:
        JUN L0163
L0164:
; ELSE IF (COMMAND == 'P') ( RNEED('R'); RNEED('I'); RNEED('N'); RNEED('
        FIM 0AH,050H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0168
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0168
        FIM 4,0
        FIM 6,052H
        JMS W0024
        FIM 6,058H
        JMS W0025
        JUN RNEED
L0169:
        FIM 4,0
        FIM 6,049H
        JMS W0024
        FIM 6,05AH
        JMS W0025
        JUN RNEED
L0170:
        FIM 4,0
        FIM 6,04EH
        JMS W0024
        FIM 6,05CH
        JMS W0025
        JUN RNEED
L0171:
        FIM 4,0
        FIM 6,054H
        JMS W0024
        FIM 6,05EH
        JMS W0025
        JUN RNEED
L0172:
        JUN L0167
L0168:
; ELSE IF (COMMAND == 'I') ( RNEED('F'); COMMAND = 'F'; )
        FIM 0AH,049H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0174
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0174
        FIM 4,0
        FIM 6,046H
        JMS W0024
        FIM 6,060H
        JMS W0025
        JUN RNEED
L0175:
        FIM 4,0
        FIM 6,046H
        FIM 0,053H
        JMS QSTAC
        JUN L0173
L0174:
; ELSE IF (COMMAND == 'G') ( RNEED('O'); RNEED('T'); RNEED('O'); )
        FIM 0AH,047H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0177
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0177
        FIM 4,0
        FIM 6,04FH
        JMS W0024
        FIM 6,062H
        JMS W0025
        JUN RNEED
L0178:
        FIM 4,0
        FIM 6,054H
        JMS W0024
        FIM 6,064H
        JMS W0025
        JUN RNEED
L0179:
        FIM 4,0
        FIM 6,04FH
        JMS W0024
        FIM 6,066H
        JMS W0025
        JUN RNEED
L0180:
        JUN L0176
L0177:
; ELSE IF (COMMAND == 'E') ( RNEED('N'); RNEED('D'); )
        FIM 0AH,045H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0182
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0182
        FIM 4,0
        FIM 6,04EH
        JMS W0024
        FIM 6,068H
        JMS W0025
        JUN RNEED
L0183:
        FIM 4,0
        FIM 6,044H
        JMS W0024
        FIM 6,06AH
        JMS W0025
        JUN RNEED
L0184:
        JUN L0181
L0182:
; ELSE IF (COMMAND == 'R') ( RNEED('E'); RNEED('M'); )
        FIM 0AH,052H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0186
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0186
        FIM 4,0
        FIM 6,045H
        JMS W0024
        FIM 6,06CH
        JMS W0025
        JUN RNEED
L0187:
        FIM 4,0
        FIM 6,04DH
        JMS W0024
        FIM 6,06EH
        JMS W0025
        JUN RNEED
L0188:
        JUN L0185
L0186:
; ELSE ERROR = 1;
        FIM 4,0
        FIM 6,1
        JMS W0005
L0185:
L0181:
L0176:
L0173:
L0167:
L0163:
; SAVE(COMMAND);
        JMS W0023
        JMS W0026
        FIM 6,070H
        JMS W0027
        JUN F0014
L0189:
; QUOTED = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,083H
        JMS QSTAC
; CH = GETCHAR();
        JMS QGETC
        JMS W0028
; WHILE (!ERROR && CH != 13 && CH != 10) (
        JUN L0191
L0190:
; IF (!QUOTED && COMMAND == 'F' && CH == 'T') (
        JMS W0029
        LD 7
        JCN 4,$+4
        JUN L0195
        LD 6
        JCN 4,$+4
        JUN L0195
        JMS W0023
        FIM 0AH,046H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0195
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0195
        JMS W0030
        FIM 0AH,054H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0195
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0195
; NEXT = GETCHAR();
        JMS QGETC
        FIM 0,073H
        JMS QSTAC
; IF (NEXT == 'H') (
        FIM 0AH,048H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0197
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0197
; RNEED('E'); RNEED('N'); SAVE(':');
        FIM 4,0
        FIM 6,045H
        JMS W0024
        FIM 6,072H
        JMS W0025
        JUN RNEED
L0198:
        FIM 4,0
        FIM 6,04EH
        JMS W0024
        FIM 6,074H
        JMS W0025
        JUN RNEED
L0199:
        FIM 4,0
        FIM 6,03AH
        JMS W0026
        FIM 6,076H
        JMS W0027
        JUN F0014
L0200:
; CH = GETCHAR();
        JMS QGETC
        JMS W0028
        JUN L0196
L0197:
; SAVE('T'); CH = NEXT;
        FIM 4,0
        FIM 6,054H
        JMS W0026
        FIM 6,078H
        JMS W0027
        JUN F0014
L0201:
        FIM 0,073H
        JMS QLDA
        JMS W0028
L0196:
        JUN L0194
L0195:
; IF (!CH ?? (!QUOTED && CH == ':')) ERROR = 1;
        JMS W0030
        LD 7
        JCN 0CH,L0204
        LD 6
        JCN 0CH,$+4
        JUN L0203
L0204:
        JMS W0029
        LD 7
        JCN 4,$+4
        JUN L0202
        LD 6
        JCN 4,$+4
        JUN L0202
        JMS W0030
        FIM 0AH,03AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0202
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0202
L0203:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0202:
; IF (CH == '"') QUOTED = 1-QUOTED;
        JMS W0030
        FIM 0AH,022H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0205
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,L0205
        FIM 4,0
        FIM 6,1
        FIM 0,083H
        JMS QLDB
        JMS QSUB
        FIM 0,083H
        JMS QSTAC
L0205:
; IF (QUOTED ?? CH > ' ') SAVE(CH);
        JMS W0029
        LD 7
        JCN 0CH,L0207
        LD 6
        JCN 0CH,L0207
        JMS W0030
        FIM 0AH,020H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0206
L0207:
        JMS W0030
        JMS W0026
        FIM 6,07AH
        JMS W0027
        JUN F0014
L0208:
L0206:
; CH = GETCHAR();
        JMS QGETC
        JMS W0028
L0194:
L0192:
L0191:
        JMS W0002
        LD 7
        JCN 0CH,L0209
        JMS W0030
        FIM 0AH,0DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0210
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0209
L0210:
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0190
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0190
L0209:
L0193:
; SAVE(0);
        FIM 4,0
        FIM 6,0
        JMS W0026
        FIM 6,07CH
        JMS W0027
        JUN F0014
L0211:
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
        JUN L0213
L0212:
; CH = GETCHAR();
        JMS QGETC
        JMS W0031
; WHILE (CH == 13 ?? CH == 10 ?? CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0217
L0216:
        JMS QGETC
        JMS W0031
L0218:
L0217:
        FIM 0AH,0DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0220
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0216
L0220:
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0221
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0216
L0221:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0222
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0216
L0222:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0223
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0216
L0223:
L0219:
; IF (CH == 'R') (
        FIM 0AH,052H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0224
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0224
; IF (GETCHAR() != 'U' ?? GETCHAR() != 'N') ERROR = 1;
        JMS QGETC
        FIM 0AH,055H
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0226
        CLC
        LD 6
        SUB 0AH
        JCN 4,$+4
        JUN L0226
        JMS QGETC
        FIM 0AH,04EH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0227
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0225
L0227:
L0226:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0225:
; CH = GETCHAR();
        JMS QGETC
        JMS W0031
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0229
L0228:
        JMS QGETC
        JMS W0031
L0230:
L0229:
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0232
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0228
L0232:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0233
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0228
L0233:
L0231:
; IF (CH != 13 && CH != 10) ERROR = 1;
        FIM 0AH,0DH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0235
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0234
L0235:
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0236
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0234
L0236:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0234:
; RETURN;
        FIM 0,093H
        JUN QRETF
L0224:
; LABEL = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,0B3H
        JMS QSTA
; IF (CH < '0' ?? CH > '9') ERROR = 1;
        JMS W0032
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 0AH,L0238
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0237
L0238:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0237:
; WHILE (CH >= '0' && CH <= '9') (
        JUN L0240
L0239:
; IF (LABEL > 6553 ?? (LABEL == 6553 && CH > '5')) ERROR = 2;
        JMS W0033
        FIM 8,019H
        FIM 0AH,099H
        JMS QUGT
        JCN 0CH,L0244
        JMS W0033
        FIM 8,019H
        FIM 0AH,099H
        JMS QEQ
        JCN 4,L0243
        JMS W0032
        FIM 0AH,035H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 2,L0243
L0244:
        FIM 4,0
        FIM 6,2
        JMS W0005
L0243:
; LABEL = LABEL * 10 + CH - '0';
        JMS W0033
        JMS QSHL1
        JMS QSHL1
        FIM 0,0B3H
        JMS QLDB
        JMS QADD
        JMS QSHL1
        FIM 0,0A3H
        JMS QLDB
        JMS QADD
        FIM 8,0
        FIM 0AH,030H
        JMS QSUB
        FIM 0,0B3H
        JMS QSTA
; CH = GETCHAR();
        JMS QGETC
        JMS W0031
L0241:
L0240:
        JMS W0032
        FIM 0AH,030H
        CLC
        LD 7
        SUB 0BH
        CMC
        LD 6
        SUB 0AH
        JCN 2,$+4
        JUN L0245
        FIM 0AH,039H
        CLC
        LD 0BH
        SUB 7
        CMC
        LD 0AH
        SUB 6
        JCN 0AH,$+4
        JUN L0239
L0245:
L0242:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0246
        FIM 0,093H
        JUN QRETF
L0246:
; IF (CH != ' ' && CH != 9) ERROR = 1;
        JMS W0032
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0248
        CLC
        LD 6
        SUB 0AH
        JCN 0CH,$+4
        JUN L0247
L0248:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 4,$+4
        JUN L0249
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0247
L0249:
        FIM 4,0
        FIM 6,1
        JMS W0005
L0247:
; IF (!LABEL ?? LABEL > 255 ?? LABEL <= PREVIOUS) ERROR = 5;
        JMS W0033
        JMS QTST
        JCN 4,L0251
        FIM 8,0
        FIM 0AH,0FFH
        JMS QUGT
        JCN 0CH,L0251
        JMS W0033
        FIM 0,0C3H
        JMS QLDB
        JMS QULE
        JCN 4,L0250
L0251:
        FIM 4,0
        FIM 6,5
        JMS W0005
L0250:
; IF (ERROR) RETURN;
        JMS W0002
        LD 7
        JCN 4,L0252
        FIM 0,093H
        JUN QRETF
L0252:
; WHILE (CH == ' ' ?? CH == 9) CH = GETCHAR();
        JUN L0254
L0253:
        JMS QGETC
        JMS W0031
L0255:
L0254:
        JMS W0032
        FIM 0AH,020H
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0257
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0253
L0257:
        FIM 0AH,9
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0258
        CLC
        LD 6
        SUB 0AH
        JCN 4,L0253
L0258:
L0256:
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
L0259:
; PACKEDLINE(CH);
        JMS W0032
        FIM 0,053H
        JMS QSTAC
        FIM 6,080H
        FIM 0,043H
        JMS QSTAC
        JUN PACKE
L0260:
; COUNT++;
        FIM 0,040H
        JMS QINCC
L0214:
L0213:
        JMS W0002
        LD 7
        JCN 0CH,$+4
        JUN L0212
L0215:
        FIM 0,093H
        JUN QRETF
        ORG 0BB4H
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
        ORG 0BF3H
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
        ORG 0C00H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN L0001
        JUN L0010
        JUN L0031
        JUN L0035
        JUN L0036
        JUN L0037
        JUN L0040
        JUN L0041
        JUN L0042
        JUN L0045
        JUN L0050
        JUN L0051
        JUN L0052
        JUN L0053
        JUN L0058
        JUN L0066
        JUN L0071
        JUN L0086
        JUN L0095
        JUN L0096
        JUN L0098
        JUN L0101
        JUN L0102
        JUN L0112
        JUN L0113
        JUN L0114
        JUN L0115
        JUN L0125
        JUN L0126
        JUN L0130
        JUN L0133
        JUN L0136
        JUN L0137
        JUN L0139
        JUN L0142
        JUN L0143
        JUN L0144
        JUN L0145
        JUN L0146
        JUN L0156
        JUN L0165
        JUN L0166
        JUN L0169
        JUN L0170
        JUN L0171
        JUN L0172
        JUN L0175
        JUN L0178
        JUN L0179
        JUN L0180
        JUN L0183
        JUN L0184
        JUN L0187
        JUN L0188
        JUN L0189
        JUN L0198
        JUN L0199
        JUN L0200
        JUN L0201
        JUN L0208
        JUN L0211
        JUN L0259
        JUN L0260
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 0C8AH
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
        ORG 0D8BH
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
        ORG 0DBCH
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
        ORG 0DE8H
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
        ORG 0E00H
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
        ORG 0E25H
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
        ORG 0E41H
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
        ORG 0E55H
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
        ORG 0E67H
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
        ORG 0E78H
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
        ORG 0E88H
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
        ORG 0E96H
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
        ORG 0EA4H
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
        ORG 0EB0H
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
        ORG 0EBCH
; A = THE ACCUMULATOR, 0 OR 1.
QBOOL:  XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 0EC4H
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0ECCH
; INCREMENT THE CHAR AT R0R1, LEAVING IT IN A.
QINCC:  JMS QLDA
        JMS QINC
        JUN QSTAC
        ORG 0ED2H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        ORG 0ED8H
W0001: FIM 0,030H
        JUN QSTA
        ORG 0EDCH
W0002: FIM 0,050H
        JUN QLDA
        ORG 0EE0H
W0003: FIM 0,020H
        JUN QINCV
        ORG 0EE4H
W0004: FIM 0,020H
        JUN QLDA
        ORG 0EE8H
W0005: FIM 0,050H
        JUN QSTAC
        ORG 0EECH
W0006: FIM 0,0C0H
        JUN QLDA
        ORG 0EF0H
W0007: FIM 0,080H
        JUN QSTAC
        ORG 0EF4H
W0008: FIM 0,0A0H
        JUN QSTAC
        ORG 0EF8H
W0009: FIM 0,090H
        JUN QSTAC
        ORG 0EFCH
W0010: FIM 0,0B0H
        JUN QSTAC
        ORG 0F00H
W0011: FIM 0,051H
        JUN QSTA
        ORG 0F04H
W0012: FIM 0,051H
        JUN QLDA
        ORG 0F08H
W0013: FIM 0,0A1H
        JUN QSTA
        ORG 0F0CH
W0014: FIM 0,0A1H
        JUN QLDA
        ORG 0F10H
W0015: FIM 0,2
        JUN QINCV
        ORG 0F14H
W0016: FIM 0,010H
        JUN QLDA
        ORG 0F18H
W0017: FIM 0,091H
        JUN QSTAC
        ORG 0F1CH
W0018: FIM 0,082H
        JUN QLDA
        ORG 0F20H
W0019: FIM 0,052H
        JUN QLDA
        ORG 0F24H
W0020: FIM 0,062H
        JUN QLDB
        ORG 0F28H
W0021: FIM 0,0A2H
        JUN QSTAC
        ORG 0F2CH
W0022: FIM 0,0A2H
        JUN QLDA
        ORG 0F30H
W0023: FIM 0,053H
        JUN QLDA
        ORG 0F34H
W0024: FIM 0,3
        JUN QSTAC
        ORG 0F38H
W0025: FIM 0,0F2H
        JUN QSTAC
        ORG 0F3CH
W0026: FIM 0,023H
        JUN QSTAC
        ORG 0F40H
W0027: FIM 0,013H
        JUN QSTAC
        ORG 0F44H
W0028: FIM 0,063H
        JUN QSTAC
        ORG 0F48H
W0029: FIM 0,083H
        JUN QLDA
        ORG 0F4CH
W0030: FIM 0,063H
        JUN QLDA
        ORG 0F50H
W0031: FIM 0,0A3H
        JUN QSTAC
        ORG 0F54H
W0032: FIM 0,0A3H
        JUN QLDA
        ORG 0F58H
W0033: FIM 0,0B3H
        JUN QLDA
        END
