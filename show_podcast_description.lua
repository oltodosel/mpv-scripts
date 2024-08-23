-- shows content from mp.get_property('metadata/lyrics')

----------------------------------------
SPD_HOTKEY = 'Alt+c'

-- in % from osd-font-size
SPD_FONT_SCALE = 80

-- top padding
SPD_Y_POS_PX = 500

-- for not truncating =0
SPD_TEXT_MAX_SYMBOLS = 600

SPD_AUTOSTART_IN_PATHS_REGEX = {
    "/home/lom/podcasts",
    "/mnt/1/Music/",
    "/abooks/"
}
----------------------------------------

local assdraw_lyrics = require('mp.assdraw')

function show_lyrics()
    local osd_w, osd_h, aspect = mp.get_osd_size()
    local ass = assdraw_lyrics:ass_new()
    ass:new_event()
    ass:an(4)

    -- font scale
    ass:append('{\\fscx' .. tostring(SPD_FONT_SCALE) .. '}')
    ass:append('{\\fscy' .. tostring(SPD_FONT_SCALE) .. '}')

    lyrics = mp.get_property('metadata/lyrics')
    
    if lyrics ~= nil then
        -- for assdraw's newlines
        lyrics = lyrics:gsub('\n', '\\N')

        if SPD_TEXT_MAX_SYMBOLS > 0 then
            lyrics = string.sub(lyrics, 0, SPD_TEXT_MAX_SYMBOLS)
        end

        ass:append('{\\pos(10,' .. SPD_Y_POS_PX .. ')}')
        ass:append(lyrics)
    end

    mp.set_osd_ass(osd_w, osd_h, ass.text)
end

function SPD_started()
    local pth = mp.get_property("path")
    
    if pth == nil then
        return
    end

    for i, i_path in pairs(SPD_AUTOSTART_IN_PATHS_REGEX) do
		if pth:find(i_path) then
            running_lyrics = true
            show_lyrics()
			return
		end
    end
end

function SPD_show_hide()
	if running_lyrics == true then
        running_lyrics = false
        mp.set_osd_ass(0, 0, "{}")
        mp.osd_message('Hiding lyricss', 5)
	else
		running_lyrics = true
        show_lyrics()
        mp.osd_message('Showing lyricss', 5)
	end
end

mp.register_event("file-loaded", SPD_started)
mp.add_forced_key_binding(SPD_HOTKEY, 'SPD_show_hide', SPD_show_hide)
