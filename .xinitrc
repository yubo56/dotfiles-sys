##!/usr/bin/dash

##font stuff
xset +fp /usr/share/fonts/TTF && xset fp rehash

##statusbar stuff
weatherLoop&
statusBar&

##various system settings
setxkbmap us -variant dvorak
ibus-daemon -drx
dconf load / < .dconf
xset r rate 150 60 && xset -dpms && xset s off
xrdb ~/.Xresources
redshift&
if [[ "$(hostname)" =~ ArchTest ]]; then
    synclient TouchpadOff=1
    synclient TapButton1=1
    xrandr --output HDMI1 --left-of eDP1
else
    xrandr --output eDP-1 --mode 1920x1200
fi
xmodmap ~/.xmodmap
rebg

#-----------------------------------------------------------AUTOSTART-----------------------------------------------
xscreensaver -nosplash &
goldendict &
exec dwmalt
