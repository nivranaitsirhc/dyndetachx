#!/system/bin/sh
# Dynamic Detached Module for ReVanced Assist Module
#
# magisk_module required
MODDIR="${0%/*}"
#MODNAME="${MODDIR##*/}"
# config-paths
# ------------
# Module & Magisk Busybox Binaries
export PATH="$MODDIR/bin:$MAGISKTMP/.magisk/busybox:$PATH"
# config-static_variables 
# -----------------------
path_detach_file_module="$MODDIR/detach.txt"
# -----------------------
PS=com.android.vending
DB=/data/data/$PS/databases
LDB=$DB/library.db
LADB=$DB/localappstate.db
toggled_playstore_disabled=false
toggled_foced_detach=false
detached_list=""
# Internal Storage folder
sdcard_folder=/sdcard/DynamicDetachX
# check for db files
{ [ ! -f "$LDB" ] || [ ! -f "$LADB" ]; } && {
	exit 1
}
# send notifications
send_notification() {
    su 2000 -c "cmd notification post -S bigtext -t 'DynDetachX' 'Tag' '$(printf "$1")'"
}
# tag files
[ -f "$sdcard_folder/enable" ] && {
	[ -f "$sdcard_folder/detach.txt" ] && {
		if [ -f "$sdcard_folder/replace" ];then 
			cp -rf "$sdcard_folder/detach.txt" "$MODDIR/detach.txt"
			rm -rf "$sdcard_folder/replace"
		elif [ -f "$sdcard_folder/merge" ];then
			sort -u "$MODDIR/detach.txt" "$sdcard_folder/detach.txt" > "$MODDIR/tmp_detach.txt"
			cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt"
			rm -rf "$MODDIR/tmp_detach.txt"
			rm -rf "$sdcard_folder/merge"
		fi
		[ -f "$sdcard_folder/mirror" ] && {
			cp -rf "$MODDIR/detach.txt" "$sdcard_folder/detach.txt"
		}
		chown root:root "$MODDIR/detach.txt"
		chmod 0644      "$MODDIR/detach.txt"
	}
	[ -f "$sdcard_folder/force" ] && {
		toggled_foced_detach=true
		rm -rf "$sdcard_folder/force"
	}
}
# check for detach file
[ ! -f "$path_detach_file_module" ] && {
	exit 1
}
# main-process
# ------------
while IFS= read -r package_name || [ -n "$package_name" ];do
    [ -z "$(dumpsys package "$package_name" | grep versionName | cut -d= -f 2 | sed -n '1p')" ] && {
		continue
	}
	[ $toggled_foced_detach != true ] && {
		get_LDB=$(sqlite3 "$LDB" "SELECT doc_id,doc_type FROM ownership" | grep "$package_name" | head -n 1 | grep -o 25)
	}
	# detach
	[ "$get_LDB" != "25" ] || [ $toggled_foced_detach = true ] && {
		# stop playstore
		[ $toggled_playstore_disabled = false ] && {
			am force-stop "$PS"
			cmd appops set --uid "$PS" GET_USAGE_STATS ignore
			# prevent multiple call
			toggled_playstore_disabled=true
		}
		# configure database
		sqlite3 $LDB	"UPDATE ownership	SET doc_type 	= '25'	WHERE doc_id		= '$package_name'";
		sqlite3 $LADB	"UPDATE appstate	SET auto_update = '2'	WHERE package_name	= '$package_name'";
		detached_list="$detached_list\n$package_name"
	}
done < "$path_detach_file_module"
# clear playstore cache
[ $toggled_playstore_disabled = true ] && {
	send_notification "Detached Apps: $detached_list"
	rm -rf /data/data/$PS/cache/*
	# start playstore
	am start -n "$(cmd package resolve-activity --brief $PS | tail -n 1)"
}