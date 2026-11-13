/* A small, native 4004 BASIC interpreter. Source is read over the console;
   there is no host-side BASIC parser or translation to machine code. */
#include <stdio.h>
#ifdef LARGE
#define SPACE 832
#define LINES 255
#define CELLS 64
char text[SPACE];
unsigned vars[26+CELLS];
#else
#define SPACE 384
#define LINES 32
#define CELLS 200
char text[SPACE];
unsigned labels[LINES], offsets[LINES], vars[26+CELLS];
#endif

unsigned used, pos;
#ifdef LARGE
unsigned line;
#else
char line;              /* At most 32 stored lines. */
char command[48];
char quitting;
#endif
char count, error, done, interactive;

#ifdef LARGE
/* Packed source has no whitespace outside string literals. */
#define blanks()
#else
void blanks()
{
    while (text[pos] == ' ' || text[pos] == 9) pos++;
}
#endif

void need(char ch)
{
    if (text[pos] != ch) error = 1;
    else pos++;
}

unsigned number()
{
    unsigned value;
    char ch;
#ifdef LARGE
    ch = text[pos++];
    if (ch >= 128) return ch-128;
    if (ch == 3) { error = 2; return 0; }
    if (ch != 1 && ch != 2) { error = 1; return 0; }
    value = text[pos++]-128;
    if (ch == 2) value = value*128 + text[pos++]-128;
    return value*128 + text[pos++]-128;
#else
    value = 0;
    ch = text[pos];
    if (ch < '0' || ch > '9') error = 1;
    while (ch >= '0' && ch <= '9') {
        if (value > 6553 || (value == 6553 && ch > '5')) error = 2;
        value = value * 10 + ch - '0';
        pos++;
        ch = text[pos];
    }
    return value;
#endif
}

/* A-Z are scalar slots; @(0)..@(199) share the remaining word slots.
   Array subscripts are a literal or a scalar variable, not an expression. */
unsigned destination()
{
    unsigned index;
    char ch;
    /* Callers have already consumed leading whitespace. */
    ch = text[pos];
    if (ch >= 'A' && ch <= 'Z') { pos++; return ch-'A'; }
    if (ch != '@') { error = 1; return 0; }
    pos++; blanks(); need('('); blanks();
    ch = text[pos];
    if (ch >= 'A' && ch <= 'Z') { pos++; index = vars[ch-'A']; }
    else index = number();
    blanks(); need(')');
    if (error) return 0;
    if (index >= CELLS) { error = 7; return 0; }
    return index+26;
}

unsigned atom()
{
    unsigned value;
    char ch;
    blanks();
    ch = text[pos];
    if (ch >= 'A' && ch <= 'Z') { pos++; value = vars[ch-'A']; }
    else if (ch == '@') value = vars[destination()];
    else value = number();
    blanks();
    return value;
}

unsigned product()
{
    unsigned value, right;
    char op;
    value = atom();
    while (!error && (text[pos] == '*' || text[pos] == '/')) {
        op = text[pos++];
        right = atom();
        if (op == '*') value = value * right;
        else if (!right) error = 3;
        else value = value / right;
    }
    return value;
}

unsigned expression()
{
    unsigned value, right;
    char op;
    value = product();
    while (!error && (text[pos] == '+' || text[pos] == '-')) {
        op = text[pos++];
        right = product();
        if (op == '+') value = value + right;
        else value = value - right;
    }
    return value;
}

#ifdef LARGE
/* Branch cache uses status registers, leaving main RAM for source and data.
   This profile loads one program and runs it once. Zero is not a line number. */
