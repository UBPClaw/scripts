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
echo %today%>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log


rem ************************************
rem * Deport Disk Group on Remote host *
rem ************************************
echo Deporting Disk Group on Remote host...
echo Deporting Disk Group on Remote host>>C:\MonthEnd_Resync_SnapShot_Before.log
echo ***********************************>>C:\MonthEnd_Resync_SnapShot_Before.log
psexec \\xlr vxdg -g CIS_Before -f deport>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log


rem *********************
rem * Import Disk Group *
rem *********************
echo Importing Disk Group...
echo Importing Disk Group>>C:\MonthEnd_Resync_SnapShot_Before.log
echo ********************>>C:\MonthEnd_Resync_SnapShot_Before.log
vxassist rescan>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log
vxdg -g CIS_Before -f -C import>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log
psexec \\xlr vxassist rescan>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log


rem ************************************
rem * Re-join the Disk Group to CIS_DG *
rem ************************************
echo Re-joining the Disk Group to CIS_DG...
echo Re-joining the Disk Group to CIS_DG>>C:\MonthEnd_Resync_SnapShot_Before.log
echo ***********************************>>C:\MonthEnd_Resync_SnapShot_Before.log
vxdg -g CIS_Before -n CIS_DG -C -f join>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log
echo.>>C:\MonthEnd_Resync_SnapShot_Before.log


rem *********************************
rem * Snap Back the SnapShot Volume *
rem *********************************
echo Snapping Back the SnapShot Volume...
echo Snapping Back the SnapShot Volume>>C:\MonthEnd_Resync_SnapShot_Before.log
echo *********************************>>C:\MonthEnd_Resync_SnapShot_Before.log
vxassist -f -gCIS_DG snapback volume1>>C:\MonthEnd_Resync_SnapShot_Before.log


call E:\Scripts\MonthEnd\MonthEndEmails\MonthEndVolumeSynched.bat

REM This script Synchs up the Before volume to get it ready for Month End
REM The process is scheduled to happen at 4:00 AM on a set of pre scheduled Month End Dates.
REM See the Scheduled task for details.
REM The script then calls E:\Scripts\MonthEnd\MonthEndEmails\WaitingForMonthendTextFile.bat
REM letting the CIS Programmer know that they can begin month end.
REM for futher details, see E:\Scripts\MonthEnd\MonthEndEmails\WaitingForMonthendTextFile.bat
