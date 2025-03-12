# sd2psx-save-converter

This script is useful if you have a lot of saved data and use the Game ID option with your sd2psx or MemCardPRO. It allows you to convert all your saves files to `.mcd` or `.mc2` individually, each with its own Game ID.

## Import Save to MCD or MC2

### For PS1
Drop your `*.raw`, `*.mcs`, `*.psv`, `*.ps1`, `*.mcb`, `*.mcx`, `*.pda`, `*.psx` files into the `MY_SAVES_PS1` folder.

### For PS2
Drop your `*.psu`, `*.psv`, `*.max`, `*.cbs`, `*.sps`, `*.xps` files into the `MY_SAVES_PS2` folder.

## Export Virtual Memory Cards to PSU

### For PS1
Drop your `*.bin`, `*.ddf`, `*.gme`, `*.mc`, `*.mcd`, `*.mci`, `*.mcr`, `*.mem`, `*.ps`, `*.psm*`, `*.srm`, `*.vgs`, `*.vm1`, `*.vmp`, `*.vmc` files into the `MY_SAVES_PS1` folder.

### For PS2
Drop your `*.mcd`, `*.mc2`, `*.bin`, and `*.ps2` files into the `MY_SAVES_PS2` folder.

The exported files will be placed in the .???_Exported folder. The question marks represent the format of the exported card

## Create Memory Cards groups for cross-game features
Cross-Game Groups allows you to unlock bonuses in compatible games, such as Need for Speed Most Wanted, if the save data from Need for Speed Underground 2 is present. You will then start the game with an additional $10,000. [See more at](https://github.com/sync-on-luma/xebplus-neutrino-loader-plugin/wiki/Memory-Card-Groups)

This feature also allows you to add your memory cards from compatible games, currently stored in the `MemoryCards\PS2` or `PS1` folder, to memory card groups.

Don't forget to copy the `Game2Folder.ini` file into the `.sd2psx` folder. This file contains all the game IDs of compatible games, which will automatically create the group when the game is launched.

The groups will have the prefix `MCCG` for `MemoryCardsCrossGame`
## Export sd2psx or MemCardPRO to PSU

Drop the entire `MemoryCards` folder.

Example: `MemoryCards\PS2\Card1\Card1-1.mcd`

The exported files will be placed in the `sd2psx_Exported` folder, organized by channels to prevent overwriting save data with the same name across different channels.

**Note:** `BootCard.mcd` and `DATA-SYSTEM.PSU` files will be ignored.
