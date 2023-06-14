#!/system/bin/sh
# shellcheck shell=bash
# Dynamic Detached Module
#
# magisk_module required
MODDIR="${0%/*}"
# MODNAME="${MODDIR##*/}"
MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin
# config-paths
# ------------
# magisk Busybox & module local binaries
export PATH="$MODDIR/bin:$MAGISKTMP/.magisk/busybox:$PATH"
# config-static_variables 
# -----------------------
path_file_module_detach="$MODDIR/detach.txt"
path_dir_storage="/sdcard/DynamicMountManagerX"
path_file_tag_global_debug="$path_dir_storage/debug"
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
# dummy fn
logme(){ :; }
# source logger from lib
[ -d "$MODDIR/lib" ] && {
    # logger
    [ -f "$MODDIR/lib/logger.sh" ] && . "$MODDIR/lib/logger.sh"
}
# logger configs
logger_process=$(printf "%-6s %-6s" "$UID" "$PID")
logger_special=$(printf "%-18s - %s" "$(basename "$0"):$STAGE" "$PROC")
# logger
logger_check(){
    if [[ -v LOGGER_MODULE ]] && [ -f "$path_file_tag_global_debug" ]; then
        [ -f "$path_file_logs" ] && {
            cat "$path_file_logs" >> "$path_dir_storage/module.log"
            printf "" > "$path_file_logs"
        }
    fi
}
# send notifications
send_notification() {
    su 2000 -c "cmd notification post -S bigtext -t 'DynDetachX' 'Tag' '$(printf "$1")'"
}

# log
logme stats "initializing detach.sh.."

# Tag Files
[ -f "$internal_storage/enable" ] && {
	logme debug "tag-files: enabled by $internal_storage/enable"

	# Enable Tag File Process
	[ -f "$internal_storage/detach.txt" ] && {
		# internal storage detach.txt is present
		logme debug "tag-files: Internal Storage detach.txt detected"

		if [ -f "$internal_storage/replace" ];then 
			logme stats "tag-files: detected replace tag, replacing module tag detach.txt with Internal Storage."
			# replace the module detach.txt
			cp -rf "$internal_storage/detach.txt" "$MODDIR/detach.txt" || logme error "tag-files: replace: failed to copy detach.txt to module"
			rm -rf "$internal_storage/replace"
		elif [ -f "$internal_storage/merge" ];then
			logme stats "tag-files: detected merge tag, merging detach.txt from Internal Storage to Module."
			# merge both module and internal storage detach.txt
			sort -u "$MODDIR/detach.txt" "$internal_storage/detach.txt" > "$MODDIR/tmp_detach.txt" || logme error "tag-files: merge: failed to merge detach.txt"
			cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt" || logme error "tag-files: merge: failed to copy detach.txt to module"
			rm -rf "$MODDIR/tmp_detach.txt"
			rm -rf "$internal_storage/merge"
		fi

		[ -f "$internal_storage/mirror" ] && {
			logme stats "tag-files: detected mirror tag, copying detach.txt from module to Internal Storage"
			# copy detach.txt from module dir to internal storage
			cp -rf "$MODDIR/detach.txt" "$internal_storage/detach.txt" || logme error "tag-files: mirror: failed to copy detach.txt to Internal Storage"
		}

		if	chown root:root "$MODDIR/detach.txt" && \
			chmod 0644      "$MODDIR/detach.txt"; then
			logme debug "tag-files: done setting permissions."
		else
			logme warn "tag-files: failed to set permissions"
		fi
	}

	[ -f "$internal_storage/force" ] && {
		logme stats "tag-files: detected force tag, setting force toggle to true. This will ignore checks during detach process."
		# flag the force detach script
		toggled_forced_detach=true
		rm -rf "$internal_storage/force"
	}
}

# check for detach file
[ ! -f "$path_file_module_detach" ] && {
	mkdir -p "$internal_storage"
	printf "$(date) - missing module dir detach.txt" > "$internal_storage/missing_detach.txt"
	logme error "exiting due missing detach.txt in module."
	exit 1
}

# main-process
# ------------
logme stats "loop: starting detach process.."
logme debug "loop: querying package_name's from detach.txt.."
while IFS=  read -r package_name || [ -n "$package_name" ];do
	# iterate all the package name in detach.txt
	logme debug "loop: processing $package_name.."
	
	# verify package name
    [ -z "$(dumpsys package "$package_name" | grep versionName | cut -d= -f 2 | sed -n '1p')" ] && {
		# package_name is not installed, skip to the next iteration
		logme debug "loop: skipping,  $package_name is not installed."
		continue
	}

	[ $toggled_forced_detach != true ] && {
		# get LDB value, no need to check if force flag is enabled
		get_LDB=$(sqlite3 "$LDB" "SELECT doc_id,doc_type FROM ownership" | grep "$package_name" | head -n 1 | grep -o 25)
		[ -z $get_LDB ] && {
			logme debug "loop: skipping,  $package_name failed when querying for LDB"
			continue
		}
	}

	# verification if detach is need unless force flash is enabled
	if { [ "$get_LDB" != "25" ] || [ $toggled_forced_detach = true ]; };then 

		# stop playstore only once
		[ $toggled_playstore_disabled != true ] && {
			logme debug "loop: disabling PlayStore and setting GET_USAGE_STATS to ignore"

			# stop the playstore
			am force-stop "$PS" ||\
			logme error "loop: failed to stop $PS"
			cmd appops set --uid "$PS" GET_USAGE_STATS ignore ||\
			logme error "loop: failed to set GET_USAGE_STATS"

			# prevent multiple call
			toggled_playstore_disabled=true
		}
		logme stats "loop: detaching  $package_name.."
		# update database to disable apps
		sqlite3 $LDB	"UPDATE ownership	SET doc_type 	= '25'	WHERE doc_id		= '$package_name'" ||\
		logme error "loop: failed to set DB ownership"
		sqlite3 $LADB	"UPDATE appstate	SET auto_update = '2'	WHERE package_name	= '$package_name'" ||\
		logme error "loop: failed to set DB disable auto_update"

		# generate detach list
		detached_list="$detached_list\n$package_name"
	else 
		logme debug "loop: skipping,  $package_name already detached!"
	fi
done < "$path_file_module_detach"
logme stats "loop: detach process done!"

# clear playstore cache
[ $toggled_playstore_disabled = true ] && {
	logme stats "cleanup: clearing PlayStore Cache.."
	send_notification "Detached Apps: $detached_list"
	rm -rf /data/data/$PS/cache/* ||\
	logme error "cleanup: failed to clear cache"

	# restart playstore only after a successfully detached, prevent loops
	[ ! -f "$MODDIR/detached" ] && {
		# start playstore
		# sleep 3
		logme debug "cleanup: restarting PlayStore and creating detached tag file."
		touch "$MODDIR/detached" ||\
		logme error "cleanup: failed to create tag detached tag file."
		{ am start -n "$(cmd package resolve-activity --brief $PS | tail -n 1)" && { logger_check && return 0;}; } ||\
		logme error "cleanup: failed to start PlayStore"
	}
}

# clean up
[ -f "$MODDIR/detached" ] && {
	logme debug "cleanup: removed detached tag file."
	rm -rf "$MODDIR/detached"
}
logger_check