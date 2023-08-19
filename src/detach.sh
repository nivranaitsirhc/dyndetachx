#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

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
path_dir_storage="/sdcard/DynamicDetachX"
# -----------------------
[[ ! -v PROC ]] && PROC=com.android.vending
PS=com.android.vending
DB=/data/data/$PS/databases
LDB=$DB/library.db
LADB=$DB/localappstate.db
toggled_playstore_disabled=false
toggled_forced_detach=false
detached_list=""

# log instance
path_file_logs="$MODDIR/logs/$(date +%y-%m-%d_%H-%M-%S)"
# create module logs dir if not present
[ ! -d "$MODDIR/logs" ] && mkdir -p "$MODDIR/logs"

# logger library required variables
# -----------------------
# [[ -v STAGE ]]  || export STAGE=boot-service
# [[ -v PROC ]]   || export PROC=magisk
# [[ -v UID ]]    || { UID=$(id -g) && export UID; }
# [[ -v PID ]]    || export PID=$$

# logger dummy function
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
    # check if logger module is loaded
    if [[ -v LOGGER_MODULE ]]; then
        if [ -f "$path_dir_storage/debug" ]; then
            # concat to internal storage module.log
            [ -f "$path_file_logs" ] && {
                cat "$path_file_logs" >> "$path_dir_storage/module.log"
            }
        else 
            # concat to module dir log
            cat "$path_file_logs" >> "$MODDIR/logs/module.log"
        fi
        rm "$path_file_logs"
    fi
}

# send notifications
send_notification() {
    su 2000 -c "cmd notification post -S bigtext -t 'DynDetachX' 'Tag' '$(printf "$1")'"
}

# clean-exit
clean_exit() {
    local exitCode="${1:-0}"
    logger_check
    return "$exitCode"
}

# current detach
[ -f "$MODDIR/running" ] && {
    # check if running is within threshold
    runningCount=$(cat "$MODDIR/running")
    if { [ -n "$runningCount" ] && [ "$runningCount" -ge "5" ]; }; then
        logme stats "running tag: Reached the max allowed skip. Removing tag and continuing.."
        rm -f "$MODDIR/running"
    else
        currentCount=$(("$runningCount" + 1))
        echo "$currentCount" > "$MODDIR/running"
        logme debug "running tag: current count is $currentCount"
        logme stats "running tag: skipping.. a detach process is still in progress."
        clean_exit 1
    fi
}

# recent detach 
[ -f "$MODDIR/detached" ] && {
    logme stats "skipping.. a recent detached prevented this run."
    rm -rf "$MODDIR/detached"
    clean_exit 1
}

# sanity checks
{ [ ! -f "$LDB" ] || [ ! -f "$LADB" ]; } && {
    logme error "exiting.. unable to locate LDB or LADB"
    clean_exit 1
}

# Start
logme stats "initializing detach.sh.."
# mark this run
touch "$MODDIR/running"


# Tag Files
[ -f "$path_dir_storage/enable" ] && {
    logme debug "tag-files: enabled by $path_dir_storage/enable"

    # Enable Tag File Process
    [ -f "$path_dir_storage/detach.txt" ] && {
        # internal storage detach.txt is present
        logme debug "tag-files: Internal Storage detach.txt detected"

        if [ -f "$path_dir_storage/replace" ];then 
            logme stats "tag-files: detected replace tag, replacing module tag detach.txt with Internal Storage."
            # replace the module detach.txt
            if ! cp -rf "$path_dir_storage/detach.txt" "$MODDIR/detach.txt"; then
                logme error "tag-files: replace: failed to copy detach.txt to module"
            fi
            # remove tag file
            rm -rf "$path_dir_storage/replace"
            setup_permissions=true
        elif [ -f "$path_dir_storage/merge" ];then
            logme stats "tag-files: detected merge tag, merging detach.txt from Internal Storage to Module."
            # merge both module and internal storage detach.txt
            if ! sort -u "$MODDIR/detach.txt" "$path_dir_storage/detach.txt" > "$MODDIR/tmp_detach.txt"; then
                logme error "tag-files: merge: failed to merge detach.txt"
            fi
            # rename temp detach to final detach
            if ! cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt"; then
                logme error "tag-files: merge: failed to copy detach.txt to module"
            fi
            # clean old detach.txt
            rm -rf "$MODDIR/tmp_detach.txt"
            rm -rf "$path_dir_storage/merge"
            setup_permissions=true
        fi

        [ -f "$path_dir_storage/mirror" ] && {
            logme stats "tag-files: detected mirror tag, copying detach.txt from module to Internal Storage"
            # copy detach.txt from module dir to internal storage
            if ! cp -rf "$MODDIR/detach.txt" "$path_dir_storage/detach.txt"; then
                logme error "tag-files: mirror: failed to copy detach.txt to Internal Storage"
            fi
        }


    }

    # setup permissions
    [ "$setup_permissions" = true ] && {
        if	chown root:root "$MODDIR/detach.txt" && \
            chmod 0644      "$MODDIR/detach.txt"; then
            logme debug "tag-files: done setting permissions."
        else
            logme warn "tag-files: failed to set permissions"
        fi
    }

    # set force flag
    [ -f "$path_dir_storage/force" ] && {
        logme stats "tag-files: detected force tag, setting force toggle to true. This will ignore checks during detach process."
        # flag the force detach script
        toggled_forced_detach=true
        rm -rf "$path_dir_storage/force"
    }
}

