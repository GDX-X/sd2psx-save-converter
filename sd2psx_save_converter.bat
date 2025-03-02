@echo off
chcp 65001 >nul 2>&1
title sd2psx save converter By GDX v1.1

if exist "%~dp0BAT\mymcplusplus.exe" (set "mymcplusplusPath=%~dp0BAT\mymcplusplus.exe") else (set mymcplusplusPath=mymcplusplus)

setlocal EnableDelayedExpansion

echo\
echo Choose your Memory Cards
echo 1. PSxMemCard = mcd ^(sd2psx^)
echo 2. MemCardPRO = mc2
echo\
CHOICE /C 12 /M "Select Option:"
IF !ERRORLEVEL!==1 set "MCM=sd2psx" & set "MCEXT=MCD"
IF !ERRORLEVEL!==2 set "MCM=MemCardPRO" & set "MCEXT=MC2"

:MCMODE
echo\
echo Choose your memory card mode
echo 1. PS1
echo 2. PS2
echo\
CHOICE /C 12 /M "Select Option:"
IF !ERRORLEVEL!==1 set "McType=PS1" & set DFormat=RAW
IF !ERRORLEVEL!==2 set "McType=PS2" & set DFormat=PSU

rmdir /Q/S "%~dp0BAT\TMP" >nul 2>&1
IF NOT EXIST BAT\TMP MD BAT\TMP
IF NOT EXIST MemoryCards\!McType! MD MemoryCards\!McType!
IF NOT EXIST MY_SAVES_PS1 MD MY_SAVES_PS1
IF NOT EXIST MY_SAVES_PS2 MD MY_SAVES_PS2

:MainMenu
cd /d "%~dp0"
cls
echo.------------------------------------------
echo.
ECHO  [=====^| Main Menu !McType! Memory Card ^|=====]
echo.
ECHO  [1] Import MY SAVES ^> !MCEXT!
ECHO.
ECHO  [2] Export Any Virtual Memory card format ^> !DFormat!
ECHO  [3] Export !MCM! ^> !DFormat!
REM ECHO  [4] Create Memory Cards groups for cross-game features
ECHO.
ECHO  [11] Exit
ECHO  [12] About
ECHO  [13] Change Memory Card: Current - [!McType!]
ECHO.
echo.------------------------------------------
set "choice=" & set /p choice=Select Option:

if "!choice!"=="1" goto ImportSaveSD2PSX

if "!choice!"=="2" goto ExportVMC
if "!choice!"=="3" goto ExportSaveSD2PSX

if "!choice!"=="TEST1" mymcplusplus -i "%~dp0MemoryCards\!McType!\SLES-50288\SLES-50288-1.!ext!" ls & pause
if "!choice!"=="TEST2" mymcplusplus -i "%~dp0MemoryCards\!McType!\SLES-50288\SLES-50288-1.!ext!" check & pause
if "!choice!"=="11" exit
if "!choice!"=="12" goto About
if "!choice!"=="13" cls & goto MCMODE

(goto MainMenu)

:About
cls
echo.--------------------------------------------------------------------------
echo.
echo This tool automates the conversion of PS1 ^& PS2 SaveData for sd2psx
echo I hope it was useful^^!
echo.
echo.--------------------------------------------------------------------------
echo\
echo\
pause & goto MainMenu

REM ######################################################################################################
:ImportSaveSD2PSX
cls\
cd /d "%~dp0MY_SAVES_!McType!"

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
set channel=-!ERRORLEVEL!
if !channel!==9 goto MainMenu
) else (set channel=-1)

if "!MCEXT!"=="MCD" (set ext=mcd) else (set ext=mc2)

if "!McType!"=="PS1" (set "extsup=mcs|psv|ps1|mcb|mcx|pda|psx") else (set "extsup=mcs|psu|psv|max|sps|xps|pws")

