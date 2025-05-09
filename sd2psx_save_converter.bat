@echo off
chcp 65001 >nul 2>&1
title sd2psx save converter By GDX v1.4

rmdir /Q/S "%~dp0BAT\TMP" >nul 2>&1
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
IF NOT EXIST MemoryCards\!McType! MD MemoryCards\!McType!
IF NOT EXIST MY_SAVES_PS1 MD MY_SAVES_PS1
IF NOT EXIST MY_SAVES_PS2 MD MY_SAVES_PS2

:MainMenu
cd /d "%~dp0"
rmdir /Q/S "%~dp0BAT\TMP" >nul 2>&1
IF NOT EXIST BAT\TMP MD BAT\TMP
cls
echo.------------------------------------------
echo.
ECHO  [=====^| Main Menu !McType! Memory Card ^|=====]
echo.
ECHO  [1] Import MY SAVES ^> !MCEXT!
ECHO.
ECHO  [2] Export Any Virtual Memory card format ^> !DFormat!
ECHO  [3] Export !MCM! ^> !DFormat!
ECHO  [4] Create Memory Cards groups for cross-game features
if !McType!==PS2 ECHO  [5] Import config network
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
if "!choice!"=="4" goto MakeCardsgroups
if !McType!==PS2 if "!choice!"=="5" goto ImportNetworkConfig

if "!choice!"=="11" exit
if "!choice!"=="12" goto About
if "!choice!"=="13" cls & goto MCMODE

if "!choice!"=="TEST1" mymcplusplus -i "%~dp0MemoryCards\!McType!\SLES-50288\SLES-50288-1.mcd" ls & pause
if "!choice!"=="TEST2" mymcplusplus -i "%~dp0MemoryCards\!McType!\SLES-51967\SLES-51967-1.mcd" ls & pause
if "!choice!"=="TEST3" mymcplusplus -i "%~dp0MemoryCards\!McType!\SLES-50288\SLES-50288-1.mcd" check & pause

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

if "!McType!"=="PS1" (set MCSizeDefault=1MB) else (set MCSizeDefault=8MB)
set MCSize=!MCSizeDefault!

"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\MemoryCards.zip" -o"%~dp0BAT\TMP" "MC_!McType!_!MCSize!.mcd" -r -y >nul 2>&1

if "!McType!"=="PS1" (set "extsup=mcs|psv|ps1|mcb|mcx|pda|psx") else (set "extsup=mcs|psu|psv|max|sps|xps|pws|cbs")
"%~dp0BAT\busybox" ls -p "%~dp0MY_SAVES_!McType!" 2>&1 | "%~dp0BAT\busybox" grep -iE "(\.(!extsup!)$|^^[^^\.]+$)" | "%~dp0BAT\busybox" sed "/\//d" > "%~dp0BAT\TMP\Saveslist.txt"

