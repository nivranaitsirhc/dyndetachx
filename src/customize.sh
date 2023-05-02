#!/system/bin/sh
[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "25000" ]  && abort "Requires Magisk v25 and Above"

sdcard_folder="/sdcard/DynamicDetachX"
# setup new sdcard dir
[ ! -d "$sdcard_folder" ] && {
    ui_print "* setting up sdcard folder"
    mkdir -p "$sdcard_folder"
    cp -rf "$MODPATH/detach.txt" "$sdcard_folder/detach.txt"
}


# preserve the old Detach.txt
old_detach_txt="/data/adb/modules/dyndetachx/detach.txt"
if [ -f "$old_detach_txt" ]; then 
    ui_print "* using old detach.txt"
    cp -rf "$old_detach_txt" "sdcard/DynamicDetachX/detach_old.txt"
    cp -rf "$old_detach_txt" "$MODPATH/detach.txt"
    set_perm "$MODPATH/detach.txt" root root 0755
elif [ -f "$sdcard_folder/detach.txt" ]; then 
    ui_print "* using sdcard detach.txt"
    cp -rf "$sdcard_folder/detach.txt" "$MODDIR/detach.txt"
    set_perm "$MODPATH/detach.txt" root root 0755
else
    ui_print "* creating $sdcard_folder/detach.txt"
    touch "$sdcard_folder/detach.txt"
    # touch "$sdcard_folder/enable"
    # touch "$sdcard_folder/replace"
    printf "com.google.android.apps.youtube.music\ncom.google.android.youtube" > "$sdcard_folder/detach.txt"
    ui_print "* created default detach.txt, please modify this file before you reboot."
fi

# check for dynmount
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    ui_print "* missing Magisk Process Monitor. Please install it after this module."
}