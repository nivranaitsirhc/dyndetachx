#!/system/bin/sh
# magisk_module required
MODDIR="${0%/*}"
MODNAME="${MODDIR##*/}"

# config-paths
# ------------

# magisk Busybox
export PATH="$MAGISKTMP/.magisk/busybox:$PATH"
# module local binaries
export PATH="$MODDIR/bin:$PATH"


# API_VERSION = 1
STAGE="$1"  # prepareEnterMntNs or EnterMntNs
PID="$2"    # PID of app process
UID="$3"    # UID of app process
PROC="$4"   # Process name. Example: com.google.android.gms.unstable
USERID="$5" # USER ID of app
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

# this function run on app pre-initialize
prepareEnterMntNs(){
	# minimum process monitor tool v3
    if [ "$API_VERSION" -lt 3 ]; then
        exit_script 1
    fi

	# catch google play, pass to EnterMntNs to lunch detach
    if [ "$PROC" = "com.android.vending" ]; then
        # proceed to EnterMntNs
        exit_script 0
    fi

    exit_script 1 # close script
}

# this function will be run when mount namespace of app process is unshared
EnterMntNs(){
    # catch google play source detach script
    if [ "$PROC" = "com.android.vending" ]; then
        su -mm -c sh "$MODDIR/detach.sh"
    fi
    
    # call exit_script 0 to let script to be run in OnSetUID
    exit_script 1 # close script
}

# this function will be run when UID is changed from 0 to $UID
OnSetUID(){
    

    exit_script 1 # close script
}

RUN_SCRIPT