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

powershell Compress-Archive -Force .\src\* .\dyndetach_%version%.zip

:exit
endlocal