#!/usr/bin/env bash

preserve() {
  local SRC=$1
  local DST=$2
  test ! -f ${DST}/${SRC} && install -Dvcm644 -b ${SRC} -t ${DST}
}

uninstall() {
    rm -vf ~/.local/bin/radion.sh
    rm -vf ~/.local/bin/record-toggle.sh
    rm ~/.config/mpv/scripts/icecast-logger.lua
    rm ~/.config/mpv/icyhistory.log
}

case $1 in
  install)
    preserve stations.txt ~/.config/radion
    preserve radion.conf ~/.config/radion
    install -Dvcm644 -b icecast-logger.lua -t ~/.config/mpv/scripts/
    install -Dvcm644 -b radion-rofi-theme.rasi -t ~/.config/radion/
    install -Dvcm755 -d ~/Music/radion/
    install -Dvcm755 radion.sh ~/.local/bin/
    install -Dvcm755 record-toggle.sh ~/.local/bin/
    install -Dvcm644 png/* -t ~/.config/radion/png
    ;;
  uninstall)
    uninstall
    ;;
  purge)
    uninstall
    rm -vrf ~/.config/radion
    ;;
  *)
    printf "USAGE: %s <command>\n" "$0"
    printf "   install    installs radion\n"
    printf "   uninstall  uninstalls the radion executables, ~/.config/mpv/scripts/icecast-logger.lua\n"
    printf "   purge      completely uninstalls radion, including all radion config files\n"
    ;;
esac

exit 0
