##!/usr/bin/dash

## font stuff
xset +fp /usr/share/fonts/TTF && xset fp rehash

## various system settings
setxkbmap us -variant dvorak
dconf load / < .dconf
xset r rate 150 60 && xset -dpms && xset s off
xrdb ~/.Xresources
xmodmap ~/.xmodmap
dwm_rebg

## transparency
~/bin/toggle-xcompmgr

#-----------------------------------------------------------AUTOSTART-----------------------------------------------
xscreensaver -nosplash &
goldendict &
redshift&
ibus-daemon -rxv > tmp/ibus.log &

## statusbar stuff
weatherLoop&
statusBar&

if [[ "$(hostname)" =~ ArchTest ]]; then
    synclient TouchpadOff=1
    synclient TapButton1=1
    xrandr --output HDMI1 --left-of eDP1
else if [[ "$(hostname)" =~ BlendArch ]]; then
    xrandr\
        --output HDMI-1 --auto\
        --output DP-1 --auto --rotate left --right-of HDMI-1\
        --output eDP-1 --auto --right-of DP-1 --mode 1920x1200
else if [[ "$(hostname)" =~ YuboDesktop ]]; then
    xrandr --output HDMI-1 --rotate left --right-of DP-1
fi; fi; fi
exec dwmalt
