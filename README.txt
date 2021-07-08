---------------------------------------------------------------------------------
-- 
-- Universal Cosmic games (Z80 based) for MiSTer - Mike Coates
--
-- V 0.9 - 08/07/2021 - Mike Coates
---------------------------------------------------------------------------------
--
-- Up, Down, Left, Right, Fire 1, Fire 2 (not all games use all buttons) 
-- 
---------------------------------------------------------------------------------

This is a recreation of the Universal games that run on similar hardware

The game timing should be very close to the original, but the code is not 
necessarily identical to the real thing, but achieves the same end result.

---------------------------------------------------------------------------------

Known differences / problems

Sound effects are all implemented using samples (other than the DAC)

I have added a screen flip option which is not present on all parts of the 
original video hardware, sprites are instead flipped by software. 

coinage dip on Magic Spot is wrong!

The CPU is running at the wrong frequency for a couple of the games, but this 
does not affect the game (other than the DAC sounds wil be higher frequency)
This will be fixed at some point. (by converting it to a CPU Enable signal and 
adding a second divider)

No mans land needs the background video lined up properly in all flip modes.

Devil Zone and No Mans Land need sound samples sourcing and connecting up.

---------------------------------------------------------------------------------

                                *** Attention ***

ROMs are not included. In order to use this arcade, you need to provide the
correct ROMs.

To simplify the process .mra files are provided in the releases folder, that
specifies the required ROMs with checksums. The ROMs .zip filename refers to the
corresponding file of the M.A.M.E. project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for
information on how to setup and use the environment.

Quickreference for folders and file placement:

/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/_Arcade/mame/<mame rom>.zip
/_Arcade/hbmame/<hbmame rom>.zip
