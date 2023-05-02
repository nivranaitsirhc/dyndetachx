@echo off
setlocal
:: Get Version
for /f "delims== tokens=1,2" %%A in (.\src\module.prop) do (
	if  "%%A"=="version" (
		set version=%%B
	)
)

if not defined version (
	echo "failed to get version"
	goto:exit
)

set zip="C:\Program Files\7-Zip\7z.exe"

if not exist %zip% (
	echo "No Zip File"
	goto:exit
)
%zip% a -tzip -mx=9 -mm=Deflate -mcu=on -mmt=on -r .\dyndetachx_%version%.zip .\src\*

::powershell Compress-Archive -Path .\src\* -DestinationPath .\dyndetachx_%version%.zip -Force -CompressionLevel Fastest 



:exit
endlocal