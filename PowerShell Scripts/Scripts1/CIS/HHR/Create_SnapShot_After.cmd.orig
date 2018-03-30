@echo off
cls
rem *****************
rem * Get Date/Time *
rem *****************
set getdate=%temp%\date.txt
date /t >%getdate%
for /F "tokens=2 delims=/ " %%i in (%getdate%) do set Month=%%i
for /F "tokens=3 delims=/ " %%i in (%getdate%) do set Day=%%i
for /F "tokens=4 delims=/ " %%i in (%getdate%) do set Year=%%i
del %getdate%
set gettime=%temp%\time.txt
time /t >%gettime%
for /F "tokens=1 delims=: " %%i in (%gettime%) do set Hour=%%i
for /F "tokens=2 delims=: " %%i in (%gettime%) do set Minute=%%i
rem for /F "tokens=3 delims=: " %%i in (%gettime%) do set Second=%%i
del %gettime%
set today=%Month%-%Day%-%Year% %Hour%:%Minute%
echo %today%>C:\Create_SnapShot_After.log
echo.>>C:\Create_SnapShot_After.log


rem ********************************
rem * Create SnapShot After Volume *
rem ********************************
echo Creating SnapShot After...
echo Creating Snapshot After>>C:\Create_SnapShot_After.log
echo ***********************>>C:\Create_SnapShot_After.log
vxsnap -x CIS_After.xml create source=w:/label=CIS_After/newvol=CIS_After>>C:\Create_SnapShot_After.log
echo.>>C:\Create_SnapShot_After.log
echo.>>C:\Create_SnapShot_After.log


rem *****************************************
rem * Split SnapShot Volume into Disk Group *
rem *****************************************
echo Spliting SnapShot Volume into Disk Group...
echo Spliting SnapShot Volume into Disk Group>>C:\Create_SnapShot_After.log
echo ****************************************>>C:\Create_SnapShot_After.log
vxdg -g CIS_DG -n CIS_After -f -s split CIS_After>>C:\Create_SnapShot_After.log
echo.>>C:\Create_SnapShot_After.log
echo.>>C:\Create_SnapShot_After.log


rem ************************************
rem * Import Disk Group on Remote host *
rem ************************************
echo Importing Disk Group on Remote host...
echo Importing Disk Group on Remote host>>C:\Create_SnapShot_After.log
echo ***********************************>>C:\Create_SnapShot_After.log
vxassist rescan>>C:\Create_SnapShot_After.log
psexec \\xlr vxassist rescan>>C:\Create_SnapShot_After.log
echo.>>C:\Create_SnapShot_After.log
psexec \\xlr vxdg -g CIS_After -f -C import>>C:\Create_SnapShot_After.log

rem BTS 10-07-05 backup - psexec \\xlr vxassist -f assign \Device\HarddiskDmVolumes\CIS_After\SnapVolume01 DriveLetter=Y:>>C:\Create_SnapShot_After.log

psexec \\xlr vxassist -f assign \Device\HarddiskDmVolumes\CIS_After\Volume1 DriveLetter=Y:>>C:\Create_SnapShot_After.log
echo.>>C:\Create_SnapShot_After.log
vxassist rescan>>C:\Create_SnapShot_After.log
psexec \\xlr vxassist rescan>>C:\Create_SnapShot_After.log


rem ******************
rem * Send the email *
rem ******************
rem BTSecho Sending email...
set SendTo1=dataadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="CIS Create SnapShot After Operation"
set body1=C:\Create_SnapShot_After.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q


rem******Check for the Y drive on XLR.


call E:\Scripts\CheckForY.bat