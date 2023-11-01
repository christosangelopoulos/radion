#! /bin/bash
#	 ╭───────────────╮
#	 │ RECORD-TOGGLE │
#	 ╰───────────────╯
#record-toggle.sh is a scrip written by Christos Angelopoulos, October 2023, under GPL v2

function print_logo ()
{
	echo " ╭───────────────╮"
	echo " │ RECORD-TOGGLE │"
	echo " ╰───────────────╯"
}

function name_save ()
{
	if [[ $YAD_TOGGLE == "yes" ]]
	then
	yad --text="<span foreground='magenta'>⏹ </span>Recording Stopped..." --no-buttons --on-top --undecorated --no-focus --skip-taskbar --sticky --geometry=${YAD_WIDTH}x${YAD_HEIGHT}+$YAD_X+$YAD_Y --borders=10&YAD_PID=$(pidof yad |awk '{print $1}')&&	echo $YAD_PID>/tmp/rec-yad-pid.txt;fi
	case $REC_NAME_PROTOCOL in
		"date")REC_NAME="$(date +%Y-%m-%d\_%T)";
		;;
		"icy")if [[ $YAD_TOGGLE == "yes" ]];then yad_name_file "Is this the correct title?" "$(tail -1  $HOME/.config/mpv/icyhistory.log | awk -F '|' '{print $3}')";else REC_NAME="$(tail -1  $HOME/.config/mpv/icyhistory.log | awk -F '|' '{print $3}')";fi;if [[ -z $REC_NAME ]]||[[ $REC_NAME == " No title available " ]];then REC_NAME="$(date +%s)";fi;
		;;
		"epoch")REC_NAME="$(date +%s)";
		;;
		"blank")if [[ $YAD_TOGGLE == "yes" ]];then yad_name_file "Please enter file name:" "";else REC_NAME="$(date +%s)";fi
	esac
	sox /tmp/radion-tmp1.wav "$HOME""$RECORD_DIR""$REC_NAME.$OUT_FORMAT" norm
		if [[ $YAD_TOGGLE == "yes" ]];then kill $(cat /tmp/rec-yad-pid.txt)
	yad --text="<span foreground='lime'>🗸 </span>$REC_NAME.$OUT_FORMAT normalized and saved." --button=gtk-ok:0 --undecorated --on-top --no-focus --skip-taskbar --sticky --geometry=${YAD_WIDTH}x${YAD_HEIGHT}+$YAD_X+$YAD_Y --borders=10 --timeout="$YAD_DURATION";fi;
}

function rec_toggle_on ()
{
	echo "Recording..."
	if [[ $YAD_TOGGLE == "yes" ]]
	then
		yad --text="<span foreground='red'>⏺ </span>Recording..." --no-buttons --undecorated --no-focus --on-top --skip-taskbar --sticky --geometry=${YAD_WIDTH}x${YAD_HEIGHT}+$YAD_X+$YAD_Y --borders=10&YAD_PID=$(pidof yad |awk '{print $1}');echo "Yad pid: $YAD_PID";echo $YAD_PID>/tmp/rec-yad-pid.txt;while	[[ $YAD_PID !=  $(cat /tmp/rec-yad-pid.txt) ]]||[[ -z $(cat /tmp/rec-yad-pid.txt) ]];do YAD_PID=$(pidof yad |awk '{print $1}');echo "Getting yad pid: $YAD_PID";echo $YAD_PID>/tmp/rec-yad-pid.txt;done;
	fi
	rec -c 2 -r 44100 /tmp/radion-tmp1.wav
	echo "Recording stopped. File naming..."
}

function rec_toggle_off ()
{
	kill $REC_PID&&	if [[ $YAD_TOGGLE == "yes" ]];then kill $(cat /tmp/rec-yad-pid.txt);fi
}

function yad_name_file()
{
	REC_NAME="$(yad --entry \
			--text="<span foreground='lime'>♫ </span>$1" \
			--entry-text="$2" \
			--width=400 \
			--center \
			--undecorated \
			--skip-taskbar\
			--on-top )"
	if [[ $? -eq 1 ]]
	then
		if [[ $YAD_TOGGLE == "yes" ]];then kill $(cat /tmp/rec-yad-pid.txt);fi
		exit
	fi
	if [[ -z $REC_NAME ]];then REC_NAME="$(date +%s)";fi
}

function load_config ()
{
	RECORD_DIR="$(grep 'Record_directory' $HOME/.config/radion/radion.conf|sed 's/Record_directory //')";
	YAD_TOGGLE="$(grep 'Yad_toggle' $HOME/.config/radion/radion.conf|sed 's/Yad_toggle //')";
	YAD_DURATION="$(grep 'Yad_duration' $HOME/.config/radion/radion.conf|sed 's/Yad_duration//')";
	YAD_X="$(grep 'Yad_position' $HOME/.config/radion/radion.conf|awk '{print $2}')";
	YAD_Y="$(grep 'Yad_position' $HOME/.config/radion/radion.conf|awk '{print $3}')";
	YAD_WIDTH="$(grep 'Yad_dimensions' $HOME/.config/radion/radion.conf|awk '{print $2}')";
	YAD_HEIGHT="$(grep 'Yad_dimensions' $HOME/.config/radion/radion.conf|awk '{print $3}')";
	OUT_FORMAT="$(grep 'Out_format' $HOME/.config/radion/radion.conf|awk '{print $2}')";
	REC_NAME_PROTOCOL="$(grep 'Rec_name_protocol' $HOME/.config/radion/radion.conf|sed 's/Rec_name_protocol //')";
}
#############################
print_logo
load_config
REC_PID=$(pidof rec)
if [[ -n $REC_PID ]]
then rec_toggle_off
else
	rec_toggle_on
	name_save
fi
