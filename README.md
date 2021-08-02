# [Arcade: Universal Cosmic](https://www.arcade-museum.com/game_detail.php?game_id=7398) games (Z80-based) for [MiSTer](https://github.com/MiSTer-devel/Main_MiSTer/wiki)

By [Mike Coates](https://github.com/macrofpga)  
Current Version - 0.9 - 08/07/2021

## Description

This is a recreation of the [Universal](https://www.arcade-museum.com/manuf_detail.php?manuf_id=1703&orig_game_id=7398) games that run on similar hardware.

The game timing should be very close to the original, but the code is not necessarily identical to the real thing, but achieves the same end result.

## Controls

Up, Down, Left, Right, Fire 1, Fire 2 (not all games use all buttons)

## Games currently supported

* [Cosmic Alien](https://www.arcade-museum.com/game_detail.php?game_id=7398)
* [Magical Spot](https://www.arcade-museum.com/game_detail.php?game_id=8505)
* [Space Panic](https://www.arcade-museum.com/game_detail.php?game_id=9676)

## Known differences/problems

Sound effects are all implemented using samples (other than the DAC).

I have added a screen flip option to the sprite code, sprites are flipped by the software on the real hardware, but everything else does have a flip signal. It is implemented as a fake dip switch.

No Man's Land needs the background video lined up properly in all flip modes.

Devil Zone and No Man's Land need sound samples sourced and connected up.

## ROM Files Instructions

**ROMs are not included!** In order to use this arcade core, you will need to provide the correct ROM file yourself.

To simplify the process `.mra` files are provided in the releases folder, that specify the required ROMs with their checksums. The ROMs `.zip` filename refers to the corresponding file from the MAME project.

Please refer to https://github.com/MiSTer-devel/Main_MiSTer/wiki/Arcade-Roms for information on how to setup and use the environment.

Quick reference for folders and file placement:

```
/_Arcade/<game name>.mra
/_Arcade/cores/<game rbf>.rbf
/games/mame/<mame rom>.zip
/games/hbmame/<hbmame rom>.zip
```
