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

powershell Compress-Archive -Path .\src\* -DestinationPath .\dyndetachx_%version%.zip -Force -CompressionLevel Fastest 

:exit
endlocal