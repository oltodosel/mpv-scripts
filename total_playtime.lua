--~ Shows total playtime of current playlist.
--~ If number of items in playlist didn't change since last calculation - it doesn't probe files anew.
--~ requires ffprobe (ffmpeg)

key_binding = 'F12'
-- save probed files for future reference -- ${fname} \t ${duration}
save_probed = true
saved_probed_filename = '~/.config/mpv/scripts/total_playtime.list'

-----------------------------------

saved_probed_filename = saved_probed_filename:gsub('~', os.getenv('HOME'))

local utils = require 'mp.utils'

function disp_time(time)
	local hours = math.floor(time/3600)
	local minutes = math.floor((time % 3600)/60)
	local seconds = math.floor(time % 60)
	
	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function setContains(set, key)
	return set[key] ~= nil
end
playlist = {}
playlist_total = -1

function total_time()
	if #playlist ~= playlist_total then
		if save_probed then
			if io.open(saved_probed_filename, "rb") then
				probed_file = {}
				for line in io.lines(saved_probed_filename) do
					for k, v in line:gmatch("(.+)\t(.+)") do
						probed_file[k] = v
					end
				end
			else
				probed_file = {}
			end
		end
		
		local cwd = utils.getcwd()
		for _, f in ipairs(mp.get_property_native("playlist")) do
			f = utils.join_path(cwd, f.filename)
			-- attempt basic path normalization
			if on_windows then
				f = string.gsub(f, "\\", "/")
			end
			f = string.gsub(f, "/%./", "/")
			local n
			repeat
				f, n = string.gsub(f, "/[^/]*/%.%./", "/", 1)
			until n == 0
			
			f = string.gsub(f, "\"", "\\\"")
			
			if probed_file[f] then
				fprobe = probed_file[f]
			else
				fprobe = io.popen('ffprobe -v quiet -of csv=p=0 -show_entries format=duration "'.. f .. '"'):read()
				
				if save_probed then
					file = io.open(saved_probed_filename, "a")
					file:write(f .. '\t' .. fprobe .."\n")
					file:close()
				end
			end
			
			playlist[#playlist + 1] = { f, tonumber(fprobe) }
			
			mp.osd_message(string.format("Calculating: %s/%s", #playlist, mp.get_property("playlist-count")))
		end
		playlist_total = #playlist
	end
	
	total_dur = 0
	played_dur = mp.get_property_number("time-pos")
	current_pos = mp.get_property_number("playlist-pos-1", 0)
	
	for i, fn in pairs(playlist) do
		total_dur = total_dur + fn[2]
		if i < current_pos then
			played_dur = played_dur + fn[2]
		end
	end
	
	mp.osd_message(string.format("%s/%s (%s%%) \n %s/%s", disp_time(played_dur), disp_time(total_dur), math.floor(played_dur*100/total_dur), mp.get_property("playlist-pos-1"), mp.get_property("playlist-count")))
end

mp.add_forced_key_binding(key_binding, "total_time", total_time)
