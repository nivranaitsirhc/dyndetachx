#!/system/bin/sh
until [ "$(getprop sys.boot_completed)" = 1 ];do sleep 1;done
sdcard_folder="/sdcard/DynamicDetachX"
until [ -d "/sdcard/" ];do sleep 1;done
MODDIR="${0%/*}"
[ -f "$sdcard_folder/detach.txt" ] && {
    if [ -f "$MODDIR/detach.txt" ]; then
        [ -f "$sdcard_folder/enable" ] && {
            if [ -f "$sdcard_folder/replace" ];then 
                cp -rf "$sdcard_folder/detach.txt" "$MODDIR/detach.txt"
            elif [ -f "$sdcard_folder/update" ];then
                sort -u "$MODDIR/detach.txt" "$sdcard_folder/detach.txt" > "$MODDIR/tmp_detach.txt"
                cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt"
                rm -rf "$MODDIR/tmp_detach.txt"
            fi
            [ -f "$sdcard_folder/mirror" ] && {
                cp -rf "$MODDIR/detach.txt" "$sdcard_folder/detach.txt"
            }
        }
    else
        cp -rf "$sdcard_folder/detach.txt" "$MODDIR/detach.txt"
    fi

    # cleanup
    rm -rf "$sdcard_folder/enable"
    rm -rf "$sdcard_folder/replace"
    rm -rf "$sdcard_folder/update"

    chown root:root "$MODDIR/detach.txt"
    chmod 0644      "$MODDIR/detach.txt"
}