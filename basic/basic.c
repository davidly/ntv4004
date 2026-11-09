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

unsigned used, pos, line;
char count, error, done;

void blanks()
{
    while (text[pos] == ' ' || text[pos] == 9) pos++;
}

void need(char ch)
{
    if (text[pos] != ch) error = 1;
    else pos++;
}

unsigned number()
{
    unsigned value;
    char ch;
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
}

/* A-Z are scalar slots; @(0)..@(199) share the remaining word slots.
   Array subscripts are a literal or a scalar variable, not an expression. */
unsigned destination()
{
    unsigned index;
    char ch;
    blanks();
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
    if ((ch >= 'A' && ch <= 'Z') || ch == '@') value = vars[destination()];
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
unsigned findline(unsigned target)
{
    unsigned i;
    i = 0;
    while (i < used) {
        if (text[i] == target) return i;
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
        vars[variable] = value;
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
        if (!quoted && command == 'F' && ch == 'T') {
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

void load()
{
    char ch;
    unsigned label;
#ifdef LARGE
    unsigned previous;
    previous = 0;
#endif
    while (!error) {
        ch = getchar();
        while (ch == 13 || ch == 10 || ch == ' ' || ch == 9) ch = getchar();
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
        if (error) return;
        if (ch != ' ' && ch != 9) error = 1;
#ifdef LARGE
        if (!label || label > 255 || label <= previous) error = 5;
#else
        if (!label || count == LINES || (count && label <= labels[count-1])) error = 5;
#endif
        if (error) return;
        while (ch == ' ' || ch == 9) ch = getchar();
#ifdef LARGE
        previous = label;
        save(label);
        packedline(ch);
#else
        labels[count] = label;
        offsets[count] = used;
        while (ch != 13 && ch != 10) {
            if (used >= SPACE-1) { error = 6; return; }
            text[used++] = ch;
            ch = getchar();
        }
        if (used >= SPACE) { error = 6; return; }
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
    load();
    line = 0;
#ifdef LARGE
    while (!error && !done && line < used) {
        pos = line+1;
        line = pos;
        while (text[line]) line++;
        line++;
#else
    while (!error && !done && line < count) {
        pos = offsets[line++];
#endif
        statement();
    }
    if (error) printf("?ERROR %u\n", error);
    return 0;
}
