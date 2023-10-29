#! /bin/bash
# ╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮
# │ R ││ A ││ D ││ I ││ O ││ N │
# ╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯
#A bash script written by Christos Angelopoulos, October 2023, under GPL v2



function keybindings ()
{
	echo -e "  ${B}╭─────┬──────────╮"
	echo -e "  ${B}│${M}  ␣  ${B}│${C}    Pause ${B}│"
	echo -e "  ${B}├─────┼──────────┤"
	echo -e "  ${B}│${M} 9 0 ${B}│${C}   ↑↓ Vol ${B}│"
	echo -e "  ${B}├─────┼──────────┤"
	echo -e "  ${B}│${M}  m  ${B}│${C}     Mute ${B}│"
	echo -e "  ${B}├─────┼──────────┤"
	echo -e "  ${B}│${M} ← → ${B}│${C} Skip 10\"${B} │"
	echo -e "  ${B}├─────┼──────────┤"
	echo -e "  ${B}│${M} ↑ ↓ ${B}│${C} Skip 60\"${B} │"
	echo -e "  ${B}├─────┼──────────┤"
	echo -e "  ${B}│${M}  q  ${B}│${R}     Quit ${B}│"
	echo -e "  ${B}╰─────┴──────────╯${M}"
}

function play_station ()
{
	clear
	print_logo
	if [[ $SHOW_MPV_KEYBINDINGS == "yes" ]]; then keybindings;fi
	echo -e "${B}STATION: ${Y}$STATION${n}"
	echo -e "${B}URL    : ${C}$STATION_URL${n}"
	mpv $STATION_URL
}

function print_logo ()
{
	echo -e "${B} ╭───╮╭───╮╭───╮╭───╮╭───╮╭───╮"
	echo -e " │ ${Y}R ${B}││ ${Y}A ${B}││ ${Y}D ${B}││ ${Y}I ${B}││ ${Y}O ${B}││ ${Y}N ${B}│"
	echo -e " ╰───╯╰───╯╰───╯╰───╯╰───╯╰───╯${n}"
}

function load_config ()
{
	if [[ "$OSTYPE" == "darwin"* ]]; then
		URL_OPENER="open"
	else
		URL_OPENER="xdg-open"
	fi
	PREF_SELECTOR="$(grep 'Preferred_selector' $HOME/.config/radion/radion.conf|awk '{print $2}')";
	FZF_FORMAT="$(grep 'fzf_format' $HOME/.config/radion/radion.conf|sed 's/fzf_format//;s/|//')";
	ROFI_FORMAT="$(grep 'rofi_format' $HOME/.config/radion/radion.conf|sed 's/rofi_format//;s/|//')";
		DMENU_FORMAT="$(grep 'dmenu_format' $HOME/.config/radion/radion.conf|sed 's/dmenu_format//;s/|//')";
	PREF_EDITOR="$(grep 'Preferred_editor' $HOME/.config/radion/radion.conf|sed 's/Preferred_editor//')";
	if [[ $PREF_SELECTOR == "rofi" ]]
	then PREF_SELECTOR_STR="$ROFI_FORMAT"
	elif [[ $PREF_SELECTOR == "fzf" ]]
	then PREF_SELECTOR_STR="$FZF_FORMAT"
	elif [[ $PREF_SELECTOR == "dmenu" ]]
	then PREF_SELECTOR_STR=""$DMENU_FORMAT""
	fi;
	PROMPT_TEXT="$(grep 'Prompt_text' $HOME/.config/radion/radion.conf|sed 's/Prompt_text//;s/|//')";
	SHOW_MPV_KEYBINDINGS="$(grep 'Show_mpv_keybindings' $HOME/.config/radion/radion.conf|awk '{print $2}')";
	main
}

