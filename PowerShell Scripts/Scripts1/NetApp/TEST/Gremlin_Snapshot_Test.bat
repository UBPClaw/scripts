@echo off

REM************************************************************************************************
REM                    DEPORT THE TC_DG_Clone DISK GROUP ON GV
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

rem ************************************
rem * Deport Disk Group on GV host *
rem ************************************
echo Deporting Disk Group on Remote host...
echo Deporting Disk Group on Remote host>>E:\scripts\Resync_SnapShot_After.log
echo ***********************************>>E:\scripts\Resync_SnapShot_After.log
psexec \\GV vxdg -g TC_DG_Clone -f deport>>E:\scripts\Resync_SnapShot_After.log
echo.>>E:\scripts\Resync_SnapShot_After.log
echo.>>E:\scripts\Resync_SnapShot_After.log

###################################################################
# Command set for offlining LUN's from AFTER host

rsh M35 lun offline /vol/cis_clone_after/lun0.lun

###################################################################
# Command set for unmapping LUN's from AFTER host

rsh M35 lun unmap /vol/cis_clone_after/lun0.lun cis 0

###################################################################
# Command set for removing FlexClone volume in preparation
# for AFTER snapshot process

rsh M35 vol offline cis_clone_after
rsh M35 vol destroy cis_clone_after

###################################################################
# Command set for creating AFTER snapshots for CIS on M35
# This will keep rolling snapshots for 7 days

rsh M35 snap delete cis_fc cis_fc_after.6
rsh M35 snap rename cis_fc cis_fc_after.5 cis_fc_after.6
rsh M35 snap rename cis_fc cis_fc_after.4 cis_fc_after.5
rsh M35 snap rename cis_fc cis_fc_after.3 cis_fc_after.4
rsh M35 snap rename cis_fc cis_fc_after.2 cis_fc_after.3
rsh M35 snap rename cis_fc cis_fc_after.1 cis_fc_after.2
rsh M35 snap rename cis_fc cis_fc_after.0 cis_fc_after.1
rsh M35 snap create cis_fc cis_fc_after.0

###################################################################
# Command set for creating FlexClone volume

rsh M35 vol clone create cis_clone_after -b cis_fc cis_fc_after.0

###################################################################
# Command set for mapping LUN's to AFTER host

rsh M35 lun map /vol/cis_clone_after/lun0.lun cis 0

###################################################################
# Command set for onlining LUN's for AFTER host

rsh M35 lun online /vol/cis_clone_after/lun0.lun
