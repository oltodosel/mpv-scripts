[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-single.svg)](https://stand-with-ukraine.pp.ua)

# speed.lua
Changing speed based on regex of filename/path.
 * (see `speed.conf` for config example)
 * Use [rubberband](https://github.com/jgreco/mpv-scripts/blob/master/rubberband_helper.lua) for higher speeds.

# total_playtime.lua
  * Shows total playtime of current playlist with `F12`.
  * Sorts playlist by duration with `KP4`.
  * * Repeated keypress reverses the order.
  * Sorts playlist by duration and jumps to the first entry with `shift+KP4`.
  * * Repeated keypress reverses the order.
  * On `Windows` it might flash cmd window for each iteration. [Reason](https://stackoverflow.com/questions/6362841/use-lua-os-execute-in-windows-to-launch-a-program-with-out-a-flash-of-cmd/6365296#6365296)
  * On `Windows` change the script according to [this](https://github.com/oltodosel/mpv-scripts/issues/1#issuecomment-894465495)
  * For `Mac` - https://github.com/oltodosel/mpv-scripts/issues/15#event-14435343114

# show_chapters.lua
Shows chapters and their time at the bottom left corner.
  * at a hotkey
  * at given paths
  * [example](https://github.com/oltodosel/mpv-scripts/raw/master/show_chapters.jpeg)
  
# speed_osd3.lua
Recalculates `osd-msg3` timecodes with speed != 1
* Example at 1.5x : 00:24:43 -> 00:16:29

# pause-indicator.lua
Displays an indicator in the middle of the screen while mpv is paused.
[Preview](https://github.com/oltodosel/mpv-scripts/raw/master/pause-indicator.jpg)

# show_podcast_description.lua
Displays content from `mp.get_property('metadata/lyrics')`
