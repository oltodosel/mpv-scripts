speed_regexs_fn = '~/.config/mpv/scripts/speed.conf'

function string.interpr_hex(str)
	return (str:gsub('\\x..', function (c)
		return string.char(c:gsub('\\x', '0x')):sub(1, 1)
	end))
end

function trim(s)
	return s:gsub("^%s+", ""):gsub("%s+$", "")
end

function started()
	pth = mp.get_property("path"):lower()

	for _, speed_rgx in pairs(speed_regexs) do
		if pth:find(speed_rgx[2]) then
			mp.set_property("speed", speed_rgx[1])
			break
		end
	end
end

speed_regexs_fn = speed_regexs_fn:gsub('~', os.getenv('HOME'))
speed_regexs = {}

for line in io.lines(speed_regexs_fn) do
	rgx = line:match("^\t(.+)")

	if speed and rgx then
		rgx = trim(rgx):interpr_hex():lower()
		if rgx:len() > 0 then
			table.insert(speed_regexs, {speed, rgx})
		end
	else
		speed_tmp, rgx = line:match("^([%d%.]+)(.*)")

		if speed_tmp and rgx then
			speed = speed_tmp
			rgx = trim(rgx):interpr_hex():lower()
			if rgx:len() > 0 then
				table.insert(speed_regexs, {speed, rgx})
			end	
		end
	end
end

mp.register_event("file-loaded", started)