set /a savecount=0
for /f "usebackq delims=" %%f in ("%~dp0BAT\TMP\Saveslist.txt") do (
set /a savecount+=1
	
	setlocal DisableDelayedExpansion
	set Filename=%%~nxf
	set Gameid=
	setlocal EnableDelayedExpansion

	"%~dp0BAT\busybox" grep -om1 "[A-Z]\{6\}-[0-9]\{5\}" "!Filename!" | "%~dp0BAT\busybox" head -1 > "%~dp0BAT\TMP\gameid.txt" & set /p Gameid=<"%~dp0BAT\TMP\gameid.txt"
	if not defined Gameid (
	"%~dp0BAT\psv-converter-win" "!Filename!" | "%~dp0BAT\busybox" grep "PSV resigned successfully" | "%~dp0BAT\busybox" sed "s/.*: //" > "%~dp0BAT\TMP\PSV.txt" & set /p PSVName=<"%~dp0BAT\TMP\PSV.txt"
		if errorlevel 1 (
		echo\
		echo\
		echo !Filename! - Error, this save data cannot be imported^^!
		) else (
		"%~dp0BAT\busybox" grep -om1 "[A-Z]\{6\}-[0-9]\{5\}" "!PSVName!" > "%~dp0BAT\TMP\gameid.txt" & set /p Gameid=<"%~dp0BAT\TMP\gameid.txt" & del "!PSVName!" >nul 2>&1
			)
		)

	if defined Gameid (
	set SaveName=!Gameid!
	set MCName=!Gameid:~2,10!

	REM Get Game title
	for /f "tokens=1*" %%A in ( 'findstr "!Gameid:~2,4!_!Gameid:~7,3!.!Gameid:~10,7!" "%~dp0BAT\TitlesDB_!McType!_English.txt"' ) do set TitleDB=%%B
	
	REM Checking Nertwork compatible game
	if "!McType!"=="PS2" for /f "tokens=1*" %%A in ( 'findstr "!Gameid:~2,4!_!Gameid:~7,3!.!Gameid:~10,7!" "%~dp0BAT\TitlesDB_!McType!_Online.txt"' ) do set NETCNF=Yes
	
	REM Set region
	if "!Gameid:~0,2!"=="BA" (set Region=America) ^
	else if "!Gameid:~0,2!"=="BC" (set Region=China) ^
	else if "!Gameid:~0,2!"=="BE" (set Region=Europe) ^
	else if "!Gameid:~0,2!"=="BI" (set Region=Japan) ^
	else if "!Gameid:~0,2!"=="BK" (set Region=Korea)
	
	echo\
	echo\
	echo !savecount! - !Filename!
	echo Title:      [!TitleDB!]
	echo MemoryCard: [!MCName!!channel!.!ext!]
	echo SaveData:   [!SaveName!]
	echo Region:     [!Region!]
	echo McType:     [!McType!]
	REM echo MCSize:       [!MCSize!]
	REM echo NetConf:    [!NETCNF!]

	REM Check if config saves files exist
	if exist "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" (
		if "!McType!"=="PS1" ("%~dp0BAT\ps1vmc-tool" "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" -in "!Filename!") else ("!mymcplusplusPath!" -i "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" import "!Filename!")
	) else (
	md "%~dp0MemoryCards\!McType!\!MCName!" >nul 2>&1
		copy "%~dp0BAT\TMP\MC_!McType!_!MCSize!.mcd" "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" >nul 2>&1
			if "!McType!"=="PS1" ("%~dp0BAT\ps1vmc-tool" "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" -in "!Filename!") else ("!mymcplusplusPath!" -i "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" import "!Filename!")
	)
	
	REM Import network configuration if the game is compatible with PS2 Online
	if !NETCNF!==Yes (
		if exist "BWNETCNF.psu" (
			"!mymcplusplusPath!" -i "%~dp0MemoryCards\!McType!\!MCName!\!MCName!!channel!.!ext!" import "BWNETCNF.psu"
			)
		)
		
	) else (
	if /I not "!Filename:~0,-4!"=="BWNETCNF" (
		echo %date% - %time% - !Filename!>>"%~dp0__IGNORED-IMPORT_!McType!.txt"
		)
	)
	endlocal
endlocal
)

echo\
echo\
pause & goto MainMenu
REM ######################################################################################################
:ImportNetworkConfig
cls
cd /d "%~dp0MY_SAVES_!McType!"

if exist "%~dp0MY_SAVES_!McType!\BWNETCNF.psu" (
echo\
echo Do you want to import the network configuration into the memory card of PS2 Online compatible games^?
echo If you don't know, put: NO
echo\
CHOICE /C YN /M "Select Option:"
IF !ERRORLEVEL!==1 (set NETCNF_USER=Yes) else (goto MainMenu)

if "!MCEXT!"=="MCD" (set ext=mcd) else (set ext=mc2)
cls
echo Checking Saves Data PS2 Online compatibility...
"%~dp0BAT\busybox" ls -p "%~dp0MemoryCards\!McType!" 2>&1 | "%~dp0BAT\busybox" grep -oE "[A-Z]{4}-[0-9]{5}" > "%~dp0BAT\TMP\MClist.txt"

for /f "usebackq delims=" %%f in ("%~dp0BAT\TMP\MClist.txt") do (

	setlocal DisableDelayedExpansion
	set Gameid=%%f
	set Groups=
	setlocal EnableDelayedExpansion

	REM Get only compatible Memory Cards
	"%~dp0BAT\busybox" grep -o "!Gameid:~0,4!_!Gameid:~5,3!.!Gameid:~8,8!" "%~dp0BAT\TitlesDB_PS2_Online.txt" >nul 2>&1
	
	if !errorlevel!==1 (
	REM echo not found
	) else (
	
	REM Get groups
	for /f "usebackq tokens=1,2 delims==" %%a in ("%~dp0BAT\Game2Folder.ini") do if /i "%%a"=="!Gameid!" set "Groups=%%b"
	
	REM Get Title
	for /f "tokens=1*" %%A in ( 'findstr "!Gameid:~0,4!_!Gameid:~5,3!.!Gameid:~8,8!" "%~dp0BAT\TitlesDB_!McType!_English.txt"' ) do set TitleDB=%%B
	
	REM If Memory Cards Groups exist set gameid to groups
	if exist "%~dp0MemoryCards\!McType!\!Groups!\!Groups!-1.!ext!" set Gameid=!Groups!
	
	echo\
	echo\
	echo !TitleDB!
	echo !Gameid!
	
	"!mymcplusplusPath!" -i "%~dp0MemoryCards\!McType!\!Gameid!\!Gameid!-1.!ext!" import "BWNETCNF.psu"
	)
	endlocal
endlocal
	)
) else (echo\ & echo\ & echo BWNETCNF.psu not found^^! & echo\ & echo Please put BWNETCNF.psu in MY_SAVES_!McType!)

