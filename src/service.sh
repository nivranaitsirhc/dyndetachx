#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

# Wait until boot is completed
until [ "$(getprop sys.boot_completed)" = 1 ];do sleep 1;done

# Magisk Variables
MODDIR="${0%/*}"
# MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin
# MIRROR="$MAGISKTMP/.magisk/mirror"

# config-static_variables 
# -----------------------
path_dir_storage="/sdcard/DynamicDetachX"

# logger library required variables
# -----------------------
[[ -v STAGE ]]  || STAGE=boot-service
[[ -v PROC ]]   || PROC=magisk
[[ -v UID ]]    || UID=$(id -g)
[[ -v PID ]]    || PID=$$

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
    if [[ -v LOGGER_MODULE ]] && [ -f "$path_dir_storage/debug" ]; then
        [ -f "$path_file_logs" ] && {
            cat "$path_file_logs" >> "$path_dir_storage/module.log"
            printf "" > "$path_file_logs"
        }
    fi
}

# BootScript Service
# - At every boot check if a detach.txt is present in the designated directory
# - Source this file and perform necessary task
internal_storage="/sdcard/DynamicDetachX"
logme debug "executing service"
# @internal storage
[ -f "$internal_storage/detach.txt" ] && {
    # detach.txt is present
    logme debug "found $internal_storage detach.txt"

    if [ -f "$MODDIR/detach.txt" ]; then
        # detach.txt is also present in module dir.
        logme debug "module detach.txt is also present"
        
        [ -f "$internal_storage/enable" ] && {
            # enable tag is present in internal storage 
            logme debug "tag-files: tag enable detected.."

            if [ -f "$internal_storage/replace" ];then 
                # replace tag is present, replacing module detach.txt
                logme debug "tag-files: replace: detected"
                if cp -rf "$internal_storage/detach.txt" "$MODDIR/detach.txt";then
                    logme stats "tag-files: replace: success!"
                else
                    logme error "tag-files: replace: failed to replace module detach.txt"
                fi
            elif [ -f "$internal_storage/merge" ];then
                # merge tag is present, merging both detach.txt
                logme debug "tag-files: merge: detected"

                if {
                    sort -u "$MODDIR/detach.txt" "$internal_storage/detach.txt" > "$MODDIR/tmp_detach.txt" &&\
                    cp -rf "$MODDIR/tmp_detach.txt" "$MODDIR/detach.txt"
                };then
                    logme stats "tag-files: merge: success!"    
                    rm -rf "$MODDIR/tmp_detach.txt"
                else
                    logme error "tag-files: merge: failed to merge detach.txt"
                fi
            fi

            [ -f "$internal_storage/mirror" ] && {
                # mirror tag is present, copy the module detach.txt to internal storage
                logme debug "tag-files: mirror: detected"
                if cp -rf "$MODDIR/detach.txt" "$internal_storage/detach.txt";then
                    logme stats "tag-files: mirror: success! copied module detach to internal storage"
                else
                    logme error "tag-files: mirror: failed to mirror detach.txt"
                fi
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
    logme stats "done setting permissions!"
}
logger_check