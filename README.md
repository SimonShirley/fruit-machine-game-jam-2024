# The Slot Machine Simulation Jam

This is my entry to the Slot Machine Simulation Jam 2024, hosted by Phaze101 and the Retro Programmers Inside.

More details and the rules of the game jam can be found on the game jam page at: https://itch.io/jam/the-slot-machine-simulation-jam

## What does my entry do?
In a sense, it's a primitive slot machine / fruit machine game for the Commodore 64.

The game features primitive sounds, sprites and PETSCII graphics to protray a simple slot machine.

As per the requirements, the game is wrtten in BASIC, in my case Commodore Basic 2.0 to be run on the Commodore 64. There is one SYS PLOT Kernal call subroutine that updates the cursor location on screen. Everything that doesn't have built-in BASIC commands have had to be POKEd and PEEKed at the relevant memory locations (like sprite and sound data).


## How To Play
The game is completely keyboard controlled.

Once the game has loaded, pressing **S** will move on from the title screen. Unfortunately, the sprite data takes a little while to be poked into memory, so please be patient!

For the most part, the controls are as follows:

* Pressing **S** will spin the reels, if the player has any credit remaining.
* Pressing **+** or **-** will increase the bet amount for this and subsequent spins, in increments of 10p / £0.10, from a minumum of £0.10 to a maximum of £1.00.
* Pressing **Q** will quit the game and return to a READY prompt.

### Holding Reels
At random intervals through the game, the player will be given the opportunity to hold the reels in the hopes that the next spin will achieve a winning outcome. Pressing **1**, **2**, or **3** will toggle that reel from held to unheld. The colours of the bars underneath the reels indicate whether the reel will be held (green) or will spin (red) on the next spin. It is possible to hold all three reels or none of them, or any combination thereof.

### Nudging Reels
At random intervals during the game, the player will also be given the opportunity to nudge the reels downwards by a random number of nudges. This gives the player the opportunity to win in this turn that they otherwise wouldn't have. The number of nudges is random, so there may not be a winning possibility after all the nudges have been used, and sometimes the game will give more nudges than required for a win.

Pressing **1**, **2**, or **3** will nudge that reel accordingly. A sound will play repetatively to differentiate nudging from holding.

There isn't any gamble possibility for wins or nudges. Once a winning combination has been achieved (by spinning or nudging), the winning amount is automatically added back to the player's credit pot.

### Game Over
Once the player runs out of credit, the game is over. Pressing **P** will restart the game with a new £1.00 credit. If not then after a short pause, the game will return to the title screen.

## Technical Challenges While Creating This
* The VIC memory needed to be moved to Bank 2 because the program code was too large to fit into the default memory space before the location of VIC Bank 0 sprite pointer data.
* I wasn't aware of string memory creep that, after a few playthroughs, would overwrite the sprite data, thus corrupting them. After moving from VIC Bank 0 to VIC Bank 2, the end of BASIC needed to be set to $7FFF to avoid this.
* Creating the appearance of reel scrolling. Originally, the game just showed the word of the reel which was later replaced by a single reel sprite image, randomised. After seeing OSK's streams and others that had been demonstrated in production, I took inspiration in having an order in which the reel symbols would appear, and created what I refer to as 'half sprites' (sprites where the top of the sprite data contains the bottom half of one image and the top half of another), to simulate the appearance of 3 images on a reel visible. This is due to a limitation in the C64 where only 8 sprites can be visible at a time (without mastery, to which BASIC isn't fast enough). The reel order and its correlating sprite ordering arrays are scrolled through to give the appearance of scrolling.


## Special Thanks
* **Phaze101** and **Retro Programmers Inside** for hosting the jam.
* **OldSkoolCoder** for assisting in publicising the jam (I wouldn't have known about it otherwise!)
* **mikroman** / **mikroman3526** for assisting with screen memory issues getting in the way of the program itself.
* **fizgog** for assisting with the hold functionality and the reel spin mechanic.
* **NitroGBeans**, **DracoXGaming**, **Sabbath**, **stacbats** and the **OSK Community** for either testing or supporting me through the creation process.

### Tools and references used:
 * Visual Studio Code - https://code.visualstudio.com/
 * VS64 VS Code Extension - https://marketplace.visualstudio.com/items?itemName=rosc.vs64
 * SpriteMate - https://www.spritemate.com/
 * VICE Emulator - https://vice-emu.sourceforge.io/
 * Commodore User Manual and Programmers Reference Guide
 * C64-Wiki - https://www.c64-wiki.com
 * Ultimate C64 Reference - https://www.pagetable.com/c64ref/c64mem/
 