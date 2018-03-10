--~ Shows total playtime of current playlist.
--~ If number of items in playlist didn't change since last calculation - it doesn't probe files anew.
--~ requires ffprobe (ffmpeg)

--~ F12 key_binding

local utils = require 'mp.utils'

function disp_time(time)
	local hours = math.floor(time/3600)
	local minutes = math.floor((time % 3600)/60)
	local seconds = math.floor(time % 60)
	
	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

playlist = {}
playlist_total = -1

function total_time()	
	if #playlist ~= playlist_total then
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
			playlist[#playlist + 1] = { f, tonumber( io.popen('ffprobe -v quiet -of csv=p=0 -show_entries format=duration "'.. f .. '"'):read() ) }
			
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
	
	mp.osd_message(string.format("%s/%s \n %s/%s", disp_time(played_dur), disp_time(total_dur), mp.get_property("playlist-pos-1"), mp.get_property("playlist-count")))
end

mp.add_forced_key_binding("F12", "total_time", total_time)
