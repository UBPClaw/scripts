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
echo %today%>E:\Scripts\dpr02\LOGS\Create_SnapShot_dpr02BACKUP.log
echo.>>E:\Scripts\dpr02\LOGS\Create_SnapShot_dpr02BACKUP.log

rem ###################################################################
rem # Command set for offlining LUN's from host
rem ###################################################################

rsh M45 lun offline /vol/dpr02_clone_nova/lun0.lun

rem ###################################################################
rem # Command set for unmapping LUN's from host
rem ###################################################################

rsh M45 lun unmap /vol/dpr02_clone_nova/lun0.lun nova
sleep 5
rem ###################################################################
rem # Command set for removing FlexClone volume in preparation
rem # for snapshot process
rem ###################################################################

rsh M45 vol offline dpr02_clone_nova
rsh M45 vol destroy dpr02_clone_nova -f
sleep 5
rem ###################################################################
rem # Command set for creating before snapshots for dpr02 on M45
rem # This will keep rolling snapshots for 4 copies
rem ###################################################################

rsh M45 snap delete dpr02_fc dpr02_nova.6
rsh M45 snap rename dpr02_fc dpr02_nova.5 dpr02_nova.6
rsh M45 snap rename dpr02_fc dpr02_nova.4 dpr02_nova.5
rsh M45 snap rename dpr02_fc dpr02_nova.3 dpr02_nova.4
rsh M45 snap rename dpr02_fc dpr02_nova.2 dpr02_nova.3
rsh M45 snap rename dpr02_fc dpr02_nova.1 dpr02_nova.2
rsh M45 snap rename dpr02_fc dpr02_nova.0 dpr02_nova.1
rsh M45 snap create dpr02_fc dpr02_nova.0

sleep 5
rem ###################################################################
rem # Command set for creating FlexClone volume
rem ###################################################################

rsh M45 vol clone create dpr02_clone_nova -b dpr02_fc dpr02_nova.0
sleep 5
rem ###################################################################
rem # Command set for mapping LUN's to before host
rem ###################################################################

rsh M45 lun map /vol/dpr02_clone_nova/lun0.lun nova
sleep 5
rem ###################################################################
rem # Command set for onlining LUN's for host
rem ###################################################################

rsh M45 lun online /vol/dpr02_clone_nova/lun0.lun
sleep 5
rem ####################################
rem # Import Disk on Nova host
rem ####################################

echo %today%>>E:\Scripts\dpr02\LOGS\Create_SnapShot_dpr02BACKUP.log
echo Importing Disk on Nova host...
echo Importing Disk on Nova host>>E:\Scripts\dpr02\LOGS\Create_SnapShot_dpr02BACKUP.log
echo ###################################>>E:\Scripts\dpr02\LOGS\Create_SnapShot_dpr02BACKUP.log
psexec \\nova vxassist rescan
echo.>>E:\Scripts\dpr02\LOGS\Create_SnapShot_dpr02BACKUP.log


rem ##################
rem # Send the email 
rem ##################

echo Sending email...
set SendTo1=backupadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="dpr02 Create SnapShot of Production Disk F: on Nova"
set body1=E:\Scripts\dpr02\LOGS\Create_SnapShot_dpr02BACKUP.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q

rem ######################################
rem # Un REM after testing 10-8-06 BTS 
rem ######################################

call E:\Scripts\dpr02\CheckForF.bat