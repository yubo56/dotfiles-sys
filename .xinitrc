#!/usr/bin/dash

if [[ "$(hostnamectl hostname)" =~ ArchTest ]]; then
    echo "disable" | sudo tee /sys/firmware/acpi/interrupts/gpe61
fi
# if [[ "$(hostnamectl hostname)" =~ YuboAcer ]]; then
#     echo 0 | sudo tee /sys/devices/system/cpu/cpufreq/boost
# fi

## font stuff
xset +fp /usr/share/fonts/TTF && xset fp rehash

## try to set mouse accel
for i in $(xinput | 'grep' pointer | sed -rn 's/.*id=([0-9]+).*/\1/p'); do
    xinput --set-prop $i 'libinput Accel Profile Enabled' 0, 1 2> /dev/null
done

## transparency
# ~/bin/toggle-xcompmgr
## Alt: zoom share screen
xcompmgr -o.00 &

#-----------------------------------------------------------AUTOSTART-----------------------------------------------
xscreensaver -nosplash &

## various system settings
dconf load / < .dconf
xset -dpms && xset s off
xrdb ~/.Xresources
# xkbset exp =bo && xkbset bo 30
dwm_usbconnect
redshift &!
dwm_rebg

# seems like need to start ibus after X server launches
# ibus-daemon -drx

## statusbar stuff
statusLoop &!

# try to enable bluetooth
bluetoothctl power on || :

gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
gsettings set org.gnome.desktop.peripherals.mouse double-click 100

exec dwmalt
