#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
    exit 0
fi

case ${PERCENTAGE} in
  # 87) ICON="􀺸" COLOR=0xffff3010 ;; Just for testing purposes

  100) ICON="􀛨" COLOR=0xff00ff00 ;;
  9[0-9]) ICON="􀛨" COLOR=0xff40f020 ;;
  8[0-9]) ICON="􀛨" COLOR=0xff70f020 ;;

  7[0-9]) ICON="􀺸" COLOR=0xff75c860 ;;
  6[0-9]) ICON="􀺸" COLOR=0xffa5c840 ;;
  5[5-9]) ICON="􀺸" COLOR=0xffd5c840 ;;

  5[0-4]) ICON="􀺶" COLOR=0xffd5c840 ;;
  4[0-9]) ICON="􀺶" COLOR=0xffe5b820 ;;
  3[5-9]) ICON="􀺶" COLOR=0xffefb010 ;;

  3[0-4]) ICON="􀛩" COLOR=0xffefb010 ;;
  2[0-9]) ICON="􀛩" COLOR=0xfff27010 ;;
  1[0-9]) ICON="􀛩" COLOR=0xffff5010 ;;
  *) ICON="􀛪" COLOR=0xffff3010 ;;
esac

if [[ $CHARGING != "" ]]; then
  ICON="􀢋"
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set $NAME icon=$ICON icon.color=$COLOR label="${PERCENTAGE}%"