char cached_target0; unsigned cached_offset0;
char cached_target1; unsigned cached_offset1;
char cached_target2; unsigned cached_offset2;
char cached_target3; unsigned cached_offset3;
char cached_target4; unsigned cached_offset4;
char cached_target5; unsigned cached_offset5;
char cached_target6; unsigned cached_offset6;
char cached_target7; unsigned cached_offset7;
__nibble cache_next;
unsigned findline(unsigned target)
{
    unsigned i;
    char key;
    if (!target || target > 255) { error = 4; return used; }
    key = target;
    if (key == cached_target0) return cached_offset0;
    if (key == cached_target1) return cached_offset1;
    if (key == cached_target2) return cached_offset2;
    if (key == cached_target3) return cached_offset3;
    if (key == cached_target4) return cached_offset4;
    if (key == cached_target5) return cached_offset5;
    if (key == cached_target6) return cached_offset6;
    if (key == cached_target7) return cached_offset7;
    i = 0;
    while (i < used) {
        if (text[i] == target) {
        if (cache_next == 0) { cached_target0 = key; cached_offset0 = i; }
        else if (cache_next == 1) { cached_target1 = key; cached_offset1 = i; }
        else if (cache_next == 2) { cached_target2 = key; cached_offset2 = i; }
        else if (cache_next == 3) { cached_target3 = key; cached_offset3 = i; }
        else if (cache_next == 4) { cached_target4 = key; cached_offset4 = i; }
        else if (cache_next == 5) { cached_target5 = key; cached_offset5 = i; }
        else if (cache_next == 6) { cached_target6 = key; cached_offset6 = i; }
        else if (cache_next == 7) { cached_target7 = key; cached_offset7 = i; }
        cache_next = (cache_next+1) & 7;
        return i;
        }
        i++;
        while (text[i]) i++;
        i++;
    }
    error = 4;
    return used;
}
#else
unsigned findline(unsigned target)
{
    char i;
    i = 0;
    while (i < count && labels[i] != target) i++;
    if (i == count) error = 4;
    return i;
}

#endif

void printline()
{
    unsigned value;
    char ch;
#ifndef LARGE
    need('R'); need('I'); need('N'); need('T');
#endif
    blanks();
    if (text[pos] == '"') {
        pos++;
        ch = text[pos];
        while (ch && ch != '"') {
            putchar(ch);
            pos++;
            ch = text[pos];
        }
        need('"');
    } else {
        value = expression();
        if (!error) printf("%u", value);
    }
    blanks();
    if (text[pos] == ';') pos++;
    else putchar(10);
}

#ifndef LARGE
void inputvar()
{
    char ch;
    unsigned variable, value;
    need('N'); need('P'); need('U'); need('T'); blanks();
    variable = destination();
    if (!error) {
        value = 0;
        putchar('?'); putchar(' ');
        ch = getchar();
        while (ch <= ' ') ch = getchar();
        if (ch < '0' || ch > '9') error = 1;
        while (ch >= '0' && ch <= '9') {
            if (value > 6553 || (value == 6553 && ch > '5')) error = 2;
            value = value * 10 + ch - '0';
            ch = getchar();
        }
        while (ch == ' ' || ch == 9) ch = getchar();
        if (ch != 13 && ch != 10) error = 1;
        if (!error) vars[variable] = value;
        if (interactive) while (ch != 13 && ch != 10) ch = getchar();
    }
}

#endif

void branch()
{
    unsigned left, right, target;
    char op, equal, yes;
#ifndef LARGE
    need('F');
#endif
    blanks();
    left = expression();
    op = text[pos];
    if (error || !op) { error = 1; return; }
    pos++;
    equal = 0;
    if ((op == '<' || op == '>') && text[pos] == '=') {
        equal = 1;
        pos++;
    }
    if (op != '=' && op != '<' && op != '>') error = 1;
    right = expression();
#ifdef LARGE
    need(':');
#else
    need('T'); need('H'); need('E'); need('N');
#endif
    blanks();
    target = number();
    yes = left == right;
    if (op == '<') yes = left < right || (equal && yes);
    if (op == '>') yes = left > right || (equal && yes);
    if (!error && yes) line = findline(target);
}

