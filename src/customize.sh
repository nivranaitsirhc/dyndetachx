#!/system/bin/sh
[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "24300" ]  && abort "Requires Magisk v24.3 and Above"

internal_storage="/sdcard/DynamicDetachX"
# setup new sdcard dir
[ ! -d "$internal_storage" ] && {
    ui_print "- setting up Internal Storage directory.."
    mkdir -p "$internal_storage"
}

# preserve the old Detach.txt
old_detach_txt="/data/adb/modules/dyndetachx/detach.txt"
tag_sample_detach=false
if [ -f "$old_detach_txt" ]; then 
    ui_print "- upgrade detected!"
    ui_print "- using old detach.txt.."
    if  cp -rf "$old_detach_txt" "$internal_storage/detach_old.txt" && \
        cp -rf "$old_detach_txt" "$MODPATH/detach.txt"; then
        ui_print "- old detach.txt imported!" 
    else
        ui_print "- failed to import detach.txt"
        tag_sample_detach=true
    fi
elif [ -f "$internal_storage/detach.txt" ]; then 
    ui_print "- using Internal Storage detach.txt.."
    cp -rf "$internal_storage/detach.txt" "$MODPATH/detach.txt" || {
    ui_print "- failed to utilize Internal Storage detach.txt"
    tag_sample_detach=true
    }
fi

if [ ! -f "$MODPATH/detach.txt" ]; then
    [ $tag_sample_detach != true ] && \
    ui_print "- new install detected."
    ui_print "- creating sample detach.txt @ $internal_storage/detach.txt"
    # touch "$internal_storage/detach.txt"
    # touch "$internal_storage/enable"
    # touch "$internal_storage/replace"
    printf "com.google.android.apps.youtube.music\ncom.google.android.youtube" > "$internal_storage/detach.txt" || \
    ui_print "- unable to create the detach.txt"
    ui_print "- created sample detach.txt, please modify this file before you reboot."
fi

# set permissions
ui_print "- setting permissions."
set_perm_recursive "$MODPATH/bin"   root root 0755 0755 u:object_r:system_file:s0
set_perm_recursive "$MODPATH/lib"   root root 0755 0644 u:object_r:system_file:s0
set_perm "$MODPATH/detach.sh"       root root 0755 u:object_r:system_file:s0
set_perm "$MODPATH/service.sh"      root root 0755 u:object_r:system_file:s0

# check for proccess monitor
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    MPMURL=http://github.com/HuskyDG/magisk_proc_monitor
    ui_print "* process monitor tool is not installed"
    ui_print "* opening link to $MPMURL"
    sleep 3
    am start -a android.intent.action.VIEW -d "$MPMURL" &>/dev/null
}