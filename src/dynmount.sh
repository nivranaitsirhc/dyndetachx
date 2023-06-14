#!/system/bin/sh
# magisk_module required
MODDIR="${0%/*}"
MODNAME="${MODDIR##*/}"

# config-paths
# ------------

# magisk busybox and module local binaries
export PATH="$MODDIR/bin:$MAGISKTMP/.magisk/busybox:$PATH"

# API_VERSION = 1
export STAGE="$1"  # prepareEnterMntNs or EnterMntNs
export PID="$2"    # PID of app process
export UID="$3"    # UID of app process
export PROC="$4"   # Process name. Example: com.google.android.gms.unstable
export USERID="$5" # USER ID of app
# API_VERSION = 2
# Enable ash standalone
# Enviroment variables: MAGISKTMP, API_VERSION
# API_VERSION = 3
# STAGE="$1"  # prepareEnterMntNs or EnterMntNs or OnSetUID


# config-static_variables 
# -----------------------


exit_script() {
    # clean up before exit
    exit "$1"
}
RUN_SCRIPT(){
    if [ "$STAGE" = "prepareEnterMntNs" ]; then
        prepareEnterMntNs
    elif [ "$STAGE" = "EnterMntNs" ]; then
        EnterMntNs
    elif [ "$STAGE" = "OnSetUID" ]; then
        OnSetUID
    fi
}
prepareEnterMntNs(){
    # this function run on app pre-initialize
	# minimum process monitor tool v3
    if [ "$API_VERSION" -lt 3 ]; then
        exit_script 1
    fi

	# catch google play, pass to EnterMntNs to lunch detach
    if [ "$PROC" = "com.android.vending" ]; then
        su 0 -mm -c sh "$MODDIR/detach.sh"
    fi
    exit_script 1 # close script
}
EnterMntNs(){
    # this function will be run when mount namespace of app process is unshared
    # call exit_script 0 to let script to be run in OnSetUID
    exit_script 1 # close script
}
OnSetUID(){
    # this function will be run when UID is changed from 0 to $UID
    exit_script 1 # close script
}

RUN_SCRIPT