echo\
echo\
pause & goto MainMenu
REM ######################################################################################################
:ExportVMC
cls
cd /d "%~dp0BAT\TMP"

if "!McType!"=="PS1" (
echo\
echo Do you want to export multiple save files located in subfolder^?
echo Useful for POPS, for example: POPS\MyGame\SLOT0.VMC
echo\
CHOICE /C YN /M "Select Option:"
IF !ERRORLEVEL!==1 cls & goto ExportFolderVMC
)

if "!McType!"=="PS1" (
set extsup=\.bin$^|\.ddf$^|\.gme$^|\.mc$^|\.mcd$^|\.mci$^|\.mcr$^|\.mem$^|\.ps$^|\.psm.$^|\.srm$^|\.vgs$^|\.vm1$^|\.vmp$^|\.vmc$
) else (
set extsup=\.mcd$^|\.mc2$^|\.bin$^|\.ps2$
)

dir /a /b "%~dp0MY_SAVES_!McType!" 2>&1 | "%~dp0BAT\busybox" grep -iE "!extsup!" > "%~dp0BAT\TMP\FilesList.txt
for /f "usebackq delims=" %%f in ("%~dp0BAT\TMP\FilesList.txt") do (

	setlocal DisableDelayedExpansion
	set MCName=%%~nxf
	set MCFext=%%~xf
	setlocal EnableDelayedExpansion

	if "!McType!"=="PS1" (
	"%~dp0BAT\ps1vmc-tool" "%~dp0MY_SAVES_!McType!\!MCName!" -ls | "%~dp0BAT\busybox" sed "s/[[:space:]]//g; 1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	) else (
	"!mymcplusplusPath!" -i "%~dp0MY_SAVES_!McType!\!MCName!" ls | "%~dp0BAT\busybox" cut -c45-999 | "%~dp0BAT\busybox" sed "s/^/0|/g; 1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	)
	
	md "%~dp0MY_SAVES_!McType!\!MCFext!_Exported" >nul 2>&1
	for /f "usebackq tokens=1,2 delims=|" %%a in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	
	setlocal DisableDelayedExpansion
	set SaveData=%%b
	set Slots=%%a
	setlocal EnableDelayedExpansion
	
	echo\
	echo\
	echo MemoryCard: [!MCName!]
	echo SaveData:   [!SaveData!]
	if !McType!==PS1 echo Slots:      [!Slots!]
	
	if "!McType!"=="PS1" (
	"%~dp0BAT\ps1vmc-tool" "%~dp0MY_SAVES_!McType!\!MCName!" -x "!Slots!" "%~dp0MY_SAVES_!McType!\!MCFext!_Exported\!SaveData!"
	) else (
	"!mymcplusplusPath!" -i "%~dp0MY_SAVES_!McType!\!MCName!" export "!SaveData!" & move "!SaveData!.psu" "%~dp0MY_SAVES_!McType!\!MCFext!_Exported" >nul 2>&1
		)
		endlocal
	endlocal
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
	"%~dp0BAT\ps1vmc-tool" "!FolderMCName!\!MCName!" -ls | "%~dp0BAT\busybox" sed "s/[[:space:]]//g; 1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	) else (
	"!mymcplusplusPath!" -i "!FolderMCName!\!MCName!" ls | "%~dp0BAT\busybox" cut -c45-999 | "%~dp0BAT\busybox" sed "s/^/0|/g; 1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	)

	for /f "usebackq tokens=1,2 delims=|" %%a in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	
	setlocal DisableDelayedExpansion
	set SaveData=%%b
	set Slots=%%a
	setlocal EnableDelayedExpansion
	
	echo\
	echo\
	echo MemoryCard: [!MCName!]
	echo SaveData:   [!SaveData!]
	if !McType!==PS1 echo Slots:      [!Slots!]
	
	if !McType!==PS1 (
	"%~dp0BAT\ps1vmc-tool" "!FolderMCName!\!MCName!" -x !Slots! "%~dp0!MCM!_Exported\!McType!\!FolderMCName!\!fchannel!\!SaveData!"
	) else (
	"!mymcplusplusPath!" -i "!FolderMCName!\!MCName!" export "!SaveData!" & move "!SaveData!.psu" "%~dp0!MCM!_Exported\!McType!\!FolderMCName!\!fchannel!" >nul 2>&1
	)
				endlocal
			endlocal
			)
		)
	)
)
echo\
echo\
pause & goto MainMenu
:MakeCardsgroups
cls
cd /d "%~dp0BAT\TMP"

