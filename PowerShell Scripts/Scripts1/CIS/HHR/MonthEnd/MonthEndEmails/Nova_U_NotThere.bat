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

rem ******************
rem * Send the email *
rem ******************
echo Sending email...
set SendTo1=dataadmin@mitchell1.com,DayEndPaging@MitchellRepair.com,OPSOnCall@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="The U Drive(Before MonthENd Volume) Is not Present On Nova!"
set body1="DO NOT CONTINUE WITH MONTH END! CALL ONE OF THE SYSTEM ADMINISTRATORS!"
blat - -body %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q


REM This script will send a page to both the system administrator, and the CIS programmers
REM letting them know that the SNAP did not succeed. The page is more for the system administrator
REM letting them know that they need to fix something. Past experiences with Monthend failures
REM is contributed to issues with the EMC SAN. The System Administrator, can check the EMC
REM Monitor(Currently Lotus as of 9/22/05).