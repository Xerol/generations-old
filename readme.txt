Generations - 3d Game of Life Simulator
By Ellis M. Eisen (Xerol) - xerol@xerol.org - http://xerol.org/h/

Contents

1. Licence
2. Concept
3. Operation
4. Configuration
5. Support
6. Other Info


+-------------------+
| 1. Licence        |
+-------------------+

This text is here to take the place of the GPL boilerplate until I actually get the project put under GPL.

Until then:
 -Anyone may use any of the files included here for any purpose.
 -Anyone may redistribute these files, or derivatives thereof, under the condition that all necessary files and source code are distributed with it as well.

+-------------------+
| 2. Concept        |
+-------------------+

Conway's Game of Life is a 2-dimensional cellular automata that operates under a few simple rules:

1. The "world" consists of a two-dimensional array of cells. Each cell is alive or dead.
2. Any cell surrounded by exactly three "live" cells (out of the 8 adjacent cells) will live or continue to live.
3. Any living cell surrounded by exactly two "live" cells will continue to live.
4. Any cell surrounded by any other number of "live" cells (0, 1, 4, or greater) will die or remain dead.

This engine shows the progression of this over time, using the third dimension to "stack" progressive states.

+-------------------+
| 3. Operation      |
+-------------------+

For now, there isn't much to do besides watch. You can, however, look around using the following controls:

Up/Down - Move camera closer to/farther from focus point
Left/Right - Rotate camera about focus point
WASD - Move focus point around
F1 - Display list of patterns
0-9 - Preview pattern
0-9 + Enter - Place pattern
~ - Speed up simulation

+-------------------+
| 4. Configuration  |
+-------------------+

In the 'data' folder there is a file called "config.txt". There should be exactly three lines in it.

First line - Horizontal resolution, vertical resolution, fullscreen flag (1 = fullscreen, 0 = windowed)
Second line - Framerate cap. There's no need for blazing graphics here, so this gives the CPU a bit of a break. If you want to use all your computer's power, set this to a very high number (like 1000).

The patterns are stored in the "patterns.txt" file. Each pattern must take on the following format:
"Pattern Name"
Size of block of cells
[Cells]

The block of cells must be square (you can pad with empty cells) and is stored as 1 = on, 0 = off. Included are a number of common or interesting patterns.

+-------------------+
| 5. Support        |
+-------------------+

If you have this program I probably sent it to you or posted a thread about it, so generally you should post questions there.

If, however, you obtained this some other way, you may email me at xerol@xerol.org with "Generations" in the subject line.

+-------------------+
| 6. Other Info     |
+-------------------+

The engine was coded in FreeBASIC 0.17a (http://www.freebasic.net/) using OpenGL and glu. You should be able to compile this on windows or linux.

There's a lot of optimization still to be done:
 -many calculations are performed many times over when they could easily be done once at the beginning of a loop.
 -the different states over time are copied cell-by-cell rather than by pointer swapping - this is only a slowdown once per generation, but it adds up over time

I also plan on separating the render process off into a different thread to enable faster generation speed and doing further optimizations to the program. For a full list of current and planned features, as well as program updates, visit http://xerol.org/generations/