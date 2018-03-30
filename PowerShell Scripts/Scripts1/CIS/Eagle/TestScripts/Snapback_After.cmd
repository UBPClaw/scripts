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
echo %today%>C:\Resync_SnapShot_After.log
echo.>>C:\Resync_SnapShot_After.log

rem *********************
rem * Import Disk Group *
rem *********************
echo Importing Disk Group...
echo Importing Disk Group>>C:\Resync_SnapShot_After.log
echo ********************>>C:\Resync_SnapShot_After.log
vxassist rescan>>C:\Resync_SnapShot_After.log
echo.>>C:\Resync_SnapShot_After.log
vxdg -g CIS_After -f -C import>>C:\Resync_SnapShot_After.log
echo.>>C:\Resync_SnapShot_After.log
psexec \\xlr vxassist rescan>>C:\Resync_SnapShot_After.log
echo.>>C:\Resync_SnapShot_After.log
echo.>>C:\Resync_SnapShot_After.log


rem ************************************
rem * Re-join the Disk Group to CIS_DG *
rem ************************************
echo Re-joining the Disk Group to CIS_DG...
echo Re-joining the Disk Group to CIS_DG>>C:\Resync_SnapShot_After.log
echo ***********************************>>C:\Resync_SnapShot_After.log
vxdg -g CIS_After -n CIS_DG -C -f join>>C:\Resync_SnapShot_After.log
echo.>>C:\Resync_SnapShot_After.log
echo.>>C:\Resync_SnapShot_After.log


rem *********************************
rem * Snap Back the SnapShot Volume *
rem *********************************
echo Snapping Back the SnapShot Volume...
echo Snapping Back the SnapShot Volume>>C:\Resync_SnapShot_After.log
echo *********************************>>C:\Resync_SnapShot_After.log
vxassist -f -gCIS_DG snapback volume1>>C:\Resync_SnapShot_After.log


rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=administrator@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com,8586352690@alphapage.myairmail.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="CIS SnapShot Re-Sync After Operation"
set body1=C:\Resync_SnapShot_After.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q



