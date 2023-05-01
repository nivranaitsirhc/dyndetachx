#!/system/bin/sh
[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "25000" ]  && abort "Requires Magisk v25 and Above"

sdcard_folder="/sdcard/DynamicDetachX"
# setup new sdcard dir
[ ! -d "$sdcard_folder" ] && {
    ui_print "- setting up sdcard folder"
    mkdir -p "$sdcard_folder"
    cp -rf "$MODPATH/detach.txt" "$sdcard_folder/detach.txt"
}

# preserve the old Detach.txt
old_detach_txt="/data/adb/modules/dyndetachx/detach.txt"
[ -f "$old_detach_txt" ] && {
    ui_print "- updating old detach.txt"
    cp -rf "$old_detach_txt" "sdcard/DynamicDetachX/detach_old.txt"
    cp -rf "$old_detach_txt" "$MODPATH/detach.txt"
    set_perm "$MODPATH/detach.txt" root root 0755
}

# check for dynmount
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    ui_print "Missing Magisk Process Monitor. Please install it after installing this Module."
}