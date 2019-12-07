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
xinput --set-prop :MOUSE_X_IDX 'libinput Accel Profile Enabled' 0, 1

#-----------------------------------------------------------AUTOSTART-----------------------------------------------
xscreensaver -nosplash &
goldendict &
redshift&
ibus-daemon -drx

## statusbar stuff
weatherLoop&
statusBar&

if [[ "$(hostname)" =~ ArchTest ]]; then
    synclient TouchpadOff=1
    synclient TapButton1=1
    xrandr --output HDMI1 --left-of eDP1
else
    xrandr --output eDP-1 --mode 1920x1200
fi
exec dwmalt
