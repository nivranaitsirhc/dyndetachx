#!/system/bin/sh
while [ "$(resetprop sys.boot_completed)" != 1 ]; do
    sleep 1
done
sleep 1
MODDIR="${0%/*}"

sdcard_folder="/sdcard/DynamicDetachX"
[ -f "$MODDIR/detach.txt" ] && [ -f "$sdcard_folder/detach.txt" ] && {
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
    
    # cleanup
    rm -rf "$MODDIR/enable"
    rm -rf "$MODDIR/replace"
    rm -rf "$MODDIR/update"

    chown root:root "$MODDIR/detach.txt"
    chmod 0755      "$MODDIR/detach.txt"
}
[ ! -d "$sdcard_folder" ] && mkdir -p "$sdcard_folder"