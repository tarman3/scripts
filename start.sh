#! /bin/bash

power_state=`cat /sys/class/power_supply/ACAD/online`
if [ ${power_state} = 0 ]
    then nmcli radio wifi off
    else nmcli radio wifi on
fi

srm -rlz '/home/user/.cache/chromium'
srm -rlz '/home/user/.config/chromium'
srm -rlz '/home/user/.cache/librewolf'
srm -rlz '/home/user/.local/share/materialgram/tdata/user_data'

# brightnessctl -q set 95%
plasma-apply-wallpaperimage '/home/user/Pictures/arch.png'

sleep 3
python /home/user/.local/scripts/apod.py &

# killall conky
# sleep 10
# conky &

exit

