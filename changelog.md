# Dynamic Detach ~ Changelog
## v1 - (v10.00.02)
* reworked install prep to default create a sample detach.txt in sdcard.
* service.sh will now respect sdcard tag file.
* service.sh will copy sdcard detach.txt to module when present in sdcard and missing in module. 
* use 7z in build.cmd as oppose to powershell.
## v1 - (v10.00.01)
* added new tag file ```force```, this will force detaching of detach.txt
## v1 - (v10.00.00)
* initial release