"%~dp0BAT\busybox" ls -p "%~dp0MY_SAVES_!McType!" 2>&1 | "%~dp0BAT\busybox" grep -iE "(\.(!extsup!)$|^^[^^\.]+$)" | "%~dp0BAT\busybox" sed "/\//d" > "%~dp0BAT\TMP\Saveslist.txt"
set /a savecount=0
for /f "usebackq delims=" %%f in ("%~dp0BAT\TMP\Saveslist.txt") do (
set /a savecount+=1
	
	setlocal DisableDelayedExpansion
	set Filename=%%~nxf
	set Gameid=
	setlocal EnableDelayedExpansion

	"%~dp0BAT\busybox" grep -o -m1 "[A-Z]\{6\}-[0-9]\{5\}" "!Filename!" | "%~dp0BAT\busybox" head -1 > "%~dp0BAT\TMP\gameid.txt" & set /p Gameid=<"%~dp0BAT\TMP\gameid.txt"
	if not defined Gameid echo "!Filename!"| "%~dp0BAT\busybox" grep -oE "[A-Z]{6}-[0-9]{5}" > "%~dp0BAT\TMP\gameid.txt" & set /p Gameid=<"%~dp0BAT\TMP\gameid.txt"
	
	if not defined Gameid (
	echo %date% - %time% - !Filename!>>"%~dp0__IGNORED-IMPORT_!McType!.txt"
	) else (
	set SaveName=!Gameid!
	set MCName=!Gameid:~2,10!
	set Ignore=
	
	if "!Gameid:~0,2!"=="BA" set Region=America
	if "!Gameid:~0,2!"=="BC" set Region=China
	if "!Gameid:~0,2!"=="BE" set Region=Europe
	if "!Gameid:~0,2!"=="BI" set Region=Japan
	if "!Gameid:~0,2!"=="BK" set Region=Korean

	for /f "tokens=1*" %%A in ( 'findstr "!Gameid:~2,4!_!Gameid:~7,3!.!Gameid:~10,7!" "%~dp0BAT\TitlesDB_!McType!_English.txt"' ) do set TitleDB=%%B
	
	echo\
	echo\
	echo !savecount! - !Filename!
	echo Title:      [!TitleDB!]
	echo MemoryCard: [!MCName!!channel!.!ext!]
	echo SaveData:   [!SaveName!]
	echo Region:     [!Region!]
	echo McType:     [!McType!]
	
	REM Check if config files exist
	if exist "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" (
	if "!McType!"=="PS2" !mymcplusplusPath! -i "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" import "!Filename!"
	) else (
	md "%~dp0MemoryCards\!McType!\!MCName!" >nul 2>&1
	copy "%~dp0BAT\MC_VIRGIN_!McType!.mcd" "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" >nul 2>&1

	if "!McType!"=="PS1" ("%~dp0BAT\ps1vmc-tool" "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" -in "!Filename!") else (!mymcplusplusPath! -i "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" import "!Filename!")
		)
	)
	endlocal
endlocal
)
echo\
echo\
pause & goto MainMenu
REM ######################################################################################################
:ExportVMC
cls
cd /d "%~dp0MY_SAVES_!McType!"

if "!McType!"=="PS1" (set extsup=*.bin *.ddf *.gme *.mc *.mcd *.mci *.mcr *.mem *.ps *.psm* *.srm *.vgs *.vm1 *.vmp *.vmc) else (set extsup=*.mcd *.mc2 *.bin *.ps2)

