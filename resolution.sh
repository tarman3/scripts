#! /bin/bash

out='eDP-1'

#res_low='1368x768'
res_low='1440x810'
#res_low='1600x900'
res_high='1920x1080'

mode=`xrandr | grep $out`

if ! [[ `echo $mode | grep ${res_high}` ]]
	then
		xrandr --output eDP-1 --mode ${res_high} --rate 60
		notify-send "xrandr" "${res_high}"
	else
		xrandr --output eDP-1 --mode ${res_low} --rate 60
		notify-send "xrandr" "${res_low}"
fi
