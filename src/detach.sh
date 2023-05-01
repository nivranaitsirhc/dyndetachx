#!/system/bin/sh
# Dynamic Detached Module for ReVanced Assist Module

# magisk_module required
MODDIR="${0%/*}"
MODNAME="${MODDIR##*/}"

# config-paths
# ------------

# magisk Busybox
export PATH="$MAGISKTMP/.magisk/busybox:$PATH"
# module local binaries
export PATH="$MODDIR/bin:$PATH"


# config-static_variables 
# -----------------------
# path_detach_file_magisk="/data/adb/detach.sh"
path_detach_file_module="$MODDIR/detach.txt"
# path_detach_file="/data/local/tmp/detach.sh"
# -----------------------
PS=com.android.vending
DB=/data/data/$PS/databases
LDB=$DB/library.db
LADB=$DB/localappstate.db
toggled_playstore_disabled=false
detached_list=""

#
sdcard_folder=/sdcard/DynamicDetachX

# check for detach file
if [ ! -f "$path_detach_file_module" ]; then
	exit 1
fi

send_notification() {
    su 2000 -c "cmd notification post -S bigtext -t 'DynDetachX' 'Tag' '$(printf $1)'"
}

# tag files
[ -f "$sdcard_folder/enable" ] && [ -f "$sdcard_folder/detach.txt" ] && {
    if [ -f "$sdcard_folder/replace" ];then 
        cp -rf "$sdcard_folder/detach.txt" "$MODDIR/detach.txt"
        rm -rf "$sdcard_folder/replace"
    elif [ -f "$sdcard_folder/update" ];then
        sort -u "$MODDIR/detach.txt" "$sdcard_folder/detach.txt" > "$MODDIR/tmp_detach.txt"
        cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt"
        rm -rf "$MODDIR/tmp_detach.txt"
    	rm -rf "$MODDIR/update"
    fi
    [ -f "$sdcard_folder/mirror" ] && {
        cp -rf "$MODDIR/detach.txt" "$sdcard_folder/detach.txt"
    }

    chown root:root "$MODDIR/detach.txt"
    chmod 0755      "$MODDIR/detach.txt"
}


# main-process
# ------------
while read package_name
do
    if [ -z "$(dumpsys package "$package_name" | grep versionName | cut -d= -f 2 | sed -n '1p')" ]; then
		continue
	fi
	
	get_LDB=$(sqlite3 "$LDB" "SELECT doc_id,doc_type FROM ownership" | grep "$package_name" | head -n 1 | grep -o 25)
	
	# detach
	if [ "$get_LDB" != "25" ]; then

		# stop playstore
		if [ $toggled_playstore_disabled = false ]; then
			am force-stop "$PS"
			cmd appops set --uid "$PS" GET_USAGE_STATS ignore
			# prevent multiple call
			toggled_playstore_disabled=true
		fi
	
		# configure database
		sqlite3 $LDB	"UPDATE ownership	SET doc_type 	= '25'	WHERE doc_id		= '$package_name'";
		sqlite3 $LADB	"UPDATE appstate	SET auto_update = '2'	WHERE package_name	= '$package_name'";

		detached_list="$detached_list\n$package_name"
	fi
	
done < "$path_detach_file_module"

# clear playstore cache
if [ $toggled_playstore_disabled = true ]; then
	send_notification "Detached Apps:$detached_list"
	rm -rf /data/data/$PS/cache/*
fi