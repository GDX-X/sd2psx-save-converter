@echo off
title sd2psx save converter By GDX

if exist "%~dp0BAT\mymcplusplus.exe" (set "mymcplusplusPath=%~dp0BAT\mymcplusplus.exe") else (set mymcplusplusPath=mymcplusplus)

setlocal EnableDelayedExpansion

echo\
echo Choose your Memory Cards
echo 1. PSxMemCard = mcd ^(sd2psx^)
echo 2. MemCard PRO = mc2
echo\
CHOICE /C 12 /M "Select Option:"

IF !ERRORLEVEL!==1 set "ext=mcd" & set FEXT=MCD
IF !ERRORLEVEL!==2 set "ext=mc2" & set FEXT=MC2

rmdir /Q/S "%~dp0BAT\TMP" >nul 2>&1
IF NOT EXIST BAT\TMP MD BAT\TMP
IF NOT EXIST !FEXT! MD !FEXT!
IF NOT EXIST PSU MD PSU

:MainMenu
cls
echo.------------------------------------------
echo.
ECHO  [=====^| Main Menu ^|=====]
echo.
ECHO  [1] Import PSU ^> !FEXT!
ECHO  [2] Export !FEXT! ^> PSU
ECHO. 
ECHO  [11] Exit
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" goto ImportPSU2MCD
if "!choice!"=="2" goto ExportMCD2PSU
if "!choice!"=="5" mymcplusplus -i "%~dp0!FEXT!\SLES-50288\SLES-50288-1.mcd" ls & pause
if "!choice!"=="6" mymcplusplus -i "%~dp0!FEXT!\SLES-50288\SLES-50288-1.mcd" check & pause
if "!choice!"=="11" exit

(goto MainMenu)

:ImportPSU2MCD
cls\
cd /d "%~dp0PSU"

echo\
echo Do you want to import savedata into a specific channel by default it will be on 1
echo If you don't know, put: NO
echo\
CHOICE /C YN /M "Select Option:"
IF !ERRORLEVEL!==1 (

for /L %%i in (1,1,8) do echo Channel - %%i
echo\
echo 9 - Cancel
echo\
CHOICE /C 123456789 /M "Select Option:"
set choice=!ERRORLEVEL!

if !choice!==9 goto MainMenu
set channel=!choice!
) else (set channel=1)

for %%f in (*.psu) do (
	
	set PSUName=%%f
	set MCName=!PSUName:~2,10!
	set Ignore=
	
	REM Ignore BEDATA-SYSTEM
	if "!PSUName!"=="BEDATA-SYSTEM.psu" set Ignore=Yes
	
	if not defined Ignore (
	echo\
	echo\
	echo MemoryCard: [!MCName!-!channel!.!ext!]
	echo SaveData:   [!PSUName!]
	
	REM Check if config files using the same serial ID exist
	if exist "%~dp0!FEXT!\!MCName!\!MCName!-!channel!.!ext!" (
	!mymcplusplusPath! -i "%~dp0!FEXT!\!MCName!\!MCName!-!channel!.!ext!" import "!PSUName!"
	) else (
	copy "%~dp0BAT\MC_VIRGIN.mcd" "%~dp0BAT\TMP" >nul 2>&1
	!mymcplusplusPath! -i "%~dp0BAT\TMP\MC_VIRGIN.mcd" import "!PSUName!"
	md "%~dp0!FEXT!\!MCName!" >nul 2>&1 & move "%~dp0BAT\TMP\MC_VIRGIN.mcd" "%~dp0!FEXT!\!MCName!\!MCName!-!channel!.!ext!" >nul 2>&1
		)
	) else (echo !PSUName!>>"%~dp0Ignored-PSU.txt")
)
echo\
echo\
pause & goto MainMenu

:ExportMCD2PSU
cls
cd /d "%~dp0!FEXT!"
for /d %%d in (*) do (
	
	set FolderMCName=%%d
	set Ignore=
	
	if "!FolderMCName!"=="BOOT" set Ignore=Yes
		
	if not defined Ignore (
	for %%f in (!FolderMCName!\*) do (
	set MCName=%%~nxf
	
	if "!FolderMCName:~0,4!"=="Card" (set fchannel=!MCName:~-0,8!) else (set fchannel=!MCName:~0,13!)
	
	md "%~dp0!FEXT!_Exported\!FolderMCName!\!fchannel!"
	!mymcplusplusPath! -i "!FolderMCName!\!MCName!" ls | "%~dp0BAT\busybox" cut -c45-999 | "%~dp0BAT\busybox" sed "1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	
	REM Export to PSU
	for /f "usebackq delims=" %%p in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	echo\
	echo\
	echo MemoryCard: [!MCName!]
	echo SaveData:   [%%p]

	!mymcplusplusPath! -i "!FolderMCName!\!MCName!" export "%%p" & move "%%p.psu" "%~dp0!FEXT!_Exported\!FolderMCName!\!fchannel!" >nul 2>&1		
			)
		)
	)
)
echo\
echo\
pause & goto MainMenu