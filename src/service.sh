#!/system/bin/sh
# shellcheck shell=bash

# Wait until boot is completed
until [ "$(getprop sys.boot_completed)" = 1 ];do sleep 1;done

# Magisk Variables
# MODDIR="${0%/*}"
# MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin
# MIRROR="$MAGISKTMP/.magisk/mirror"

# BootScript Service
# - At every boot check if a detach.txt is present in the designated directory
# - Source this file and perform necessary task
internal_storage="/sdcard/DynamicDetachX"
# @internal storage
[ -f "$internal_storage/detach.txt" ] && {
    # detach.txt is present
    if [ -f "$MODDIR/detach.txt" ]; then
        # detach.txt is also present in module dir.
        
        [ -f "$internal_storage/enable" ] && {
            # enable tag is present in internal storage 
            
            if [ -f "$internal_storage/replace" ];then 
                # replace tag is present, replacing module detach.txt
                cp -rf "$internal_storage/detach.txt" "$MODDIR/detach.txt"
            elif [ -f "$internal_storage/merge" ];then
                # merge tag is present, merging both detach.txt
                sort -u "$MODDIR/detach.txt" "$internal_storage/detach.txt" > "$MODDIR/tmp_detach.txt"
                cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt"
                rm -rf "$MODDIR/tmp_detach.txt"
            fi

            [ -f "$internal_storage/mirror" ] && {
                # mirror tag is present, copy the module detach.txt to internal storage
                cp -rf "$MODDIR/detach.txt" "$internal_storage/detach.txt"
            }
        }
    else
        # no module detach.txt is present in module copying the detach from internal storage.
        cp -rf "$internal_storage/detach.txt" "$MODDIR/detach.txt"
    fi
    # cleanup
    rm -rf "$internal_storage/enable"
    rm -rf "$internal_storage/replace"
    rm -rf "$internal_storage/merge"
    # permissions
    chown root:root "$MODDIR/detach.txt"
    chmod 0644      "$MODDIR/detach.txt"
}