for %%f in (!extsup!) do (

	setlocal DisableDelayedExpansion
	set MCName=%%~nxf
	set MCFext=%%~xf
	setlocal EnableDelayedExpansion
	
	if "!McType!"=="PS1" (
	"%~dp0BAT\ps1vmc-tool" "!MCName!" -ls | "%~dp0BAT\busybox" cut -c8-19 | "%~dp0BAT\busybox" sed "1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	) else (
	!mymcplusplusPath! -i "!MCName!" ls | "%~dp0BAT\busybox" cut -c45-999 | "%~dp0BAT\busybox" sed "1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	)

	REM Export
	md "%~dp0MY_SAVES_!McType!\!MCFext!_Exported" >nul 2>&1
	for /f "usebackq delims=" %%p in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	set SaveData=%%p
	echo\
	echo\
	echo MemoryCard: [!MCName!]
	echo SaveData:   [%%p]
	
	if "!McType!"=="PS1" (
	"%~dp0BAT\ps1vmc-tool" "!MCName!" -x slot "!SaveData!" & move "!SaveData!" "%~dp0MY_SAVES_!McType!\!MCFext!_Exported" >nul 2>&1
	) else (
	!mymcplusplusPath! -i "!MCName!" export "!SaveData!" & move "!SaveData!.psu" "%~dp0MY_SAVES_!McType!\!MCFext!_Exported" >nul 2>&1
		)
	)
	
	endlocal
endlocal
)
echo\
echo\
pause & goto MainMenu
REM ######################################################################################################
:ExportSaveSD2PSX
cls
cd /d "%~dp0MemoryCards\!McType!"
for /d %%d in (*) do (
	
	set FolderMCName=%%d
	set Ignore=
	
	if "!FolderMCName!"=="BOOT" set Ignore=Yes
		
	if not defined Ignore (
	for %%f in (!FolderMCName!\*) do (
	set MCName=%%~nxf
	
	if "!FolderMCName:~0,4!"=="Card" (set fchannel=!MCName:~-0,8!) else (set fchannel=!MCName:~0,13!)
	
	md "%~dp0!MCM!_Exported\!McType!\!FolderMCName!\!fchannel!" >nul 2>&1
	if !McType!==PS1 (
	"%~dp0BAT\ps1vmc-tool" "!FolderMCName!\!MCName!" -ls | "%~dp0BAT\busybox" cut -c8-19 | "%~dp0BAT\busybox" sed "1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	) else (
	!mymcplusplusPath! -i "!FolderMCName!\!MCName!" ls | "%~dp0BAT\busybox" cut -c45-999 | "%~dp0BAT\busybox" sed "1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	)
	
	REM Export
	for /f "usebackq delims=" %%p in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	echo\
	echo\
	echo MemoryCard: [!MCName!]
	echo SaveData:   [%%p]
	if !McType!==PS1 (
	"%~dp0BAT\ps1vmc-tool" "!FolderMCName!\!MCName!" -x slot "%%p" & move "%%p" "%~dp0!MCM!_Exported\!McType!\!FolderMCName!\!fchannel!" >nul 2>&1
	) else (
	!mymcplusplusPath! -i "!FolderMCName!\!MCName!" export "%%p" & move "%%p.psu" "%~dp0!MCM!_Exported\!McType!\!FolderMCName!\!fchannel!" >nul 2>&1
	)
			)
		)
	)
)
echo\
echo\
pause & goto MainMenu

REM ############################################## PS1 ###################################################
:ExportFolderVMC
cls
cd /d "%~dp0MY_SAVES_PS1\!FEXT!"

for /d %%d in (*) do (
	
	setlocal DisableDelayedExpansion
	set FolderMCName=%%d
	setlocal EnableDelayedExpansion
	
	"%~dp0BAT\ps1vmc-tool" "%~dp0MY_SAVES_PS1\!FEXT!\!FolderMCName!\SLOT0.VMC" -ls | "%~dp0BAT\busybox" cut -c8-19 | "%~dp0BAT\busybox" sed "1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"

	REM Export to RAW
	md "%~dp0MY_SAVES_PS1\!FEXT!_Exported" >nul 2>&1
	for /f "usebackq delims=" %%p in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	set SaveData=%%p
	echo\
	echo\
	echo !FolderMCName!
	echo MemoryCard: [SLOT0.VMC]
	echo SaveData:   [!SaveData!]
	
	"%~dp0BAT\ps1vmc-tool" "%~dp0MY_SAVES_PS1\!FEXT!\!FolderMCName!\SLOT0.VMC" -x slot "!SaveData!" & move "!SaveData!" "%~dp0MY_SAVES_PS1\!FEXT!_Exported" >nul 2>&1
	)
	endlocal
endlocal
)
echo\
echo\
pause & goto MainMenu
