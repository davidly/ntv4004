; CLOCK: COMPILED FROM C BY CC4.PY FOR THE 4040
        ORG 0
        JUN QSTRT
QIPAD:
        NOP
QIVEC:
        JUN QINT
QSTRT:
; CLEAR THE RAM
        LDM 0FH
        XCH 0DH
        JMS QCLR
MAIN:
; MAIN
; INT NOW, SHOWN;
; SHOWN = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,080H
        JMS QSTA
; ??EI();
        EIN
; WHILE (SHOWN < SECONDS) (
        JUN L0002
L0001:
; ??HALT();               /* SLEEP UNTIL THE NEXT INTERRUPT */
        HLT
; ??DI();                 /* READ ALL FOUR NIBBLES OF SECONDS AT ONCE */
        DIN
; NOW = SECONDS;
        FIM 0,020H
        JMS QLDA
        FIM 0,070H
        JMS QSTA
; ??EI();
        EIN
; IF (NOW != SHOWN) (
        FIM 0,080H
        JMS QLDB
        JMS QNE
        JCN 4,L0005
; SHOWN = NOW;
        FIM 0,080H
        JMS QSTA
; ??ROM?OUT(0, SHOWN & 1);    /* A LAMP BLINKS EACH SECOND */
        JMS QAND1
        FIM 0EH,0
        SRC 0EH
        LD 7
        WRR
; PRINTF("%D:%D%D?N", SHOWN / 60, SHOWN % 60 / 10, SHOWN % 10);
        FIM 0,080H
        JMS QLDA
        FIM 8,0
        FIM 0AH,03CH
        JMS QSDIV
        JMS QPRTD
        FIM 4,0
        FIM 6,03AH
        JMS QPUTC
        FIM 0,080H
        JMS QLDA
        FIM 8,0
        FIM 0AH,03CH
        JMS QSMOD
        FIM 8,0
        FIM 0AH,0AH
        JMS QSDIV
        JMS QPRTD
        FIM 0,080H
        JMS QLDA
        FIM 8,0
        FIM 0AH,0AH
        JMS QSMOD
        JMS QPRTD
        FIM 4,0
        FIM 6,0AH
        JMS QPUTC
L0005:
L0003:
L0002:
        FIM 0,080H
        JMS QLDA
        FIM 8,0
        FIM 0AH,0AH
        JMS QSLT
        JCN 0CH,L0001
L0004:
; ??DI();
        DIN
; PUTS("DONE");
        FIM 0,S0001 AND 0FFH
        JMS QS1
; RETURN 0;
        FIM 4,0
        FIM 6,0
        DIN
        JUN QEXIT
TICK:
; TICK
; IF (++TENTHS == 10) (
        FIM 0,010H
        JMS QLDN0
        JMS QINC
        FIM 0,010H
        JMS QSTN0
        FIM 0AH,0AH
        CLC
        LD 7
        SUB 0BH
        JCN 0CH,L0006
; TENTHS = 0;
        FIM 4,0
        FIM 6,0
        FIM 0,010H
        JMS QSTN0
; SECONDS++;
        FIM 0,020H
        JMS QINCV
L0006:
        FIM 0,090H
        JUN QRETF
        ORG 0A1H
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
        ORG 0100H
; RETURN FROM A FUNCTION: R0R1 ADDRESSES ITS RETURN NUMBER, AN OFFSET
; INTO THE TABLE OF JUMPS THAT FOLLOWS ON THIS PAGE.
QRETF:  JMS QLDR
        JIN 2
        NOP
        JUN QINTR
QLDR:   LD 1
        DCL
        SRC 0
        RD2
        XCH 2
        RD3
        XCH 3
        BBL 0
        ORG 010EH
; THE 4040'S INTERRUPT: REGISTER BANK 1 KEEPS THE PROGRAM'S R0-R7; SAVE ITS
; ACCUMULATOR, CARRY, RAM BANK AND R8-R15, CALL THE HANDLER, AND RESTORE THEM.
; BBS RESTORES THE SRC ADDRESS AND REGISTER BANK.
QINT:   SB1
        XCH 7
        TCC
        XCH 6
        LCR
        XCH 5
        FIM 0,030H
        LD 1
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
        FIM 0,040H
        LD 1
        DCL
        SRC 0
        LD 12
        WR0
        LD 13
        WR1
        LD 14
        WR2
        LD 15
        WR3
        FIM 0,050H
        LD 1
        DCL
        SRC 0
        LD 5
        WR0
        LD 6
        WR1
        LD 7
        WR2
        FIM 6,4
        FIM 0,090H
        JMS QSTAC
        JUN TICK
QINTR:
        FIM 0,030H
        LD 1
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
        FIM 0,040H
        LD 1
        DCL
        SRC 0
        RD0
        XCH 12
        RD1
        XCH 13
        RD2
        XCH 14
        RD3
        XCH 15
        FIM 0,050H
        LD 1
        DCL
        SRC 0
        RD0
        XCH 5
        RD1
        XCH 6
        RD2
        XCH 7
        LD 5
        DCL
        LD 6
        RAR
        LD 7
        BBS
        ORG 016CH
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
        ORG 01C1H
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
        ORG 0200H
; SIGNED / AND %: DIVIDE THE MAGNITUDES. THE QUOTIENT IS NEGATIVE WHEN THE
; SIGNS DIFFER (R0), THE REMAINDER WHEN THE DIVIDEND IS NEGATIVE (R1).
QSDIV:  JMS QSPRE
        JMS QUDIV
        LD 0
        JCN 4,QSDX
        JMS QNEG
QSDX:   BBL 0
QSMOD:  JMS QSPRE
        JMS QUDIV
        JMS QREMA
        LD 1
        JCN 4,QSDX
        JMS QNEG
        BBL 0
QSPRE:  LDM 0
        XCH 0
        LDM 0
        XCH 1
        LD 4
        RAL
        JCN 0AH,QSP1
        JMS QNEG
        LDM 1
        XCH 0
        LDM 1
        XCH 1
QSP1:   LD 8
        RAL
        JCN 0AH,QSP2
        LD 8
        CMA
        XCH 8
        LD 9
        CMA
        XCH 9
        LD 10
        CMA
        XCH 10
        LD 11
        CMA
        XCH 11
        ISZ 11,QSP3
        ISZ 10,QSP3
        ISZ 9,QSP3
        INC 8
QSP3:   LD 0
        RAR
        CMC
        TCC
        XCH 0
QSP2:   BBL 0
        ORG 0241H
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
        ORG 026DH
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
        DB 064H,06FH,06EH,065H,0AH,0
        ORG 0287H
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
        ORG 029CH
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
        ORG 02B0H
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
        ORG 02C0H
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
        ORG 02CCH
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
        ORG 02D8H
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
        ORG 02E4H
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
        ORG 02F0H
; A = A & 1.
QAND1:  LD 7
        RAR
        TCC
        XCH 7
        LDM 0
        XCH 6
        LDM 0
        XCH 5
        LDM 0
        XCH 4
        BBL 0
        ORG 02FBH
; THE END OF THE PROGRAM: A JUMP TO ITSELF.
QEXIT:  JUN QEXIT
        ORG 0300H
; A = A % B UNSIGNED.
QUMOD:  JMS QUDIV
QREMA:  LD 12
        XCH 4
        LD 13
        XCH 5
        LD 14
        XCH 6
        LD 15
        XCH 7
        BBL 0
        ORG 030BH
; PRINT THE CHARACTER IN A'S LOW BYTE ON ROM PORT 15, THE CONSOLE.
QPUTC:  FIM 14,0F0H
        SRC 14
        LD 6
        WRR
        LD 7
        WRR
        BBL 0
        ORG 0313H
; INCREMENT THE INT AT R0R1, LEAVING IT IN A.
QINCV:  JMS QLDA
        JMS QINC
        JUN QSTA
        END
