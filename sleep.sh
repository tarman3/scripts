#! /bin/bash

killall conky
powerprofilesctl set power-saver

clear

min_volume=15
start_brigtness=10

if [ $# -lt 1 ]; then
    echo -n "Enter minutes to power off (default 60): "
    read period
else
    period=$1
fi

if [[ "$period" == "" ]]; then
    period=60
elif [[ $period -lt 2 ]]; then
    echo "Period must be more than 2 minutes"
    exit
fi

# Manually block sleep and screen locking
# https://discuss.kde.org/t/manually-block-sleep-and-screen-locking-for-n-minutes/14560
systemd-inhibit --what=idle:sleep  sleep $(($period+60)) &

current_volume=`pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1`
echo -e "\nCurrent_volume ${current_volume}%"
echo -e "Min_volume ${min_volume}%"

if [[ ${current_volume} -lt $((${min_volume}*2)) ]]; then
    echo "Current volume must be more than $((${min_volume}*2))%"
    exit
fi

#start_brigtness=$((${current_volume}-${min_volume}))
echo -e "\nDecreasing brightness to ${start_brigtness}%"
while [[ `brightnessctl | grep 'Current brightness' | awk -F' ' '{print $4}' | sed -e 's/[()%]//g'` > ${start_brigtness} ]]
do
    brightnessctl -q set 1%-
    sleep 0.2
done

pause=$((${period}*60/(${current_volume}-${min_volume})))
echo "Pause ${pause} sec"

kde-inhibit --power --screenSaver sleep $period &

while [[ ${current_volume} -gt ${min_volume} ]]; do
    pactl set-sink-volume @DEFAULT_SINK@ -1%
    current_volume=`pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1`
    left=$(((${current_volume}-${min_volume})*$pause/60))
    echo -e "\n"`date '+%H:%M:%S'`" | Current volume ${current_volume} | Minutes left $left"

    #brightnessctl -q set "${current_volume}%"
    brightnessctl -q set 1%-

    sleep $pause
done

pactl set-sink-volume @DEFAULT_SINK@ 0%

echo -e "\nPress CTRL+C to exit\n"
for i in `seq 30 -1 1`; do
    echo -ne "\rTime to poweroff $i "
    sleep 1
done

echo -ne "\rPoweroff "
echo

poweroff
