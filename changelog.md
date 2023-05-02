# Dynamic Detach ~ Changelog
## v1 - (v10.00.05)
* code cleanup.
* changed tag file ``replace`` to ``merge``.
* start Google PlayStore after detaching. *(It migth cause performance issue)*
## v1 - (v10.00.04)
* fixed service.sh.
* fixed detach.txt not being sourced from internal storage.
* fixed typo in install script.
## v1 - (v10.00.03)
* fixed missing execute permission for bin
* fixed bug preventing the last entry from detach.txt from being read.
## v1 - (v10.00.02)
* reworked install prep to default create a sample detach.txt in internal storage.
* service.sh will now respect internal storage tag file.
* service.sh will copy internal storage detach.txt to module when present in internal storage and missing in module. 
* use 7z in build.cmd as oppose to powershell.
## v1 - (v10.00.01)
* added new tag file ```force```, this will force detaching of detach.txt
## v1 - (v10.00.00)
* initial release