#!/system/bin/sh
[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "25000" ]  && abort "Requires Magisk v25 and Above"

internal_storage="/sdcard/DynamicDetachX"
# setup new sdcard dir
[ ! -d "$internal_storage" ] && {
    ui_print "- I: Setting up Internal Storage directory.."
    mkdir -p "$internal_storage"
}

# preserve the old Detach.txt
old_detach_txt="/data/adb/modules/dyndetachx/detach.txt"
tag_sample_detach=false
if [ -f "$old_detach_txt" ]; then 
    ui_print "- I: Upgrade detected!"
    ui_print "- I: Using old detach.txt.."
    if  cp -rf "$old_detach_txt" "$internal_storage/detach_old.txt" && \
        cp -rf "$old_detach_txt" "$MODPATH/detach.txt"; then
        ui_print "- I: Old detach.txt imported!" 
    else
        ui_print "- E: Failed to import detach.txt"
        tag_sample_detach=true
    fi
elif [ -f "$internal_storage/detach.txt" ]; then 
    ui_print "- I: Using Internal Storage detach.txt.."
    cp -rf "$internal_storage/detach.txt" "$MODPATH/detach.txt" || {
    ui_print "- E: Failed to utilize Internal Storage detach.txt"
    tag_sample_detach=true
    }
fi

if [ ! -f "$MODPATH/detach.txt" ]; then
    [ $tag_sample_detach != true ] && \
    ui_print "- I: New install detected."
    ui_print "- I: Creating sample detach.txt @ $internal_storage/detach.txt"
    # touch "$internal_storage/detach.txt"
    # touch "$internal_storage/enable"
    # touch "$internal_storage/replace"
    printf "com.google.android.apps.youtube.music\ncom.google.android.youtube" > "$internal_storage/detach.txt" || \
    ui_print "- E: Unable to create the detach.txt"
    ui_print "- I: Created sample detach.txt, please modify this file before you reboot."
fi

# set permissions
ui_print "- I: setting permissions"
set_perm "$MODPATH/detach.txt" root root 0755
set_perm_recursive "$MODPATH/bin" root root 0755 0755
# check for dynmount
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    ui_print "- E: Missing Magisk Process Monitor Module!"
    ui_print "- I: Opening link.. This is necessary for this module's functionality."
}