#!/bin/bash
#program written by karol.gotowala for my personal usage, feel free to use it anyway You like, I dont take reposnibility for damage caused and bad usage :)

DESKTOP_WID=0
DESKTOP_FOCUSED=0
DESKTOP_WAS_FOCUSED=0
LIVE_WALLPAPER_PROGRAM_PID=0
LIVE_WALLPAPER_PROGRAM_WID=0
REPLY_GLOBAL="NORMAL"
LIVE_FOCUSED=0

function QUIT_FUNC() {
	NORMAL_WALLPAPER
	clear
	read -p "
	write:
	QUIT to quit 
	PID of program to set as live wallpaper 
	NORMAL to hold normal wallpaper in place
	CTRL+C to get back to this prompt

	"
	REPLY_GLOBAL=$REPLY
}

function NORMAL_WALLPAPER() {
	for x in $(xfconf-query -c xfce4-desktop -lv | grep color-style | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "0"; done
		for x in $(xfconf-query -c xfce4-desktop -lv | grep image-style | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "1"; done
		for x in $(xfconf-query -c xfce4-desktop -lv | grep single-workspace-mode | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "false"; done
		for x in $(xfconf-query -c xfce4-desktop -lv | grep single-workspace-mode | awk '{print $1}'); do xfconf-query -c xfce4-desktop -p $x -s "true"; done
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,below
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,skip_pager
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,skip_taskbar
		wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,sticky
}

trap "QUIT_FUNC" SIGINT
clear
echo "CTRL+C to get prompt"
while true; do
	sleep 0.04
	wait $( wmctrl -r "xfceliveDesktop" -e '0, 0, 0, 0, 0' )

	if [[ $REPLY_GLOBAL == "QUIT" ]]; then
		NORMAL_WALLPAPER
		exit

	elif  [[ $REPLY_GLOBAL == "NORMAL" ]]; then
		NORMAL_WALLPAPER
		DESKTOP_WID=$(wmctrl -l -x -G | grep xfceliveDesktop | awk 'NR==1{print $1}')
		while [[ $REPLY_GLOBAL == "NORMAL" ]]; do
			sleep 0.006
			DESKTOP_WAS_FOCUSED=$DESKTOP_FOCUSED
			DESKTOP_FOCUSED=$( xprop -id $DESKTOP_WID | grep FOCUSED | wc -l )
			if ((DESKTOP_WAS_FOCUSED==0 )); then
				if (( DESKTOP_FOCUSED==1 )); then
					wmctrl -r "xfceliveDesktop" -b add,above
					wmctrl -r "xfceliveDesktop" -b remove,below
				fi
			fi
			if ((DESKTOP_WAS_FOCUSED==1 )); then
				if (( DESKTOP_FOCUSED==0 )); then
					wmctrl -r "xfceliveDesktop" -b remove,above
					wmctrl -r "xfceliveDesktop" -b add,below
					#wmctrl -r "xfceliveDesktop" -b remove,below
				fi
			fi
			wait $( wmctrl -r "xfceliveDesktop" -e '0, 0, 0, 0, 0' )
		done
	elif ! [[ $REPLY_GLOBAL == "" ]]; then
		LIVE_WALLPAPER_PROGRAM_PID=$REPLY_GLOBAL
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
	
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,above
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,below
					wmctrl -r "xfceliveDesktop" -b add,above
					wmctrl -r "xfceliveDesktop" -b remove,below
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,above
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,below
					wmctrl -r "xfceliveDesktop" -b remove,above
					wmctrl -r "xfceliveDesktop" -b add,below

		while ! [[ $REPLY_GLOBAL == "NORMAL" || $REPLY_GLOBAL == "QUIT" ]]; do
			sleep 0.006
			if ! [ -d "/proc/${LIVE_WALLPAPER_PROGRAM_PID}" ]; then
				REPLY_GLOBAL="NORMAL"
				LIVE_WALLPAPER_PROGRAM_PID=0
			fi
			DESKTOP_WAS_FOCUSED=$DESKTOP_FOCUSED
			DESKTOP_FOCUSED=$( xprop -id $DESKTOP_WID | grep FOCUSED | wc -l )
			LIVE_FOCUSED=$( xprop -id $LIVE_WALLPAPER_PROGRAM_WID | grep FOCUSED | wc -l )
			if ((DESKTOP_WAS_FOCUSED==0 )); then
				if (( DESKTOP_FOCUSED==1 )); then
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,above
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,below
					wmctrl -r "xfceliveDesktop" -b add,above
					wmctrl -r "xfceliveDesktop" -b remove,below
				fi
			fi
			if ((DESKTOP_WAS_FOCUSED==1 )); then
				if (( DESKTOP_FOCUSED==0 )); then
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,above
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,below
					wmctrl -r "xfceliveDesktop" -b remove,above
					wmctrl -r "xfceliveDesktop" -b add,below
				fi
			fi
						if ((DESKTOP_WAS_FOCUSED==1 )); then
			if (( LIVE_FOCUSED==1 )); then
					wmctrl -r "xfceliveDesktop" -b add,above
					wmctrl -r "xfceliveDesktop" -b remove,below
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b remove,above
					wmctrl -i -r $LIVE_WALLPAPER_PROGRAM_WID -b add,below
					wmctrl -r "xfceliveDesktop" -b remove,above
					wmctrl -r "xfceliveDesktop" -b add,below
				fi
			fi
					#wmctrl -r "xfceliveDesktop" -b remove,below
		wait $( wmctrl -r "xfceliveDesktop" -e '0, 0, 0, 0, 0' )
		done
	fi

done
exit
