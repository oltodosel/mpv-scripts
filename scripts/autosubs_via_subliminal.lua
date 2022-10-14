-- original script:
-- https://gist.github.com/selsta/ce3fb37e775dbd15c698
--
-- subliminal:
-- https://github.com/Diaoul/subliminal
------------------------------------------------------
-- Seeks subtitles with subliminal at different servers separately and downloads all available.
--
-- keybinding: shift+v - for current file
-- keybinding: shift+b - for all files in playlist
-- 
-- language code(s) for one or more languages to seek
sub_langs = {'de', 'he'}

-- sites where to search
sites = {'addic7ed', 'legendastv', 'opensubtitles', 'podnapisi', 'shooter', 'subscenter', 'thesubdb', 'tvsubtitles'}


local utils = require 'mp.utils'

function display_error()
	mp.msg.warn("Subtitle download failed")
	mp.osd_message("Subtitle download failed")
end

function auto_load_subs_all()
	all_files = 1
	mp.register_event("start-file", load_sub_fn)
	load_sub_fn()
end

function load_sub_fn()
	if all_files == 1 then
		os.execute('sleep .3')
		mp.set_property("pause", 'yes')
	end

	path = mp.get_property("path")

	for k1, language in pairs(sub_langs) do
		for k2, site_name in pairs(sites) do
			path2 = string.gsub(path, "%.%w+$", '.' .. language .. "." .. site_name .. ".srt")

			srt_path = string.gsub(path2, "%.%w+$", ".srt")
			t = { args = { "subliminal", "download", "--provider", site_name, "-s", "-l", language, path2 } }

			mp.osd_message("Searching subtitles...")
			res = utils.subprocess(t)
			if res.error == nil then
				if mp.commandv("sub_add", srt_path) then
					mp.msg.warn("Subtitle download succeeded.")
					mp.osd_message("Subtitle '" .. srt_path .. "' download succeeded")
				else
					display_error()
				end
			else
				display_error()
			end
		end
	end

	if all_files == 1 then
		mp.command("playlist_next force")
	end
end

mp.add_key_binding("V", "auto_load_subs", load_sub_fn)
mp.add_key_binding("B", "auto_load_subs_all", auto_load_subs_all)
