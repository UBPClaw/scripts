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
echo %today%>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log


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


rem *   Begin Re Sync of DPR BUP *

rem ************************************
rem * Deport Disk Group on CCI host *
rem ************************************
echo %today%>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo Deporting Disk Group on Remote host...
echo Deporting Disk Group on Remote host>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo ***********************************>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
psexec \\Nova vxdg -g DPRBUP_DG -f deport>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log

rem ************************************
rem * Resync with Production *
rem ************************************
echo %today%>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo Resyncing with Production Disk...
echo Resyncing with Production Disk>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo ***********************************>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo %today%>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
pairresync -g DPR_Backup -c 15>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
pairevtwait -g DPR_Backup -s pair -t 32000>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
sleep 30

rem *  Begin creating a DPRBUP Snapshot

rem ************************************
rem * Split From DPR Production *
rem ************************************
echo %today%>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo Split From DPR Production Disk...
echo Split From DPR Production Disk>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo ***********************************>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
pairevtwait -g DPR_Backup -s pair -t 32000
pairsplit -g DPR_Backup
sleep 5
pairevtwait -g DPR_Backup -s psus -t 32000
pairdisplay -g DPR_Backup -fcx
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log

rem ************************************
rem * Import Disk Group on HHR host *
rem ************************************
echo %today%>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo Importing Disk Group on HHR host...
echo Importing Disk Group on HHR host>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo ***********************************>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
pairevtwait -g DPR_Backup -s psus -t 32000>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
psexec \\nova vxassist rescan
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
psexec \\nova vxdg -g DPR_Dg -n DPRBUP_DG -f -C import>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
psexec \\nova vxassist -f assign \Device\HarddiskDmVolumes\DPR_Backup\Volume1 DriveLetter=S:>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log


rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=backupadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="DPR Create SnapShot of Production Disk"
set body1=E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q


rem ******************
rem * Un REM after testing 10-8-06 BTS *
rem ******************
call E:\Scripts\DPRBackup\CheckForS.bat