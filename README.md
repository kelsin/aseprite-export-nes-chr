# Aseprite - Export NES CHR

*This plugin was heavily influenced by
https://github.com/boombuler/aseprite-gbexport since I hadn't written an
Aseprite plugin before.*

This is an Aseprite extension to export your current sprite into NES CHR data
for use in a homebrew NES game.

Current limitations:
* Sprite must be 128x128 pixels
* Sprite must be using indexed colors
* The data you want to export must be on frame 1
* Only `nesasm` format supported

I'm open to changing all of these limitations as the need arises. Right now this
serves my purposes!

## Usage

The current extension should be included as a `.aseprite-extension` file in this
repo. If you want to edit the `package.json` or `export-nes-chr.lua` script make
sure to run `make` in order to rezip the extension. Then reinstall it in
Aseprite and restart Aseprite to see your changes.

Install the extension in Aseprite by either double clicking on the
`nes-chr-export.aseprite-extension` file, or using the Aseprite preferences
menu. Restart Aseprite a new menu command will be available: "Export NES CHR"

You can assign the "Export NES CHR" command a shortcut if you wish.

Now load up a 128x128 indexed sprite and run the "Export NES CHR" command. If
your sprite isn't valid for export you will get a message saying so. You are
then presented with a Dialog that asks you for the output filename and format.
We default the filename to the sprite's filename with `inc` added (for
"include"). Click OK and the exported file will be created. Then just include in
your game!

## Formats

Right now the only supported format is for
[nesasm](https://github.com/camsaul/nesasm)'s `.defchr` macro. If other formats
are needed please let me know!

### nesasm

This uses the nesasm `.defchr` macro where each sprite is defined as one macro:

```
;;; Sprite 0x0
    .defchr $00033000,\
            $00333300,\
            $03300330,\
            $03333330,\
            $03300330,\
            $03300330,\
            $03300330,\
            $00000000
```

The plugin will use your color's `index % 4` to get the color to use in this
macro. I suggest you use any color palette that is a multiple of 4 colors. I
included a simple `chr.pal` in this repo that is a good example one. You can
also make a palette based on your real NES palette with all 16 colors (keep in
mind that the first in each group is either the background color or transparant)
and use that since we will only place 0-3 in the final output.
