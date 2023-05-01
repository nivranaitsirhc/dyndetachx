#!/system/bin/sh
[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "25000" ]  && abort "Requires Magisk v25 and Above"


# preserve the old Detach.txt
old_detach_txt="/data/adb/modules/dyndetachx/detach.txt"
[ -f "$old_detach_txt" ] && {
    [ ! -d "/sdcard/DynamicDetachX" ] && mkdir -p "/sdcard/DynamicDetachX"
    cp -rf "$old_detach_txt" "sdcard/DynamicDetachX/detach_old.txt"
    cp -rf "$old_detach_txt" "$MODPATH/detach.txt"
    set_perm "$MODPATH/detach.txt" root root 0755
}

# check for dynmount
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    ui_print "Missing Magisk Process Monitor. Please install it after installing this Module."
}