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
echo %today%>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log


rem ***************************
rem * Create SnapShot Volumes *
rem ***************************
echo Creating SnapShots...
echo Creating Snapshots>>C:\Create_SnapShots.log
echo ******************>>C:\Create_SnapShots.log
vxsnap -x CIS_Before.xml create source=w:/label=CIS_Before/newvol=CIS_Before>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log
vxsnap -x CIS_After.xml create source=w:/label=CIS_After/newvol=CIS_After>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log


rem *******************************************
rem * Split SnapShot Volumes into Disk Groups *
rem *******************************************
echo Spliting SnapShot Volumes into Disk Groups...
echo Spliting SnapShot Volumes into Disk Groups>>C:\Create_SnapShots.log
echo ******************************************>>C:\Create_SnapShots.log
vxdg -g CIS_DG -n CIS_Before -f -s split CIS_Before>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log
vxdg -g CIS_DG -n CIS_After -f -s split CIS_After>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log


rem *************************************
rem * Import Disk Groups on Remote host *
rem *************************************
echo Importing Disk Groups on Remote host...
echo Importing Disk Groups on Remote host>>C:\Create_SnapShots.log
echo ************************************>>C:\Create_SnapShots.log
psexec \\xlr vxassist rescan >>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log
psexec \\xlr vxdg -g CIS_Before -f -C import>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log
psexec \\xlr vxdg -g CIS_After -f -C import>>C:\Create_SnapShots.log
echo.>>C:\Create_SnapShots.log


rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=dataadmin@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="CIS Create SnapShot Operation"
set body1=C:\Create_SnapShots.log
blat %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q
