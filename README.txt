---------------------------------------------------------------------------------
-- 
-- Universal Cosmic games (Z80 based) for MiSTer - Mike Coates
--
-- V 0.90 - 08/07/2021 - Mike Coates
-- V 0.95 - 28/06/2022 - Mike Coates - Add Devil Zone
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

I have added a screen flip option to the sprite code, sprites are flipped by the 
software on the real hardware, but everything else does have a flip signal. It is 
implemented as a fake dip switch.

No mans land needs the background video lined up properly in all flip modes.

No Mans Land need sound samples sourcing and connecting up.

---------------------------------------------------------------------------------

Hiscore save/load

Save and load of hiscores is supported for Cosmic Alien only.

To save your hiscores manually, press the 'Save Settings' option in the OSD.  Hiscores will be automatically loaded when the core is started.

To enable automatic saving of hiscores, turn on the 'Autosave Hiscores' option, press the 'Save Settings' option in the OSD, and reload the core.  Hiscores will then be automatically saved (if they have changed) any time the OSD is opened.

Hiscore data is stored in /media/fat/config/nvram/ as "<mra filename>.nvm"

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
