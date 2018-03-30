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
echo %today%>E:\scripts\Monthend_Create_SnapShot_Before.log
echo.>>E:\scripts\Monthend_Monthend_Create_SnapShot_Before.log


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
rem * Split From Production *
rem ************************************
echo Split From  Production Disk...
echo Split From  Production Disk>>C:\Resync_SnapShot_Before.log
echo ***********************************>>C:\Resync_SnapShot_Before.log
pairevtwait -g CIS_Before -s pair -t 32000
pairsplit -g CIS_Before
sleep 5
pairevtwait -g CIS_Before -s psus -t 32000
pairdisplay -g CIS_Before -fcx
echo.>>C:\Resync_SnapShot_Before.log
echo.>>C:\Resync_SnapShot_Before.log

rem ************************************
rem * Import Disk Group on HHR host *
rem ************************************
echo Importing Disk Group on HHR host...
echo Importing Disk Group on HHR host>>E:\scripts\Monthend_Monthend_Create_SnapShot_Before.log
echo ***********************************>>E:\scripts\Monthend_Create_SnapShot_Before.log
pairevtwait -g CIS_Before -s psus -t 32000>>E:\scripts\Monthend_Create_SnapShot_Before.log
vxassist rescan
echo.>>E:\scripts\Monthend_Create_SnapShot_Before.log
vxdg -g CIS_DG -n CIS_Before -f -C import>>E:\scripts\Monthend_Create_SnapShot_Before.log
echo.>>E:\scripts\Monthend_Create_SnapShot_Before.log
vxassist -f assign \Device\HarddiskDmVolumes\CIS_Before\Volume1 DriveLetter=X:>>E:\scripts\Monthend_Create_SnapShot_Before.log
echo.>>E:\scripts\Monthend_Create_SnapShot_Before.log


call E:\Scripts\MonthEnd\MonthEnd_Start_Services.bat