# check for detach file
[ ! -f "$path_file_module_detach" ] && {
    mkdir -p "$path_dir_storage"
    printf "%s" "$(date) - missing module dir detach.txt" > "$path_dir_storage/missing_detach.txt"
    logme error "exiting.. missing detach.txt in module."
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
        logme debug "loop: skipping.. $package_name is not installed."
        continue
    }

    # check current appstate & ownership value
    get_LDB=$(sqlite3 "$LDB" "SELECT doc_id,doc_type FROM ownership" | grep "$package_name" | head -n 1 | cut -d'|' -f2)
    get_LADB=$(sqlite3 "$LADB" "SELECT package_name,auto_update FROM appstate" | grep "$package_name" | head -n 1 | cut -d'|' -f2)

    # verification of detach is need unless force flash is enabled
    if { [ $toggled_forced_detach = true ] || { [ -n "$get_LADB" ] && [ "$get_LADB" -ne "2" ]; } || { [ -n "$get_LDB" ] && [ "$get_LDB" -ne "25" ]; } }; then

        # stop playstore only once
        [ $toggled_playstore_disabled != true ] && {
            logme debug "loop: stopping Google PlayStore and setting GET_USAGE_STATS to ignore"

            # stop the playstore
            if ! am force-stop "$PS"; then
                logme error "loop: failed to stop $PS"
            fi
            # set GET_USAGE_STATS
            if ! cmd appops set --uid "$PS" "GET_USAGE_STATS" "ignore"; then
                logme error "loop: failed to set $PS GET_USAGE_STATS to ignore"
            fi

            # prevent multiple call
            toggled_playstore_disabled=true 
        }

        logme stats "loop: detaching  $package_name.."
        
        # update ownership
        if [ "$get_LDB" -ne "25" ]; then
            if ! sqlite3 "$LDB" "UPDATE ownership SET doc_type = '25' WHERE doc_id = '$package_name'"; then
                logme error "loop: failed to update database to set ownership"
            fi
        else
            logme stats "loop: no need to set ownership"
        fi

        # update appstate
        if [ "$get_LADB" -ne "2" ]; then
            if ! sqlite3 "$LADB" "UPDATE appstate SET auto_update = '2' WHERE package_name = '$package_name'";then
                logme error "loop: failed to update database to disable auto_update"
            fi
        else
            logme stats "loop: no need to set appstate"
        fi

        # generate detach list
        detached_list="$detached_list\n$package_name"
    else
        if [ -z "$LADB" ]; then
            logme debug "loop: LADB is null"
        else 
            logme debug "loop: LADB is \"$LADB\""
        fi
        
        if [ -z "$LDB" ]; then
            logme debug "loop: LDB  is null"
        else 
            logme debug "loop: LDB  is \"$LDB\""
        fi

        logme stats "loop: skipping.. $package_name already detached!"
    fi
done < "$path_file_module_detach"

# clear playstore cache
[ $toggled_playstore_disabled = true ] && {
    logme stats "clear-cache: clearing PlayStore Cache.."
    send_notification "Detached Apps: $detached_list"
    if ! rm -rf /data/data/"$PS"/cache/*; then
        logme error "clear-cache: failed to clear cache"
    fi

    # restart playstore only after a successfully detached, prevent loops
    [ ! -f "$MODDIR/detached" ] && {
        # start playstore
        # sleep 3
        
        logme debug "restart: restarting PlayStore and creating detached tag file."
        if ! touch "$MODDIR/detached"; then
            logme error "restart: failed to create tag detached tag file."
        else
            # start Google PlayStore
            if ! am start -n "$(cmd package resolve-activity --brief "$PROC" | tail -n 1)" ;then
                logme error "restart: failed to start PlayStore"
            fi
        fi
    }
}

# remove run marker
rm -f "$MODDIR/running"
logger_check