function read_select_station ()
{
	LOOP2=0
	ABORT=0
	while [[ $LOOP2 -eq 0 ]]
	do
	clear
		print_logo
		echo -e "${Y}$TAG${n}"

		LINE=1
		LINEMAX=$(cat /tmp/radion_select_tag.txt|wc -l)
		echo -e "${B}╭────────────────────────────────╮"
		while [[ $LINE -le $LINEMAX ]]
		do
			PRINT_LINE="│ ${M}$LINE ${C}$(head -$LINE /tmp/radion_select_tag.txt|tail +$LINE|awk '{print $2"                          "}'|sed 's/-/ /g;s/~//g')"
			echo -e "${PRINT_LINE:0:53}${B}│"
			((LINE++))
		done
		echo -e "├────────────────────────────────┤"
		echo -e "│${M} X${R} 👈 Go Back                   ${B}│"
		echo -e "│${M} Q${R} ❌ Quit                      ${B}│"
		echo -e "├────────────────────────────────┤"
		echo -e "│${G} Enter number for station:     ${B} │"
		echo -e "╰────────────────────────────────╯${M}"

		read  INDEX
		INDEX_NUM="$(echo $INDEX|sed 's/[[:cntrl:]]//g;s/[a-z]//g;s/[A-Z]//g;s/[[:punct:]]//g;s/ //g')"
		if [[ $INDEX == "Q" ]]||[[ $INDEX == "q" ]];then clear;exit
		elif [[ $INDEX == "X" ]]||[[ $INDEX == "x" ]];then LOOP2=1;ABORT=1
		elif [[ -n $INDEX_NUM ]]&&[[ $INDEX_NUM -gt 0 ]]&&[[ $INDEX_NUM -le $LINEMAX ]]&&[[ $ABORT -eq 0 ]]
		then
			STATION_URL="$(awk '{print NR" "$0}' /tmp/radion_select_tag.txt|grep -E "^$INDEX_NUM "|awk '{print $2}')"
			STATION="$(awk '{print NR" "$0}' /tmp/radion_select_tag.txt|grep -E "^$INDEX_NUM "|awk '{print $3}'|sed 's/-/ /g;s/~//g')"
			play_station
			LOOP2=1
		fi
	done
}

