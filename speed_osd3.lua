-- recalculates osd-msg3 timecodes with playback-speed != 1

-- show current speed at given paths at top right corner
SHOW_SPEED_IN_PATHS = {
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

past_value = -1
function osd3(name, value)
    if value ~= nil and math.floor(value) ~= math.floor(past_value) then
        local speed = mp.get_property_number("speed")
        local dur = mp.get_property_number("duration")
        local pp = mp.get_property_number("percent-pos")

        if speed ~= nil and dur ~= nil and pp ~= nil then
            past_value = value
            mp.set_property("osd-msg3", 
                string.format("%s / %s (%i%%)",
                    disp_time(value / speed),
                    disp_time(dur / speed),
                    pp
                )
            )
        end
    end
end

function speed_change(name, value)
    if value ~= 1.0 then
        mp.observe_property("time-pos", "number", osd3)
    else
        mp.unobserve_property(osd3)
        mp.set_property("osd-msg3", "")
    end
    
    local tp = mp.get_property_number("time-pos")
    local speed = mp.get_property_number("speed")
    local dur = mp.get_property_number("duration")
    local pp = mp.get_property_number("percent-pos")

    if tp ~= nil and tp > 0.5 and speed ~= nil and dur ~= nil and pp ~= nil then
        mp.command(
            string.format('show-text "%s / %s (%i%%)\nx%.2f"',
                disp_time(tp / speed),
                disp_time(dur / speed),
                pp,
                speed
            )
        )
    end

    local pth = mp.get_property("path")
    if pth ~= nil then
        for i, work_in_path in pairs(SHOW_SPEED_IN_PATHS) do
            if pth:find(work_in_path) then
                local osd_w, osd_h, aspect = mp.get_osd_size()
                local ass = assdraw:ass_new()
                ass:new_event()
                ass:an(9)
                ass:append(string.format('x%.2f', speed))
                mp.set_osd_ass(osd_w, osd_h, ass.text)

                break
            end
        end
    end
end

function started()
    local speed = mp.get_property_number("speed")
    local dur = mp.get_property_number("duration")

    if speed ~= nil and dur ~= nil then
        mp.set_property("osd-playing-msg", 
            string.format("${filename} \n %s \n ${playlist-pos-1}/${playlist-count}",
                disp_time(dur / speed)
            )
        )
    else
        mp.set_property("osd-playing-msg", "")
    end
end

mp.register_event("file-loaded", started)
mp.observe_property("speed", "number", speed_change)
