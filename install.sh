#!/bin/bash

uninstall() {
    rm -vf "$HOME"/.local/bin/radion.sh
    rm -vf "$HOME"/.local/bin/record-toggle.sh
    rm "$HOME"/.config/mpv/scripts/icecast-logger.lua
    rm "$HOME"/.config/mpv/icyhistory.log
}

case $1 in
 install)
  #make scripts executable, copy them to the path:
  chmod +x radion.sh record-toggle.sh
  cp radion.sh record-toggle.sh "$HOME"/.local/bin/
  #Create necessary directories, copy files:
  mkdir "$HOME"/.config/radion/
  if [[ ! -d "$HOME"/Music/radion/ ]];then mkdir "$HOME"/Music/radion/ ;fi
  cp stations.txt "$HOME"/.config/radion/
  cp radion.conf "$HOME"/.config/radion/
  cp icecast-logger.lua -t "$HOME"/.config/mpv/scripts/
  cp radion-rofi-theme.rasi "$HOME"/.config/radion/
  cp -r png/  "$HOME"/.config/radion/
  ;;
 uninstall)uninstall
  ;;
 purge)uninstall
  rm -vrf "$HOME"/.config/radion
  ;;
 *)
  printf "USAGE: %s <command>\n" "$0"
  printf "   install   :installs radion\n"
  printf "   uninstall :uninstalls the radion executables, lua \n"
  printf "   purge     :completely uninstalls radion, including all radion config files\n"
  ;;
esac

exit 0
