# Berzerk

They say a good starting point to learn Godot (or any game engine) is to
write a classic game. I've wanted to do Berzerk for a while, and finally am
trying my hand at it.

## Assets
The sprites are from The Spriters Resource, with some editing via Image
Magick to make them more compatible with Godot and BMFont formats:
https://www.spriters-resource.com/arcade/berzerk/

Speech is generated via espeak-ng and the "gmw/en-US" voice. I'm using sound
effects from an Ovani pack I bought some time ago in a Humble Bundle, so
those are not included in the Git repo. 

## Maze Generation
Maze generation had been documented on the Robotron 2084 site. It's
currently down however is available via the Wayback machine:
https://web.archive.org/web/20200403110753/http://www.robotron2084guidebook.com/home/games/berzerk/mazegenerator/code/


## Robot AI
This site describes the Robot AI in detail:
https://www.retrogamedeconstructionzone.com/2020/03/decoding-berzerk-ai.html

## Scoring
50 points on each robot death, no matter how it dies.
10 points per robot on all robots dying, even if Otto gets you
   before you leave.

## Random Notes

B

Grid for pillars

X	Y
16	13	26	39	39+13

32

Player Start
	West:	103	407
	
Robot Start
	North:	352	96

Otto Frame /Collision y values
0	-4
1	-20
2	-28
3	-32
4	-34
5	-36
6	-34
7	-32
8	-28
9	-20
