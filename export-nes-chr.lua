-- Output the sprite at position sprite_x and sprite_y in nesasm .defchr format
function writeSpriteNesasm(img, sprite_x, sprite_y)
    io.write(string.format(";;; Sprite %dx%d\n", sprite_x, sprite_y))

    for row = 0, 7 do
        local first_row = row == 0
        local last_row = row == 7
        local pixel_y = (sprite_y * 8) + row

        -- Start the sprite output
        if first_row then
            io.write("    .defchr $")
        else
            io.write("            $")
        end

        for col = 0, 7 do
            local pixel_x = (sprite_x * 8) + col
            local index = img:getPixel(pixel_x, pixel_y)
            local chr_index = index % 4

            io.write(string.format("%d", chr_index))
        end

        -- End the sprite output
        if last_row then
            io.write("\n")
        else
            io.write(",\\\n")
        end
    end
end

-- Output the sprite at position sprite_x and sprite_y in binary format
function writeSpriteBinary(img, sprite_x, sprite_y)
    -- Low byte
    for row = 0, 7 do
        local pixel_y = (sprite_y * 8) + row
        local byte = 0

        for col = 0, 7 do
            local pixel_x = (sprite_x * 8) + col
            local index = img:getPixel(pixel_x, pixel_y)
            local chr_index = index % 4

            byte = byte * 2
            if chr_index == 1 or chr_index == 3 then
                byte = byte + 1
            end
        end

        -- Write the byte to the file
        io.write(string.char(byte))
    end

    -- High byte
    for row = 0, 7 do
        local pixel_y = (sprite_y * 8) + row
        local byte = 0

        for col = 0, 7 do
            local pixel_x = (sprite_x * 8) + col
            local index = img:getPixel(pixel_x, pixel_y)
            local chr_index = index % 4

            byte = byte * 2
            if chr_index == 2 or chr_index == 3 then
                byte = byte + 1
            end
        end

        -- Write the byte to the file
        io.write(string.char(byte))
    end
end

-- Output the CHR data from the current file to the passed in filename
function exportChrData(sprite, filename, format)
    -- Make a image out of the full sprite
    local img = Image(sprite.spec)
    img:drawSprite(sprite, 1)

    local options = "w"
    if format == "binary" then
        options = options .. "b"
    end

    -- Open the file for writing and set out default output to the file
    local f = io.open(filename, options)
    io.output(f)

    for sprite_y = 0, 15 do
        for sprite_x = 0, 15 do
            if format == "binary" then
                writeSpriteBinary(img, sprite_x, sprite_y)
            else
                writeSpriteNesasm(img, sprite_x, sprite_y)
            end

        end
    end
    io.close(f)
end

function exportNesChr(plugin)
    local sprite = app.activeSprite

    -- Check constrains
    if sprite == nil then
        app.alert("No Sprite...")
        return
    end
    if sprite.colorMode ~= ColorMode.INDEXED then
        app.alert("Sprite needs to be indexed")
        return
    end

    if sprite.width ~= 128 then
        app.alert("Sprite width needs to be 128")
        return
    end

    if sprite.height ~= 128 then
        app.alert("Sprite height needs to be 128")
        return
    end

    local filename = sprite.filename
    if filename == "" then
        filename = "chr.inc"
    else
        filename = string.gsub(filename, "%.[%w]+$", ".chr")
    end

    -- Show a dialog to get the output file and then export current sprites data
    local dlg = Dialog("Export NESASM CHR Data")
    dlg:file{ id="exportFile",
              label="Output File",
              open=false,
              save=true,
              entry=true,
              filename=filename,
              filetypes={ "chr", "asm", "inc" }}
    dlg:combobox{ id="format",
                  label="Format",
                  option=plugin.preferences.format,
                  options={ "binary", "nesasm" }}
    dlg:button{ id="ok", text="OK" }
    dlg:button{ id="cancel", text="Cancel" }
    dlg:show()
    local data = dlg.data
    if data.ok then
        plugin.preferences.format = data.format
        exportChrData(sprite, data.exportFile, data.format)
    end
end

-- Plugin init
function init(plugin)
    -- Setup initial format preference if not set
    if plugin.preferences.format == nil then
        plugin.preferences.format = "binary"
    end

    plugin:newCommand{
        id="NesChrExport",
        title="Export NES CHR",
        group="file_export",
        onclick=function()
            exportNesChr(plugin)
        end
    }
end
