/* traffic.c: a pedestrian crossing, the kind of controller the 4004 was
   made for. Run it with ntv4004's -o option to see the lamps, and -s:740000
   for a real 4004's speed; press a key to cross:

       ./ntv4004 -o -s:740000 examples/c/traffic.hex

   ROM port 0 drives the road's lamps: bit 2 red, bit 1 amber, bit 0 green.
   ROM port 1 drives the crossing's: bit 1 don't walk, bit 0 walk.
   A key press is the crossing's button. After CROSSINGS crossings the
   program ends. */

#define RED 4
#define AMBER 2
#define GREEN 1
#define DONT_WALK 2
#define WALK 1
#define CROSSINGS 2

#define READY 14        /* ROM port 14 reads 1 when a key is waiting */
#define PER_TENTH 86    /* wait's loop takes 107 instruction cycles, and a
                           tenth of a second is 9,259 at 740 kHz */

_Bool pressed;

/* Wait about tenths / 10 seconds, watching the button. A press waits in
   the keyboard buffer while another is pending. */
void wait(int tenths)
{
    int i;
    while (tenths--)
        for (i = 0; i < PER_TENTH; i++)
            if (!pressed && __rom_in(READY)) {
                getchar();
                pressed = 1;
            }
}

void lamps(int road, int crossing)
{
    __rom_out(0, road);
    __rom_out(1, crossing);
}

int main()
{
    int crossings, flash;
    lamps(GREEN, DONT_WALK);
    puts("road green; press a key to cross");
    for (crossings = 0; crossings < CROSSINGS; crossings++) {
        while (!pressed)
            wait(1);
        pressed = 0;
        wait(50);               /* the road keeps green for 5 seconds */
        lamps(AMBER, DONT_WALK);
        puts("road amber");
        wait(30);
        lamps(RED, DONT_WALK);
        wait(20);
        lamps(RED, WALK);
        puts("walk");
        wait(60);
        for (flash = 0; flash < 4; flash++) {   /* the walk lamp flashes */
            lamps(RED, 0);
            wait(5);
            lamps(RED, WALK);
            wait(5);
        }
        lamps(RED, DONT_WALK);
        wait(20);
        lamps(GREEN, DONT_WALK);
        puts("road green");
    }
    return 0;
}