echo\
echo When the saved data is copied into the Memory Card groups, do you want to keep the original Memory Cards^?
echo\
CHOICE /C YN /M "Select Option:"
IF !ERRORLEVEL!==1 (set KeepMC=Yes) else (set KeepMC=)

if "!MCEXT!"=="MCD" (set ext=mcd) else (set ext=mc2)
copy "%~dp0BAT\Game2Folder.ini" "%~dp0" >nul 2>&1

if "!McType!"=="PS1" (set MCSizeDefault=1MB) else (set MCSizeDefault=8MB)

cls
echo Checking Saves Data compatibility...
"%~dp0BAT\busybox" ls -p "%~dp0MemoryCards\!McType!" 2>&1 | "%~dp0BAT\busybox" grep -oE "[A-Z]{4}-[0-9]{5}" | "%~dp0BAT\busybox" sed "/MCCG/d" > "%~dp0BAT\TMP\MClist.txt"

for /f "usebackq delims=" %%f in ("%~dp0BAT\TMP\MClist.txt") do (

	setlocal DisableDelayedExpansion
	set FMCName=%%f
	set MCName=%%f
	set Gameid=%%f
	set Groups=
	set McSize=
	setlocal EnableDelayedExpansion
	
	REM Get only compatible Memory Cards
	"%~dp0BAT\busybox" grep -o "!FMCName!" "%~dp0BAT\Game2Folder.ini" >nul 2>&1
	
	if !errorlevel!==1 (
	REM echo not found
	) else (
	
	REM Get groups
	for /f "usebackq tokens=1,2 delims==" %%a in ("%~dp0BAT\Game2Folder.ini") do if /i "%%a"=="!FMCName!" set "Groups=%%b"
	
	REM Get Title
	for /f "tokens=1*" %%A in ( 'findstr "!Gameid:~0,4!_!Gameid:~5,3!.!Gameid:~8,8!" "%~dp0BAT\TitlesDB_!McType!_English.txt"' ) do set TitleDB=%%B
	
	if "!McType!"=="PS1" (
	"%~dp0BAT\ps1vmc-tool" "%~dp0MemoryCards\!McType!\!FMCName!\!MCName!-1.!ext!" -ls | "%~dp0BAT\busybox" sed "s/[[:space:]]//g; 1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	) else (
	"!mymcplusplusPath!" -i "%~dp0MemoryCards\!McType!\!FMCName!\!MCName!-1.!ext!" ls | "%~dp0BAT\busybox" cut -c45-999 | "%~dp0BAT\busybox" sed "s/^/0|/g; 1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"
	)

	for /f "usebackq tokens=1,2 delims=|" %%a in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	
	setlocal DisableDelayedExpansion
	set SaveData=%%b
	set Slots=%%a
	setlocal EnableDelayedExpansion
	
	if "!McType!"=="PS1" (set savext=) else (set savext=.psu)
	
	REM Get Region
	if "!SaveData:~0,2!"=="BA" (set Region=America) ^
	else if "!SaveData:~0,2!"=="BC" (set Region=China) ^
	else if "!SaveData:~0,2!"=="BE" (set Region=Europe) ^
	else if "!SaveData:~0,2!"=="BI" (set Region=Japan) ^
	else if "!SaveData:~0,2!"=="BK" (set Region=Korea)
	
	if "!Groups!"=="MCCG-10024" set "MCSize=32MB"
	if "!Groups!"=="MCCG-10040" set "MCSize=32MB"
	if not defined MCSize set McSize=!MCSizeDefault!
	
	echo\
	echo\
	echo Title:      [!TitleDB!]
	echo MemoryCard: [!MCName!-1.!ext!]
	echo SaveData:   [!SaveData!]
	if !McType!==PS1 echo Slots:      [!Slots!]
	echo Groups:     [!Groups!]
	echo Region:     [!Region!]
	echo Model:      [!McType!]
	REM echo MCSize:     [!MCSize!]

	md "%~dp0MemoryCards\!McType!\!Groups!" >nul 2>&1
		if not exist "%~dp0MemoryCards\!McType!\!Groups!\!Groups!-1.!ext!" (
		"%~dp0BAT\7-Zip\7z" e -bso0 "%~dp0BAT\MemoryCards.zip" -o"%~dp0BAT\TMP" "MC_!McType!_!MCSize!.mcd" -r -y >nul 2>&1
		move "%~dp0BAT\TMP\MC_!McType!_!MCSize!.mcd" "%~dp0MemoryCards\!McType!\!Groups!\!Groups!-1.!ext!" >nul 2>&1
		)

	if "!McType!"=="PS1" (
	"%~dp0BAT\ps1vmc-tool" "%~dp0MemoryCards\!McType!\!FMCName!\!MCName!-1.!ext!" -x !Slots! "%~dp0BAT\TMP\!SaveData!" >nul 2>&1
	"%~dp0BAT\ps1vmc-tool" "%~dp0MemoryCards\!McType!\!Groups!\!Groups!-1.!ext!" -in "!SaveData!"
	) else (
	"!mymcplusplusPath!" -i "%~dp0MemoryCards\!McType!\!FMCName!\!MCName!-1.!ext!" export "!SaveData!" >nul 2>&1
	"!mymcplusplusPath!" -i "%~dp0MemoryCards\!McType!\!Groups!\!Groups!-1.!ext!" import "!SaveData!.psu"
	)

	del "%~dp0BAT\TMP\!SaveData!!savext!" >nul 2>&1
	if not defined KeepMC rmdir /Q/S "%~dp0MemoryCards\!McType!\!MCName!" >nul 2>&1
			endlocal
		endlocal
		)
	)

	endlocal
