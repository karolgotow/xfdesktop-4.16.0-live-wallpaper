#!/bin/bash
#program written by karol.gotowala for my personal usage, feel free to use it anyway You like, I dont take reposnibility for damage caused and bad usage :)

DESKTOP_WID=0
DESKTOP_FOCUSED=0
DESKTOP_WAS_FOCUSED=0
LIVE_WALLPAPER_PROGRAM_PID=$1
LIVE_WALLPAPER_PROGRAM_WID=0
CURRENT_WORKSPACE=0

trap "QUIT_FUNC" SIGINT

function MAIN_FUNC() {
LIVE_WALLPAPER_PROGRAM_WID=$( wmctrl -lp | grep $LIVE_WALLPAPER_PROGRAM_PID | awk 'NR==1{print $1}' )
DESKTOP_WID=$(wmctrl -l -x -G | grep xfceliveDesktop | awk 'NR==1{print $1}')
wmctrl -r "xfceliveDesktop" -b add,sticky
wmctrl -r "xfceliveDesktop" -b add,hidden
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -e '0, 0, 0, -1, -1'
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,maximized_vert
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,maximized_horz
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,sticky
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,below
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,skip_pager
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,skip_taskbar
wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,hidden

#those fors for settings are borrowed from xfce forum post here @ ToZ
#https://forum.xfce.org/viewtopic.php?pid=73547#p73547
for x in $(xfconf-query -c xfce4-desktop -lv | grep color-style | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "3"; done
for x in $(xfconf-query -c xfce4-desktop -lv | grep image-style | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "0"; done
for x in $(xfconf-query -c xfce4-desktop -lv | grep single-workspace-mode | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "false"; done
for x in $(xfconf-query -c xfce4-desktop -lv | grep single-workspace-mode | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "true"; done

while true; do
	sleep 0.005
	CURRENT_WORKSPACE=$( xdotool get_desktop )
	DESKTOP_WAS_FOCUSED=$DESKTOP_FOCUSED
	DESKTOP_FOCUSED=$( xprop -id $DESKTOP_WID | grep FOCUSED | wc -l )
	if ((DESKTOP_WAS_FOCUSED==0 )); then
		if (( DESKTOP_FOCUSED==1 )); then
			for ((i = 1 ; i <= $(wmctrl -l | wc -l) ; i++ )); do 
				if(( $(wmctrl -l -x -G | awk 'NR=='$i'{print $2}') == CURRENT_WORKSPACE )); then
					if(( $( xprop -id $(wmctrl -l -x -G | awk 'NR=='$i'{print $1}') | grep NET_WM_STATE_ABOVE | wc -l ) == 0 )); then
						wmctrl -i -r $(wmctrl -l -x -G | awk 'NR=='$i'{print $1}') -b add,hidden
					fi
				fi
			done
		fi
	fi
wmctrl -r "xfceliveDesktop" -e '0, 0, 0, 0, 0'
done
}

function QUIT_FUNC() {
read -p "
write QUIT to quit or put a PID of program to set as live wallpaper CTRL+C to get back tot his prompt
"
	if [[ $REPLY == "QUIT" ]]; then
		for x in $(xfconf-query -c xfce4-desktop -lv | grep color-style | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "0"; done
		for x in $(xfconf-query -c xfce4-desktop -lv | grep image-style | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "1"; done
		for x in $(xfconf-query -c xfce4-desktop -lv | grep single-workspace-mode | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "false"; done
		for x in $(xfconf-query -c xfce4-desktop -lv | grep single-workspace-mode | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "true"; done
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,below
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,skip_pager
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,skip_taskbar
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,sticky
		exit
	else
		LIVE_WALLPAPER_PROGRAM_PID=$REPLY
		MAIN_FUNC
	fi
}

QUIT_FUNC

MAIN_FUNC

exit
