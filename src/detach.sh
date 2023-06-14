#!/system/bin/sh
# shellcheck shell=bash
# Dynamic Detached Module
#
# magisk_module required
MODDIR="${0%/*}"
# MODNAME="${MODDIR##*/}"
# config-paths
# ------------
# magisk Busybox & module local binaries
export PATH="$MODDIR/bin:$PATH:$MAGISKTMP/.magisk/busybox:$PATH"
# config-static_variables 
# -----------------------
path_detach_file_module="$MODDIR/detach.txt"
# -----------------------
PS=com.android.vending
DB=/data/data/$PS/databases
LDB=$DB/library.db
LADB=$DB/localappstate.db
toggled_playstore_disabled=false
toggled_forced_detach=false
detached_list=""

# Internal Storage folder
internal_storage=/sdcard/DynamicDetachX

# check for db files
{ [ ! -f "$LDB" ] || [ ! -f "$LADB" ]; } && {
	exit 1
}
# send notifications
send_notification() {
    su 2000 -c "cmd notification post -S bigtext -t 'DynDetachX' 'Tag' '$(printf "$1")'"
}

# Tag Files
[ -f "$internal_storage/enable" ] && {
	# Enable Tag File Process
	[ -f "$internal_storage/detach.txt" ] && {
		# internal storage detach.txt is present

		if [ -f "$internal_storage/replace" ];then 
			# replace the module detach.txt
			cp -rf "$internal_storage/detach.txt" "$MODDIR/detach.txt"
			rm -rf "$internal_storage/replace"
		elif [ -f "$internal_storage/merge" ];then
			# merge both module and internal storage detach.txt
			sort -u "$MODDIR/detach.txt" "$internal_storage/detach.txt" > "$MODDIR/tmp_detach.txt"
			cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt"
			rm -rf "$MODDIR/tmp_detach.txt"
			rm -rf "$internal_storage/merge"
		fi

		[ -f "$internal_storage/mirror" ] && {
			# copy detach.txt from module dir to internal storage
			cp -rf "$MODDIR/detach.txt" "$internal_storage/detach.txt"
		}

		chown root:root "$MODDIR/detach.txt"
		chmod 0644      "$MODDIR/detach.txt"
	}

	[ -f "$internal_storage/force" ] && {
		# flag the force detach script
		toggled_forced_detach=true
		rm -rf "$internal_storage/force"
	}
}

# check for detach file
[ ! -f "$path_detach_file_module" ] && {
	mkdir -p "$internal_storage"
	printf "$(date) - missing module dir detach.txt" > "$internal_storage/missing_detach.txt"
	exit 1
}

# main-process
# ------------
while IFS=  read -r package_name || [ -n "$package_name" ];do
	# iterate all the package name in detach.txt

	# verify package name
    [ -z "$(dumpsys package "$package_name" | grep versionName | cut -d= -f 2 | sed -n '1p')" ] && {
		# package_name is not installed, skip to the next iteration
		continue
	}


	[ $toggled_forced_detach != true ] && {
		# get LDB value, no need to check if force flag is enabled
		get_LDB=$(sqlite3 "$LDB" "SELECT doc_id,doc_type FROM ownership" | grep "$package_name" | head -n 1 | grep -o 25)
	}

	# verification if detach is need unless force flash is enabled
	[ "$get_LDB" != "25" ] || [ $toggled_forced_detach = true ] && {

		# stop playstore only once
		[ $toggled_playstore_disabled != true ] && {

			# stop the playstore
			am force-stop "$PS"
			cmd appops set --uid "$PS" GET_USAGE_STATS ignore

			# prevent multiple call
			toggled_playstore_disabled=true
		}

		# update database to disable apps
		sqlite3 $LDB	"UPDATE ownership	SET doc_type 	= '25'	WHERE doc_id		= '$package_name'";
		sqlite3 $LADB	"UPDATE appstate	SET auto_update = '2'	WHERE package_name	= '$package_name'";

		# generate detach list
		detached_list="$detached_list\n$package_name"
	}
done < "$path_detach_file_module"

# clear playstore cache
[ $toggled_playstore_disabled = true ] && {
	send_notification "Detached Apps: $detached_list"
	rm -rf /data/data/$PS/cache/*

	# restart playstore only after a successfully detached, prevent loops
	[ ! -f "$MODDIR/detached" ] && {
		# start playstore
		# sleep 3
		touch "$MODDIR/detached"
		am start -n "$(cmd package resolve-activity --brief $PS | tail -n 1)"
		
		# skip cleanup
		return 0
	}
}

# clean up
[ -f "$MODDIR/detached" ] && rm -rf "$MODDIR/detached"