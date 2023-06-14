# **Dynamic Detach Module for Magisk Android**

## Description
Dynamically Detach PlayStore App.  
Run Detach everytime Google PlayStore process start.  
An expanded approach with flexibility in mind.  
Requires Magisk Process Monitor Tool (Dynamic Mount) v2+.  

## Features
* Run checks at every google play process starts.
* Minimal script overhead delay in mind.

## Requirements
* [Magisk](https://github.com/topjohnwu/Magisk) v21
* [Magisk Process Monitor Tool](https://github.com/Magisk-Modules-Alt-Repo/magisk_proc_monitor) v2+ by HuskyDG *(Can be Installed later but required for the the module to function)*
* ARM64 (for the moment)

## How to Install
1. Download the latest release
2. Install via Magisk Manager or Third Party Module Manager
3. Look for the DynamicDetachX folder in your ``Internal Storage``.
4. Edit the ``detach.txt`` and add your application package name *(e.g. YouTube -> com.google.android.youtube)*
5. Reboot
6. Open PlayStore App. *(It immediately closes during detaching process, and restart once done.)*
7. On Android 10+ a notification will apear.

## How to Manage your detached Apps
Note: Accepted entries in the ``detach.txt`` are only package names. *(e.g. com.android.vending)*
### **Direct**
Generally you can edit the ``detach.txt`` at the module directory.  
### **Indirect (Tag Files)**
You can perform task using **``DynamicDetachX``** folder in Internal Storage. Just create it if not present.
* ``enable`` <sup>\*1</sup>
    - Enables the recognation of the tag files. 
* ``merge`` <sup>\*2 \*3</sup>
    - Merge the detach.txt entries from DynamicDetachX folder into the module. 
* ``replace`` <sup>\*2 \*3</sup>
    - Replaces the detach.txt in the module.
* ``force`` <sup>\*3</sup>
    - Force detach apps in the detach.txt instead of detaching only undetached apps.
* ``mirror``
    - Copy the detach.txt from the module in this directory every invoke time. <sup>\*1</sup>

*<sup>1</sup><sub>To reduce overhead, remove this tag file when not in use.</sub>*  
*<sup>2</sup><sub>Requires detach.txt present in the DynmountDetachX folder.</sub>*  
*<sup>3</sup><sub>This tag file will be deleted once task is done.</sub>*  

## Behaviour without Tag Files
Normal operation without using tag files in Internal Storage.
### Clean Install
* After install,  **``DynamicDetachX``** folder will be present in your sdcard.
* It will contain a sample ``detach.txt``.
* After reboot, the ``detach.txt`` will be copied to the module directory
### Clean Install with existing ``detach.txt`` in ``DynamicDetachX`` folder.
* During install, the detach.txt in internal storage will be copied to the module directory.
### Upgrade Install
* Current ``detach.txt`` in module directory is retained.

## Behaviour with Tag Files
Tag File behaviour will only be enforced after reboot for ``clean install`` or every process start of Google PlayStore if module is ``already installed``.  
Tag File behaviour will also be enforced during boot up process as long it is present and the conditions are met. Note that some tag files are removed after its execution.


## Warranty
This script is provided as-is without warranty, but reporting bugs is highly appreciated.

## Support
* [Buy Me a Coffee](https://www.buymeacoffee.com/caccabo "A caffine of excitement")
* [Paypal](https://paypal.me/caccabo "PayPal")

## Credits & Thanks
* [Magisk](https://github.com/topjohnwu/Magisk)
* [Magisk Process Monitor Tool](https://github.com/Magisk-Modules-Alt-Repo/magisk_proc_monitor)
