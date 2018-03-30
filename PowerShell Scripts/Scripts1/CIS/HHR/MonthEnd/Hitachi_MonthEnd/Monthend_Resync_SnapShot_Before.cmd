@echo off

REM************************************************************************************************
REM                    SYNCH THE BEFORE VOLUME FROM HHR TO EAGLE or XLR
REM************************************************************************************************
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
echo %today%>E:\scripts\MonthEnd_Resync_SnapShot_Before.log
echo.>>E:\scripts\MonthEnd_MonthEnd_Resync_SnapShot_Before.log

rem *****************
rem * Set Variables *
rem *****************
set HORCC_MRCF=1
set HORCMINST=0
set HORCM_CONF=C:\HORCM\etc\horcm0.conf

rem *****************
rem * Start HORCM (un rem only if not set as a service)*
rem *****************
rem horcmstart 0 1

rem ************************************
rem * Deport Disk Group on CCI host *
rem ************************************
echo Deporting Disk Group on Remote host...
echo Deporting Disk Group on Remote host>>E:\scripts\MonthEnd_MonthEnd_Resync_SnapShot_Before.log
echo ***********************************>>E:\scripts\MonthEnd_MonthEnd_Resync_SnapShot_Before.log
vxdg -g CIS_Before -f deport>>E:\scripts\MonthEnd_MonthEnd_Resync_SnapShot_Before.log
echo.>>E:\scripts\MonthEnd_MonthEnd_Resync_SnapShot_Before.log
echo.>>E:\scripts\MonthEnd_MonthEnd_Resync_SnapShot_Before.log

rem ************************************
rem * Resync with Production *
rem ************************************
echo Resyncing with Production Disk...
echo Resyncing with Production Disk>>E:\scripts\MonthEnd_Resync_SnapShot_Before.log
echo ***********************************>>E:\scripts\MonthEnd_Resync_SnapShot_Before.log
pairresync -g CIS_Before -c 15>>E:\scripts\MonthEnd_Resync_SnapShot_Before.log
pairevtwait -g CIS_Before -s pair -t 32000
echo.>>E:\scripts\MonthEnd_Resync_SnapShot_Before.log
echo.>>E:\scripts\MonthEnd_Resync_SnapShot_Before.log

call E:\Scripts\MonthEnd\MonthEndEmails\MonthEndVolumeSynched.bat













