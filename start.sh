#! /bin/bash

power_state=`cat /sys/class/power_supply/ACAD/online`
if [ ${power_state} = 0 ]; then
    nmcli radio wifi off
    powerprofilesctl set power-saver
else
    nmcli radio wifi on
    powerprofilesctl set balanced
fi

srm -rll '/home/user/.cache/chromium'
srm -rll '/home/user/.config/chromium'
srm -rll '/home/user/.cache/librewolf'
srm -rll '/home/user/.local/share/materialgram/tdata/user_data'

if [ `date +"%H"` -lt 7 ]; then brightnessctl -q set 10%; fi

# brightnessctl -q set 95%
plasma-apply-wallpaperimage '/home/user/Pictures/arch.png'

sleep 3

if [ `date +"%H"` -gt 7 ]; then
    uv run --project $HOME/uv/python13 $HOME/.local/scripts/apod.py &
fi

conky &

exit

