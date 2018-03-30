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
echo %today%>E:\scripts\Create_SnapShot_After.log
echo.>>E:\scripts\Create_SnapShot_After.log



rem ************************************
rem *Deport DG from AFTER Host
rem ************************************

psexec \\gremlin vxdg -g CIS_After -f deport

rem ###################################################################
rem # Command set for offlining LUN's from AFTER host
rem ###################################################################

rsh M45 lun offline /vol/cis_clone_after/lun0.lun

rem ###################################################################
rem # Command set for unmapping LUN's from AFTER host
rem ###################################################################

rsh M45 lun unmap /vol/cis_clone_after/lun0.lun gremlin

rem ###################################################################
rem # Command set for removing FlexClone volume in preparation
rem # for AFTER snapshot process
rem ###################################################################

rsh M45 vol offline cis_clone_after
rsh M45 vol destroy cis_clone_after -f

rem ###################################################################
rem # Command set for creating AFTER snapshots for cis on M45
rem # This will keep rolling snapshots for 7 days
rem ###################################################################

rsh M45 snap delete cis_fc cis_after.6
rsh M45 snap rename cis_fc cis_after.5 cis_after.6
rsh M45 snap rename cis_fc cis_after.4 cis_after.5
rsh M45 snap rename cis_fc cis_after.3 cis_after.4
rsh M45 snap rename cis_fc cis_after.2 cis_after.3
rsh M45 snap rename cis_fc cis_after.1 cis_after.2
rsh M45 snap rename cis_fc cis_after.0 cis_after.1
rsh M45 snap create cis_fc cis_after.0

rem ###################################################################
rem # Command set for creating FlexClone volume
rem ###################################################################

rsh M45 vol clone create cis_clone_after -b cis_fc cis_after.0

rem ###################################################################
rem # Command set for mapping LUN's to AFTER host
rem ###################################################################

rsh M45 lun map /vol/cis_clone_after/lun0.lun gremlin

rem ###################################################################
rem # Command set for onlining LUN's for AFTER host
rem ###################################################################

rsh M45 lun online /vol/cis_clone_after/lun0.lun

rem ###################################################################
rem # Command set for rescanning disks in VEA, assigning drive letter
rem ###################################################################


rem ************************************
rem * Import Disk Group on ML55 host *
rem ************************************
echo Importing Disk Group on Remote host...
echo Importing Disk Group on Remote host>>E:\scripts\Create_SnapShot_After.log
echo ***********************************>>E:\scripts\Create_SnapShot_After.log
psexec \\gremlin vxassist rescan>>E:\scripts\Create_SnapShot_After.log
echo.>>E:\scripts\Create_SnapShot_After.log
psexec \\gremlin vxdg -g CIS_DG -n CIS_After -f -C import>>E:\scripts\Create_SnapShot_After.log
echo.>>E:\scripts\Create_SnapShot_After.log
psexec \\gremlin vxassist -f assign \Device\HarddiskDmVolumes\CIS_After\Volume1 DriveLetter=U:>>E:\scripts\Create_SnapShot_After.log
echo.>>E:\scripts\Create_SnapShot_After.log


rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=dataadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="CIS Create SnapShot After Operation"
set body1=E:\scripts\Create_SnapShot_After.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q


rem ******************
rem * Un REM after testing 10-8-06 BTS *
rem ******************
call E:\Scripts\CheckForAfterU.bat