function read_select_tag ()
{
	LOOP1=0
	while [[ $LOOP1 -eq 0 ]]
	do
		clear
		print_logo
		TAGS=( $(sed 's/ /\n/g' $HOME/.config/radion/stations.txt |grep "#"|grep -v "#Favorites"|sort|uniq|sed 's/#//g') )

		echo -e "${B}   ╭──────────────────────────Tags─╮"
		x=0
		while [[ $x -lt ${#TAGS[@]} ]]
		do
			TAGLINE="   │  ${M} $((x+1))${C} ${TAGS[x]}                                  "
			echo -e "${TAGLINE:0:55}${B}│"
			((x++))
		done
		echo -e "   ├─────────────────────Favorites─┤"
		z=0
		FAVS=( $(grep "#Favorites" $HOME/.config/radion/stations.txt|grep -v -E ^$|grep -v -E ^//|awk {'print $2'}|sed 's/~//g') )
		while [[ $z -lt ${#FAVS[@]} ]]
		do
		FAVLINE="   │  ${M} $((x+z+1))${Y} ${FAVS[z]//-/ }                                  "
		echo -e "${FAVLINE:0:55}${B}│"
			((z++))
	done
		echo -e "   ├───────────────────────Actions─┤"
		echo -e "   │   ${M}A${G} ⭐ All Stations           ${B}│"
		echo -e "   │   ${M}E${G} 📋 Edit Stations          ${B}│"
		echo -e "   │   ${M}P${G} 🔧 Preferences            ${B}│"
		echo -e "   │   ${M}D${G} 🔎 Find Stations      ${B}    │"
		echo -e "   │   ${M}Q${R} ❌ Quit Radion            ${B}│"
		echo -e "   ├───────────────────────────────┤"
		echo -e "   │${G} Enter number/letter:          ${B}│"
		echo -e "   ╰───────────────────────────────╯${M}"
		read TAG_INDEX
		TAG_INDEX_NUM="$(echo $TAG_INDEX|sed 's/[[:cntrl:]]//g;s/[a-z]//g;s/[A-Z]//g;s/[[:punct:]]//g;s/ //g')"
		if [[ $TAG_INDEX == "E" ]]||[[ $TAG_INDEX == "e" ]];then eval $PREF_EDITOR $HOME/.config/radion/stations.txt
		elif [[ $TAG_INDEX == "P" ]]||[[ $TAG_INDEX == "p" ]];then eval $PREF_EDITOR $HOME/.config/radion/radion.conf;load_config
		elif [[ $TAG_INDEX == "Q" ]]||[[ $TAG_INDEX == "q" ]];then clear;exit
		elif [[ $TAG_INDEX == "A" ]]||[[ $TAG_INDEX == "a" ]]||[[ $TAG_INDEX == "" ]];then 	TAG=":";	echo -e "${Y}⭐ All Stations${n}";grep -v -E ^$ $HOME/.config/radion/stations.txt|grep -v -E ^// >/tmp/radion_select_tag.txt;LOOP1=1
		elif [[ $TAG_INDEX == "D" ]]||[[ $TAG_INDEX == "d" ]];then $URL_OPENER "https://www.radio-browser.info/tags" ;echo -e "${R}NOTICE:\n${B}Press any key to continue with radion.${n}";read -sn 1 d
		elif [[ -n $TAG_INDEX_NUM ]]&&[[ $TAG_INDEX_NUM -gt ${#TAGS[@]} ]]&&[[ $TAG_INDEX_NUM -le $(($z+${#FAVS[@]}+1)) ]]
		then
		STATION=${FAVS[$(($TAG_INDEX_NUM-$x-1))]}
		STATION_URL="$(grep ~${STATION// /-}~ $HOME/.config/radion/stations.txt|awk '{print $1}')"
		play_station
		elif [[ -n $TAG_INDEX_NUM ]]&&[[ $TAG_INDEX_NUM -gt 0 ]]&&[[ $TAG_INDEX_NUM -le ${#TAGS[@]} ]]
		then
			TAG="#${TAGS[$(($TAG_INDEX_NUM-1))]}"
			grep $TAG $HOME/.config/radion/stations.txt >/tmp/radion_select_tag.txt
			LOOP1=1
		fi
	done
}

function select_tag ()
{
	LOOP1=0
	while [[ $LOOP1 -eq 0 ]]
	do
	clear
		print_logo
		if [[ $PREF_SELECTOR == fzf ]]
		then
			TAG_INDEX="$(echo -e "${B}────────────────────── 🔖 Tags\n${C}$(sed 's/ /\n/g' $HOME/.config/radion/stations.txt |grep "#"|grep -v "#Favorites"|sort|uniq|sed 's/#//g;s/$//g')${n}\n${B}────────────────────── ⭐ Favorites\n${Y}$(grep "#Favorites" $HOME/.config/radion/stations.txt|grep -v -E ^$|grep -v -E ^//|awk {'print $2'}|sed 's/-/ /g;s/~//g')"${n}"\n${B}────────────────────── 🔧 Actions\n${G}⭐ All Stations\n📋 Edit Stations\n🔧 Preferences\n🔎 Find Stations\n${R}❌ Quit Radion${n}"|eval "$PREF_SELECTOR_STR""\"$PROMPT_TEXT\"" )"
		elif [[ $PREF_SELECTOR == "dmenu" ]]||[[ $PREF_SELECTOR == "rofi" ]]
		then
			TAG_INDEX="$(echo -e "────────────────────── 🔖 Tags\n$(sed 's/ /\n/g' $HOME/.config/radion/stations.txt |grep "#"|grep -v "#Favorites"|sort|uniq|sed 's/#//g;s/$//g')\n────────────────────── ⭐ Favorites\n$(grep "#Favorites" $HOME/.config/radion/stations.txt|grep -v -E ^$|grep -v -E ^//|awk {'print $2'}|sed 's/-/ /g;s/~//g')""\n────────────────────── 🔧 Actions\n⭐ All Stations\n📋 Edit Stations\n🔧 Preferences\n🔎 Find Stations\n❌ Quit Radion"|eval "$PREF_SELECTOR_STR""\"$PROMPT_TEXT\"" )"
		fi
		if [[ $TAG_INDEX == "📋 Edit Stations" ]];then eval $PREF_EDITOR $HOME/.config/radion/stations.txt
		elif [[ $TAG_INDEX == "🔧 Preferences" ]];then eval $PREF_EDITOR $HOME/.config/radion/radion.conf;load_config
		elif [[ $TAG_INDEX == "❌ Quit Radion" ]];then clear;exit
		elif [[ $TAG_INDEX == "⭐ All Stations" ]]||[[ $TAG_INDEX == "" ]];then 	TAG=":";	echo -e "${Y}⭐ All Stations${n}";LOOP1=1
		elif [[ $TAG_INDEX == "🔎 Find Stations" ]];then $URL_OPENER "https://www.radio-browser.info/tags" ;echo -e "${R}NOTICE:\n${B}Press any key to continue with radion.${n}";read -sn 1 d
		elif [[ $TAG_INDEX == *"────────────"* ]];then LOOP1=0
		#echo -e "${C}Congratulations.\nYou selected the separator line.\nA wise choise.\n${B}Press any key to continue.${n}";read -sn 1 d
		elif [[ -n $(grep "~${TAG_INDEX// /-}~" $HOME/.config/radion/stations.txt|awk '{print $1}') ]]
		then
		STATION=$TAG_INDEX
		STATION_URL="$(grep ~${STATION// /-}~ $HOME/.config/radion/stations.txt|awk '{print $1}')"
		play_station
		else TAG="#$TAG_INDEX";echo -e "${Y}$TAG${n}";LOOP1=1;fi
	done
}

function select_station ()
{
	STATION="$(echo -e "$(grep "$TAG" $HOME/.config/radion/stations.txt|grep -v -E ^$|grep -v -E ^//|awk {'print $2'}|sed 's/-/ /g;s/~//g')\n────────────────────────\n👈 Go Back\n❌ Quit Radion"|eval "$PREF_SELECTOR_STR""\"Select $TAG Station \"")"
	if [[ $STATION == "❌ Quit Radion" ]];then clear;exit;fi
	if [[ $STATION == "👈 Go Back" ]];then STATION="";fi
	#if [[ $STATION == "────────────────────────" ]];then STATION="";echo -e "${C}Congratulations.\nYou selected the separator line.\nWise choise.\n${B}Press any key to continue.${n}";read -sn 1 d;fi
	if [[ -n $STATION ]]
	then
		STATION_URL="$(grep ~${STATION// /-}~ $HOME/.config/radion/stations.txt|awk '{print $1}')"
		play_station
#	else
#		echo -e "${R}ABORT?\n${B}Please press\nany key  ${Y}to continue${B}\nq        ${R}to QUIT${n}"
#		read -sn 1 v
#		if [[ $v == "q" ]];then exit;fi
#		if [[ $v == "Q" ]];then exit;fi
	fi
}

function main ()
{
	while true
	do
		if [[ $PREF_SELECTOR == "read" ]]
		then
			read_select_tag
			read_select_station
		else
			select_tag
			select_station
		fi
		clear
	done
}
###############################################

B="\x1b[38;5;60m" #Grid Color
Y="\033[1;33m"    #Yellow
G="\033[1;32m"    #Green
I="\e[7m" #Invert
R="\033[1;31m"    #Red
M="\033[1;35m"    #Magenta
C="\033[1;36m"    #Cyan
n=`tput sgr0`     #Normal
export B Y G I R M C n #in order to work with fzf
if [[ -e $HOME/.config/mpv/icyhistory.log ]]&&[[ $(cat $HOME/.config/mpv/icyhistory.log|wc -l) -gt 1000 ]]
	then
		tail -500 $HOME/.config/mpv/icyhistory.log >/tmp/icytemp.log&&mv /tmp/icytemp.log $HOME/.config/mpv/icyhistory.log
	fi #keep icyhistory.log under 1000 at each start.
load_config