void statement()
{
    char ch;
    unsigned variable, value;
    blanks();
    ch = text[pos];
    if (!ch) { error = 1; return; }
    pos++;
    if (ch == 'P') printline();
#ifdef LARGE
    else if (ch == 'F') branch();
#else
    else if (ch == 'I' && text[pos] == 'F') branch();
    else if (ch == 'I') inputvar();
#endif
    else if (ch == 'G') {
#ifndef LARGE
        need('O'); need('T'); need('O');
#endif
        blanks();
        value = number();
        if (!error) line = findline(value);
    } else if (ch == 'L') {
#ifndef LARGE
        need('E'); need('T');
#endif
        blanks();
        variable = destination();
        blanks(); need('=');
        value = expression();
        if (!error) vars[variable] = value;
    } else if (ch == 'E') {
#ifndef LARGE
        need('N'); need('D');
#endif
        done = 1;
    } else if (ch == 'R') {
#ifndef LARGE
        need('E'); need('M');
#endif
        while (text[pos]) pos++;
    } else error = 1;
    blanks();
    if (text[pos]) error = 1;
}

#ifdef LARGE
void rneed(char ch)
{
    if (getchar() != ch) error = 1;
}

void save(char ch)
{
    if (used >= SPACE) error = 6;
    else text[used++] = ch;
}

/* Nonzero integer tokens keep NUL exclusively as the line terminator.
   128..255 encode 0..127; 1/2 prefix two/three base-128 digits.
   Token 3 defers an overflowing literal's error until it is executed. */
char packnumber(char ch)
{
    unsigned value;
    char overflow;
    value = 0; overflow = 0;
    do {
        if (value > 6553 || (value == 6553 && ch > '5')) overflow = 1;
        value = value*10 + ch-'0';
        ch = getchar();
        while (ch == ' ' || ch == 9) ch = getchar();
    } while (ch >= '0' && ch <= '9');
    if (overflow) save(3);
    else if (value < 128) save(value+128);
    else {
        if (value < 16384) save(1);
        else { save(2); save(128+(value >> 14)); }
        save(128+((value >> 7) & 127));
        save(128+(value & 127));
    }
    return ch;
}

void packedline(char command)
{
    char ch, next, quoted;
    if (command == 'L') { rneed('E'); rneed('T'); }
    else if (command == 'P') { rneed('R'); rneed('I'); rneed('N'); rneed('T'); }
    else if (command == 'I') { rneed('F'); command = 'F'; }
    else if (command == 'G') { rneed('O'); rneed('T'); rneed('O'); }
    else if (command == 'E') { rneed('N'); rneed('D'); }
    else if (command == 'R') { rneed('E'); rneed('M'); }
    else error = 1;
    save(command);
    quoted = 0;
    ch = getchar();
    while (!error && ch != 13 && ch != 10) {
        if (!quoted && command != 'R' && ch >= '0' && ch <= '9') {
            ch = packnumber(ch);
        } else if (!quoted && command == 'F' && ch == 'T') {
            next = getchar();
            if (next == 'H') {
                rneed('E'); rneed('N'); save(':');
                ch = getchar();
            } else {
                save('T'); ch = next;
            }
        } else {
            if (!ch || (!quoted && ch == ':')) error = 1;
            if (ch == '"') quoted = 1-quoted;
            if (quoted || ch > ' ') save(ch);
            ch = getchar();
        }
    }
    save(0);
}
#endif

