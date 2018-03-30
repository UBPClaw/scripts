@echo off
cls
rem #################
rem # Get Date/Time 
rem #################
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
echo %today%>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log
echo.>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log


rem ####################################
rem # Deport Disk Group on Gremlin host
rem ####################################

echo %today%>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log
echo Deporting Disk Group on Remote host...
echo Deporting Disk Group on Remote host>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log
echo ###################################>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log

psexec \\Gremlin vxdg -g DPR_T_DG -f deport>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log

echo.>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log
echo.>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log


rem ###################################################################
rem # Command set for offlining LUN's from host
rem ###################################################################

rsh M45 lun offline /vol/dpr_clone_gremlin/lun0.lun

rem ###################################################################
rem # Command set for unmapping LUN's from host
rem ###################################################################

rsh M45 lun unmap /vol/dpr_clone_gremlin/lun0.lun gremlin

rem ###################################################################
rem # Command set for removing FlexClone volume in preparation
rem # for snapshot process
rem ###################################################################

rsh M45 vol offline dpr_clone_gremlin
rsh M45 vol destroy dpr_clone_gremlin -f

rem ###################################################################
rem # Command set for creating before snapshots for dpr on M45
rem # This will keep rolling snapshots for 4 copies
rem ###################################################################

rsh M45 snap delete dpr_fc dpr_gremlin.3
rsh M45 snap rename dpr_fc dpr_gremlin.2 dpr_gremlin.3
rsh M45 snap rename dpr_fc dpr_gremlin.1 dpr_gremlin.2
rsh M45 snap rename dpr_fc dpr_gremlin.0 dpr_gremlin.1
rsh M45 snap create dpr_fc dpr_gremlin.0

rem ###################################################################
rem # Command set for creating FlexClone volume
rem ###################################################################

rsh M45 vol clone create dpr_clone_gremlin -b dpr_fc dpr_gremlin.0

rem ###################################################################
rem # Command set for mapping LUN's to host
rem ###################################################################

rsh M45 lun map /vol/dpr_clone_gremlin/lun0.lun gremlin

rem ###################################################################
rem # Command set for onlining LUN's for host
rem ###################################################################

rsh M45 lun online /vol/dpr_clone_gremlin/lun0.lun

rem ####################################
rem # Import Disk Group on Gremlin host
rem ####################################

echo %today%>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log
echo Importing Disk Group on Gremlin host...
echo Importing Disk Group on Gremlin host>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log
echo ###################################>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log

psexec \\Gremlin vxassist rescan

echo.>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log

psexec \\Gremlin vxdg -g DPR_Dg -n DPR_T_DG -f -C import>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log

echo.>>E:\Scripts\DPRBackup\LOGS\Create_SnapShot_DPRBACKUP.log

psexec \\Gremlin vxassist -f assign \Device\HarddiskDmVolumes\DPR_GR_BUP\Volume1 DriveLetter=T:>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log

echo.>>E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log

rem ##################
rem # Send the email
rem ##################

echo Sending email...
set SendTo1=backupadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="DPR Create SnapShot of Gremlin T:"
set body1=E:\Scripts\DPR\LOGS\Create_SnapShot_DPRGremlin_T.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q

rem ######################################
rem # Un REM after testing 10-8-06 BTS
rem ######################################

call E:\Scripts\DPR\CheckForT.bat