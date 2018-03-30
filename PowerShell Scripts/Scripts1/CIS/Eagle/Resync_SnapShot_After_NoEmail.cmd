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
echo %today%>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log


rem ************************************
rem * Deport Disk Group on Remote host *
rem ************************************
echo Deporting Disk Group on Remote host...
echo Deporting Disk Group on Remote host>>C:\Resync_SnapShot_After_NoEmail.log
echo ***********************************>>C:\Resync_SnapShot_After_NoEmail.log
psexec \\xlr vxdg -g CIS_After -f deport>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log


rem *********************
rem * Import Disk Group *
rem *********************
echo Importing Disk Group...
echo Importing Disk Group>>C:\Resync_SnapShot_After_NoEmail.log
echo ********************>>C:\Resync_SnapShot_After_NoEmail.log
vxassist rescan>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log
vxdg -g CIS_After -f -C import>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log
psexec \\xlr vxassist rescan>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log


rem ************************************
rem * Re-join the Disk Group to CIS_DG *
rem ************************************
echo Re-joining the Disk Group to CIS_DG...
echo Re-joining the Disk Group to CIS_DG>>C:\Resync_SnapShot_After_NoEmail.log
echo ***********************************>>C:\Resync_SnapShot_After_NoEmail.log
vxdg -g CIS_After -n CIS_DG -C -f join>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log
echo.>>C:\Resync_SnapShot_After_NoEmail.log


rem *********************************
rem * Snap Back the SnapShot Volume *
rem *********************************
echo Snapping Back the SnapShot Volume...
echo Snapping Back the SnapShot Volume>>C:\Resync_SnapShot_After_NoEmail.log
echo *********************************>>C:\Resync_SnapShot_After_NoEmail.log
vxassist -f -gCIS_DG snapback Volume1>>C:\Resync_SnapShot_After_NoEmail.log
