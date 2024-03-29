# Dynamic Detach ~ Changelog
## v1.1.4 
- 44fd866 [configs]       
    - reflect beta channel in module name (nivranaitsirhc)    
## v1.1.3 
- fc27ff7 [core]          
    - fix broken notificaiton (nivranaitsirhc)  
- a25ca4e [core]          
    - add safety checks to prevent PS loop (nivranaitsirhc)    
## v1.1.2 
- ce26173 [core]          
    - remove old logs (nivranaitsirhc)    
## v1.1.1 
- a86e2bf [core]          
    - refactor detach verification (nivranaitsirhc)  
- 33a74eb [core]          
    - disable detach skipping on failed ownership query (nivranaitsirhc)    
## v1.1.0 
- 06ed955 [core]          
    - refactor everything! :) (nivranaitsirhc)    
## v1.0.12_beta 
- 6da914f [fix]           
    - add com.android.vening:background to checks for older devices (nivranaitsirhc)    
## v1.0.11_beta 
- d62f39c [fix]           
    - fix bug caused by improper whitespace when updating db (nivranaitsirhc)    
## v1.0.10_beta 
- 0cd3edc [fix]           
    - fix bug caused by problematic PATH manipulation (nivranaitsirhc)    
## v1.0.9_beta 
- d9c9cb5 [core]          
    - refactor detach.sh to indicate that an app is already detached (nivranaitsirhc)  
- bf79cf7 [configs]       
    - fix module.prop support link (nivranaitsirhc)  
- 97f67dc [core]          
    - enable logger_check (nivranaitsirhc)  
- 44ad4a8 [core]          
    - temporary fix to invalid update.json caused by build.sh (nivranaitsirhc)  
- 5a44ea4 [core]          
    - fix detach.sh multiple typo causing mayhem (nivranaitsirhc)  
- 7738a45 [core]          
    - refactor dynmount.sh to fix unknown error causing detach.sh from not executing (nivranaitsirhc)  
- 30b1b02 [builder]       
    - refactor update.json generation changelog.md link not applying properly (nivranaitsirhc)  
- 87b7d8d [core]          
    - enabled debugging to detach.sh (nivranaitsirhc)  
- b008b00 [builder]       
    - fix update_beta.json generation still pointing to main (nivranaitsirhc)  
- a9d3792 [docs]          
    - update readme.md (nivranaitsirhc)    
## v1.0.7_beta 
- e94e07d [core]          
    - fix typo causing failure in copying the old detach.txt (nivranaitsirhc)  
- af9900a [builder]       
    - fix typo in release channel generation causing trims to not function (nivranaitsirhc)    
## v1.0.6 
- 0e501d4 [core]          
    - add logging lib (nivranaitsirhc)  
- cfaf6c2 [core]          
    - improve installation logics (nivranaitsirhc)  
- 2548519 [core]          
    - refactor detach.sh (nivranaitsirhc)  
- be7a7d5 [core]          
    - refactor dynmount.sh (nivranaitsirhc)  
- 9d2b0b8 [core]          
    - refactor bootscript service.sh (nivranaitsirhc)  
- 79b6716 [repository]    
    - refactor repository to match dynmount (nivranaitsirhc)  
- fcd9203 [repository]    
    - remove build.cmd (nivranaitsirhc)  
- 9b13abd [repository]    
    - move config related files to config folder (nivranaitsirhc)    
## v1.0.5 
- ea2cfe1 prevent         
    - loop from restarting playstore (nivranaitsirhc)  
- f701893 bump            
    - to v1.0.5 (nivranaitsirhc)  
- c9b10b0 updated         
    - readme to reflect change from tag file replace -> merge (nivranaitsirhc)  
- 8794d87 start           
    - playstore after detaching, cleanup script (nivranaitsirhc)  
- 3b8be97 change          
    - tag file replace -> merge (nivranaitsirhc)    
## v1.0.4 
- d29fc06 bump            
    - to v1.0.4 (nivranaitsirhc)  
- 5e6c437 wait            
    - for sdcard to be mounted (nivranaitsirhc)  
- 08bdfb8 refactor        
    - code and improve logic (nivranaitsirhc)  
- 766ee3d fix             
    - typos (nivranaitsirhc)    
## v1.0.3 
- 3dd0ea6 bump            
    - v1.0.3 (nivranaitsirhc)  
- 08478a4 fixed           
    - bug when detach.txt has no newline ending due to read limitation (nivranaitsirhc)  
- eb77114 added           
    - missing persmission for $MODDIR/bin (nivranaitsirhc)  
- 95fb89e bump            
    - v1.0.2 (nivranaitsirhc)  
- 6907853 removed         
    - default behavior of creating sdcard folder, respect sdcard tag file, copy sdcard detach.txt when module detach.txt is missing (nivranaitsirhc)  
- f3dc8f6 rework          
    - logic (nivranaitsirhc)  
- 16f5833 added           
    - default.txt sample to sdcard (nivranaitsirhc)  
- 73b5967 revert          
    - to Deflate from LZMA compression (nivranaitsirhc)  
- 99712ec bump            
    - to v1.0.1 (nivranaitsirhc)  
- fce88e6 added           
    - logic for new force tag file (nivranaitsirhc)  
- d72cec0 update          
    - build.cmd (nivranaitsirhc)  
- 0109396 update          
    - customize.sh (nivranaitsirhc)  
- 9d76de2 added           
    - missing META-INF (nivranaitsirhc)  
- eb5b6ee removed         
    - x in changelog.md (nivranaitsirhc)    
## v1.0.0
- Initial Release
