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

## Export sd2psx or MemCardPRO to PSU

Drop the entire `MemoryCards` folder.

Example: `MemoryCards\PS2\Card1\Card1-1.mcd`

The exported files will be placed in the `sd2psx_Exported` folder, organized by channels to prevent overwriting save data with the same name across different channels.

**Note:** `BootCard.mcd` and `DATA-SYSTEM.PSU` files will be ignored.
