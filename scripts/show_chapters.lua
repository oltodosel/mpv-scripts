-- show chapters and their time at the bottom left corner
-- the timings get proportionally adjusted at different speeds

----------------------------------------
CHAPTERS_TO_SHOW = 10
HOTKEY = 'Meta+c'

FONT_SCALE = 80         -- in % from osd-font-size
FONT_SCALE_inactive_chapters = 75
FONT_ALPHA_inactive_chapters = 60

AUTOSTART_IN_PATHS = {
    "^edl://",
    "/med/p/podcasts",
    "/abooks/"
}
----------------------------------------

local assdraw = require('mp.assdraw')

function disp_time(time)
    local hours = math.floor(time/3600)
    local minutes = math.floor((time % 3600)/60)
    local seconds = math.floor(time % 60)
    
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function time_2_seconds(time)
    h,m,s = time:match('(.*):(.*):(.*)$')
    
    return h*3600 + m*60 + s
end

function show_chapters()
    if observation_active == false then
        observation_active = true
        mp.observe_property("chapter", "number", show_chapters)
        mp.observe_property("speed", "number", show_chapters)
    end

    local osd_w, osd_h, aspect = mp.get_osd_size()
    local ass = assdraw:ass_new()
    ass:new_event()
    ass:an(1)

    -- font scale
    ass:append('{\\fscx' .. tostring(FONT_SCALE) .. '}')
    ass:append('{\\fscy' .. tostring(FONT_SCALE) .. '}')

    local ch_index = mp.get_property_number("chapter")
    local ch_total = mp.get_property_osd("chapter-list/count")

    if ch_index and ch_index >= 0 then
        ass:append("(" .. tostring(ch_index + 1) .. "/" .. tostring(ch_total) .. ")")

        shift = 1
        if ch_index == 0 then
            start_from = 0
        else
            shift = ch_total - CHAPTERS_TO_SHOW - ch_index - 1
            start_from = -1
        end

        if shift < 0 then
            start_from = shift
        end

        for i_ch = start_from, CHAPTERS_TO_SHOW + start_from do
            if tonumber(ch_total) == ch_index + i_ch then
                break
            end
            
            -- from overshooting backwards
            if ch_index + i_ch < 0 then
                goto continue
            end

            title = mp.get_property_osd("chapter-list/" .. tostring(ch_index + i_ch) .. "/title")
            time = mp.get_property_osd("chapter-list/" .. tostring(ch_index + i_ch) .. "/time")

            ass:append("\\N")

            if i_ch == 0 then
                ass:append("{\\alpha&H" .. '00' .. "}")
                ass:append('{\\fscx' .. tostring(FONT_SCALE) .. '}')
                ass:append('{\\fscy' .. tostring(FONT_SCALE) .. '}')
            else
                ass:append("{\\alpha&H" .. tostring(FONT_ALPHA_inactive_chapters) .. "}")
                ass:append('{\\fscx' .. tostring(FONT_SCALE_inactive_chapters) .. '}')
                ass:append('{\\fscy' .. tostring(FONT_SCALE_inactive_chapters) .. '}')
            end

            -- removing paths
            if string.sub(title, 1, 1) == '/' then
                title = title:match('.+/(.*)$')
            end

            speed = mp.get_property_number("speed")
            if speed ~= 1.0 then
                time = disp_time(time_2_seconds(time) / speed)
            end

            ass:append('[' .. time .. "]  " .. title)
            
            ::continue::
        end
    end

    mp.set_osd_ass(osd_w, osd_h, ass.text)
end

function started()
    local pth = mp.get_property("path")
    
    if pth == nil then
        return
    end

    for i, i_path in pairs(AUTOSTART_IN_PATHS) do
		if pth:find(i_path) then
            running = true
            show_chapters()
			return
		end
    end
end

function show_hide()
	if running == true then
        running = false
        observation_active = false
        mp.set_osd_ass(0, 0, "{}")
        mp.unobserve_property(show_chapters)
	else
		running = true
        show_chapters()
	end
end

observation_active = false

mp.register_event("file-loaded", started)
mp.add_forced_key_binding(HOTKEY, 'show_hide', show_hide, {repeatable=true})