void runprogram()
{
#ifdef LARGE
    while (!error && !done && line < used) {
        pos = line+1;
        /* A taken branch supplies its own offset. Otherwise statement()
           leaves pos at this line's terminator. */
        line = used;
#else
    while (!error && !done && line < count) {
        pos = offsets[line++];
#endif
        statement();
#ifdef LARGE
        if (line == used) line = pos+1;
#endif
    }
}

#ifndef LARGE
/* Reuse the existing statement parser without overwriting a full program.
   Every console parse swaps the saved source back, including error paths. */
void swapline()
{
    char i, ch;
    for (i = 0; i < 48; i++) {
        ch = command[i]; command[i] = text[i]; text[i] = ch;
    }
}

void clearvars()
{
    unsigned i;
    for (i = 0; i < 26+CELLS; i++) vars[i] = 0;
}

_Bool consoleline(char ch)
{
    char length, i, action;
    length = 0;
    while (ch != 13 && ch != 10) {
        if (length < 47) command[length++] = ch;
        else error = 6;
        ch = getchar();
    }
    command[length] = 0;
    if (error) return 0;
    swapline();
    pos = 0; ch = text[pos++]; action = ch;
    if (ch == 'R' && text[pos] == 'U') { need('U'); need('N'); }
    else if (ch == 'N') { need('E'); need('W'); }
    else if (ch == 'B') { need('Y'); need('E'); }
    else if (ch == 'L' && text[pos] == 'I') { need('I'); need('S'); need('T'); }
    else {
        pos--; action = 0; line = count;
        statement();
    }
    blanks(); if (text[pos]) error = 1;
    swapline();
    if (!error) {
        if (action == 'R') return 1;
        if (action == 'B') { quitting = 1; return 1; }
        if (action == 'N') { used = 0; count = 0; clearvars(); }
        else if (action == 'L') {
            for (i = 0; i < count; i++) {
                printf("%u ", labels[i]); pos = offsets[i];
                while (text[pos]) putchar(text[pos++]);
                putchar(10);
            }
        } else runprogram();
    }
    return 0;
}
#endif

void load()
{
    char ch;
    unsigned label, mark;
#ifdef LARGE
    unsigned previous;
    previous = 0;
#endif
    while (!error) {
        done = 0; mark = used;
        do {
            if (interactive) printf("> ");
            ch = getchar();
            while (ch == ' ' || ch == 9) ch = getchar();
        } while (ch == 13 || ch == 10);
#ifndef LARGE
        if (interactive && ch >= 'A' && ch <= 'Z') {
            if (consoleline(ch)) return;
            continue;
        }
#endif
        if (ch == 'R') {
            if (getchar() != 'U' || getchar() != 'N') error = 1;
            ch = getchar();
            while (ch == ' ' || ch == 9) ch = getchar();
            if (ch != 13 && ch != 10) error = 1;
            return;
        }
        label = 0;
        if (ch < '0' || ch > '9') error = 1;
        while (ch >= '0' && ch <= '9') {
            if (label > 6553 || (label == 6553 && ch > '5')) error = 2;
            label = label * 10 + ch - '0';
            ch = getchar();
        }
        if (!error && ch != ' ' && ch != 9) error = 1;
#ifdef LARGE
        if (!error && (!label || label > 255 || label <= previous)) error = 5;
#else
        if (!error && (!label || count == LINES || (count && label <= labels[count-1]))) error = 5;
#endif
        if (error) {
            if (interactive) while (ch != 13 && ch != 10) ch = getchar();
            return;
        }
        while (ch == ' ' || ch == 9) ch = getchar();
#ifdef LARGE
        previous = label;
        save(label);
        packedline(ch);
#else
        labels[count] = label;
        offsets[count] = used;
        while (ch != 13 && ch != 10) {
            if (used >= SPACE-1) error = 6;
            else text[used++] = ch;
            ch = getchar();
        }
        if (used >= SPACE) error = 6;
        if (error) { used = mark; return; }
        text[used++] = 0;
#endif
        count++;
    }
}

int main()
{
#ifdef LARGE
    puts("BASIC4L");
#else
    puts("BASIC4");
#endif
    interactive = __rom_in(13);
    do {
        error = 0; done = 0;
        if (interactive) puts("READY (UPPERCASE)");
        load();
#ifndef LARGE
        if (quitting) return 0;
        if (interactive && !error) clearvars();
#endif
        line = 0;
        runprogram();
        if (error) printf("?ERROR %u\n", error);
#ifdef LARGE
        return 0;
#endif
    } while (interactive);
    return 0;
}
