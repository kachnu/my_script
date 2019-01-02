#!/bin/bash
echo START mine

pactl load-module module-null-sink sink_name=duplex_out
pactl load-module module-null-sink sink_name=game_out
pactl load-module module-loopback source=game_out.monitor
pactl load-module module-loopback source=game_out.monitor sink=duplex_out
pactl load-module module-loopback sink=duplex_out


simplescreenrecorder




pactl unload-module module-loopback
pactl unload-module module-null-sink






exit 0