endlocal
)

echo\
echo\
pause & goto MainMenu
REM ############################################## PS1 ###################################################
:ExportFolderVMC
cls
cd /d "%~dp0MY_SAVES_!McType!"

echo\
echo\
echo ------------------------------------------
dir /b /ad "%~dp0MY_SAVES_!McType!" 2>&1 | "%~dp0BAT\busybox" sed "/_Exported/d"
echo ------------------------------------------
echo\
echo Enter the name of the folder where the subfolders containing your save data are located, inside MY_SAVES_!McType!
echo Example: POPS
set /p "MainFolder="
IF "!MainFolder!"=="" (goto MainMenu)

echo\
echo Enter the name of your savedata
echo example for POPS: SLOT0.VMC
set /p "FileName="
IF "!FileName!"=="" (goto MainMenu)

for /d %%d in (!MainFolder!\*) do (
	
	setlocal DisableDelayedExpansion
	set FolderMCName=%%~nxd
	setlocal EnableDelayedExpansion
	
	"%~dp0BAT\ps1vmc-tool" "%~dp0MY_SAVES_!McType!\!MainFolder!\!FolderMCName!\!FileName!" -ls | "%~dp0BAT\busybox" sed "s/[[:space:]]//g; 1,2d" > "%~dp0BAT\TMP\MC-Directory.txt"

	REM Export to RAW
	md "%~dp0MY_SAVES_PS1\!MainFolder!_Exported" >nul 2>&1
	for /f "usebackq tokens=1,2 delims=|" %%a in ("%~dp0BAT\TMP\MC-Directory.txt") do (
	
	setlocal DisableDelayedExpansion
	set SaveData=%%b
	set Slots=%%a
	setlocal EnableDelayedExpansion
	echo\
	echo\
	echo !FolderMCName!
	echo MemoryCard: [!FileName!]
	echo SaveData:   [!SaveData!]
	
	"%~dp0BAT\ps1vmc-tool" "%~dp0MY_SAVES_!McType!\!MainFolder!\!FolderMCName!\!FileName!" -x !Slots! "%~dp0MY_SAVES_!McType!\!MainFolder!_Exported\!SaveData!"
			
			endlocal
		endlocal
		)
	endlocal
endlocal
)
echo\
echo\
pause & goto MainMenu
