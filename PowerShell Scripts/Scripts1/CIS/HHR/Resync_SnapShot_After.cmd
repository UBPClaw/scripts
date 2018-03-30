@echo off

REM************************************************************************************************
REM                    SYNCH THE After VOLUME FROM ML55 TO EAGLE
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
echo %today%>E:\scripts\Resync_SnapShot_After.log
echo.>>E:\scripts\Resync_SnapShot_After.log

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
echo Deporting Disk Group on Remote host>>E:\scripts\Resync_SnapShot_After.log
echo ***********************************>>E:\scripts\Resync_SnapShot_After.log
psexec \\ml55 vxdg -g CIS_After -f deport>>E:\scripts\Resync_SnapShot_After.log
echo.>>E:\scripts\Resync_SnapShot_After.log
echo.>>E:\scripts\Resync_SnapShot_After.log

rem ************************************
rem * Resync with Production *
rem ************************************
echo Resyncing with Production Disk...
echo Resyncing with Production Disk>>E:\scripts\Resync_SnapShot_After.log
echo ***********************************>>E:\scripts\Resync_SnapShot_After.log
pairresync -g CIS_After -c 15>>E:\scripts\Resync_SnapShot_After.log
pairevtwait -g CIS_After -s pair -t 32000>>E:\scripts\Resync_SnapShot_After.log
echo.>>E:\scripts\Resync_SnapShot_After.log
echo.>>E:\scripts\Resync_SnapShot_After.log

rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=dataadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="CIS SnapShot Re-Sync After Operation"
set body1=E:\scripts\Resync_SnapShot_After.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q



