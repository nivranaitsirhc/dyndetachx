# **Dynamic Detach Module for Magisk Android**

## Description
Dynamically Detach Playstore App. Run Detach everytime Google Playstore process start. Requires Magisk Process Monitor Tool (Dynamic Mount) v2+.
An expanded approach using HuskyDG Process Monitor Tool.

## Features
* Run checks at every google play process starts.
* Minimal script overhead delay in mind.

## Requirements
* [Magisk](https://github.com/topjohnwu/Magisk) v21
* [Magisk Process Monitor Tool](https://github.com/Magisk-Modules-Alt-Repo/magisk_proc_monitor) v2+ by HuskyDG *(Can be Installed later but required for the the module to function)*
* ARM64 (for the moment)

## How to Install
1. Download the latest release
2. Install via Magisk Manager
3. Look for the DynamicDetachX folder in your sdcard.
4. Edit the detach.txt and add/uncomment your app package_name
5. create a file in DynamicDetachX and rename it ```update```.
6. Reboot
7. Open PlayStore *(It is normal for the app to immediately close after detaching)*
8. On Android 10+ a notification will apear.

## How to Manage your detached Apps
* Accepted entries in the ```detach.txt``` are only package names. *example:com.android.vending*
* Generally you can edit the ```detach.txt``` at the module directory
* If **DynamicDetachX** is present in your sdcard, create this tag files
    * ```enable``` *<sup>\*1</sup>*
        - Enables the recognation of the tag files. 
    * ```update``` *<sup>\*2 \*3</sup>*
        - Update the detach.txt in the module. 
    * ```replace``` *<sup>\*2 \*3</sup>*
        - Replaces the detach.txt in the module.
    * ```force``` *<sup>\*3</sup>*
        - Force detach apps without checking
    * ```mirror```
        - Mirror copy the final detach.txt from the module in this directory.

*<sup>1</sup><sub>To reduce overhead, remove this tag file when not in use.</sub>*  
*<sup>2</sup><sub>Requires detach.txt present in the DynmountDetachX folder.</sub>*  
*<sup>3</sup><sub>This tag file will be deleted once task is done.</sub>*  

## Support
This script is provided as-is without warranty, but reporting bugs is highly appreciated.

## Donate
*A simple ```thank you``` can go beyond a thousand miles.*
* [Buy Me a Coffee](https://www.buymeacoffee.com/caccabo "A caffine of excitement")
* [Paypal](https://paypal.me/caccabo "PayPal")

## Credits & Thanks
* [Magisk](https://github.com/topjohnwu/Magisk)
* [Magisk Process Monitor Tool](https://github.com/Magisk-Modules-Alt-Repo/magisk_proc_monitor)
