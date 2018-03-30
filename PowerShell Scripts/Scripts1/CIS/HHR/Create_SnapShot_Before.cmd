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
echo %today%>E:\scripts\Create_SnapShot_Before.log
echo.>>E:\scripts\Create_SnapShot_Before.log



rem ************************************
rem *Deport DG from BEFORE Host
rem ************************************

psexec \\nova vxdg -g CIS_Before -f deport>>E:\scripts\Create_SnapShot_before.log

rem ************************************
rem *Deport DG from AFTER Host
rem ************************************
rem Added 8-20-09 by BTS
psexec \\gremlin vxdg -g CIS_After -f deport>>E:\scripts\Create_SnapShot_before.log


rem ###################################################################
rem # Command set for offlining LUN's from Before host
rem ###################################################################

rsh M45 lun offline /vol/cis_clone_before/lun0.lun>>E:\scripts\Create_SnapShot_before.log
sleep 5

rem ###################################################################
rem # Command set for unmapping LUN's from Before host
rem ###################################################################

rsh M45 lun unmap /vol/cis_clone_before/lun0.lun nova>>E:\scripts\Create_SnapShot_before.log
sleep 5

rem ###################################################################
rem # Command set for removing FlexClone volume in preparation
rem # for before snapshot process
rem ###################################################################

rsh M45 vol offline cis_clone_before>>E:\scripts\Create_SnapShot_before.log
rsh M45 vol destroy cis_clone_before -f>>E:\scripts\Create_SnapShot_before.log
sleep 5

rem ###################################################################
rem # Command set for creating before snapshots for cis on M45
rem # This will keep rolling snapshots for 7 days
rem ###################################################################

rsh M45 snap delete cis_fc cis_before.6>>E:\scripts\Create_SnapShot_before.log
rsh M45 snap rename cis_fc cis_before.5 cis_before.6>>E:\scripts\Create_SnapShot_before.log
rsh M45 snap rename cis_fc cis_before.4 cis_before.5>>E:\scripts\Create_SnapShot_before.log
rsh M45 snap rename cis_fc cis_before.3 cis_before.4>>E:\scripts\Create_SnapShot_before.log
rsh M45 snap rename cis_fc cis_before.2 cis_before.3>>E:\scripts\Create_SnapShot_before.log
rsh M45 snap rename cis_fc cis_before.1 cis_before.2>>E:\scripts\Create_SnapShot_before.log
rsh M45 snap rename cis_fc cis_before.0 cis_before.1>>E:\scripts\Create_SnapShot_before.log
rsh M45 snap create cis_fc cis_before.0>>E:\scripts\Create_SnapShot_before.log
sleep 5

rem ###################################################################
rem # Command set for creating FlexClone volume
rem ###################################################################

rsh M45 vol clone create cis_clone_before -b cis_fc cis_before.0>>E:\scripts\Create_SnapShot_before.log
sleep 5

rem ###################################################################
rem # Command set for mapping LUN's to before host
rem ###################################################################

rsh M45 lun map /vol/cis_clone_before/lun0.lun nova>>E:\scripts\Create_SnapShot_before.log
sleep 5

rem ###################################################################
rem # Command set for onlining LUN's for before host
rem ###################################################################

rsh M45 lun online /vol/cis_clone_before/lun0.lun>>E:\scripts\Create_SnapShot_before.log
sleep 5

rem ###################################################################
rem # Command set for rescanning disks in VEA, assigning drive letter
rem ###################################################################

echo Importing Disk Group on Remote host...
echo Importing Disk Group on Remote host>>E:\scripts\Create_SnapShot_before.log
echo ***********************************>>E:\scripts\Create_SnapShot_before.log
psexec \\nova vxassist rescan>>E:\scripts\Create_SnapShot_before.log
echo.>>E:\scripts\Create_SnapShot_before.log
psexec \\nova vxdg -g CIS_DG -n CIS_Before -f -C import>>E:\scripts\Create_SnapShot_before.log
echo.>>E:\scripts\Create_SnapShot_before.log
psexec \\nova vxassist -f assign \Device\HarddiskDmVolumes\CIS_Before\Volume1 DriveLetter=U:>>E:\scripts\Create_SnapShot_before.log
echo.>>E:\scripts\Create_SnapShot_before.log


rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=dataadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="CIS Create SnapShot before Operation"
set body1=E:\scripts\Create_SnapShot_before.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q


rem ******************
rem * Un REM before testing 10-8-06 BTS *
rem ******************
call E:\Scripts\CheckForBeforeU.bat
