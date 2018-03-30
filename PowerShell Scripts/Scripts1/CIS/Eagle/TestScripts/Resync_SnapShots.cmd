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
echo %today%>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log


rem *************************************
rem * Deport Disk Groups on Remote host *
rem *************************************
echo Deporting Disk Groups on Remote host...
echo Deporting Disk Groups on Remote host>>C:\Resync_SnapShots.log
echo ************************************>>C:\Resync_SnapShots.log
psexec \\xlr vxdg -g CIS_Before -f deport>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
psexec \\xlr vxdg -g CIS_After -f deport>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log


rem **********************
rem * Import Disk Groups *
rem **********************
echo Importing Disk Groups...
echo Importing Disk Groups>>C:\Resync_SnapShots.log
echo *********************>>C:\Resync_SnapShots.log
vxassist rescan>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
vxdg -g CIS_Before -f -C import>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
vxdg -g CIS_After -f -C import>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log


rem *************************************
rem * Re-join the Disk Groups to CIS_DG *
rem *************************************
echo Re-joining the Disk Groups to CIS_DG...
echo Re-joining the Disk Groups to CIS_DG>>C:\Resync_SnapShots.log
echo ************************************>>C:\Resync_SnapShots.log
vxdg -g CIS_Before -n CIS_DG -C -f join>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
vxdg -g CIS_After -n CIS_DG -C -f join>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log


rem **********************************
rem * Snap Back the SnapShot Volumes *
rem **********************************
echo Snapping Back the SnapShot Volumes...
echo Snapping Back the SnapShot Volumes>>C:\Resync_SnapShots.log
echo **********************************>>C:\Resync_SnapShots.log
vxassist -f -gCIS_DG snapback volume1>>C:\Resync_SnapShots.log
echo.>>C:\Resync_SnapShots.log
vxassist -f -gCIS_DG snapback volume2>>C:\Resync_SnapShots.log


rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=administrator@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="CIS SnapShot Re-Sync Operation"
set body1=C:\Resync_SnapShots.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q

