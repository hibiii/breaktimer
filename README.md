# breaktimer

a very hacky break timer solution written in zig.

**why?** because none of the other solutions work for me.

## using

Set up with `bktimer -m<minutes> -r<path to ring sound> -c<path to chime sound>`.
Put it in a startup script, `& disown` it, whatever, this is not your main interface.

Breaktimer will ring, the ring sound should be irritating.
You'll have to acknowledge that time's up.
Do that with `brktc.sh ack`.

Breaktimer then will change to a soft chime to remind you to take a break when you can.
The chime sound shouldn't be too loud but it shouldn't be one thing, it should be hard to ignore.
As a reminder, every five minutes when it's chiming, breaktimer will ring again (because you're late to your break).

When you can, tell breaktimer you've begun taking a break with `brktc.sh stand`.
Your break can be as long as you want to.
When you're done, tell breaktimer you've sat down at your computer again with `brktc.sh sit`.

For further convenience, consider setting up keyboard shortcuts with your desktop environment.

## building

requires standalone raylib because cba to deal with buffers and libao lmao.
