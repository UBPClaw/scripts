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
set SendTo1=dataadmin@mitchell1.com,DayEndPaging@MitchellRepair.com,OPSOnCall@mitchell1.com,Gail.Smolen@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set subject1="4:00 AM AFTER Volume Check"
set body1="FAIL! It is 4:00 AM and the After volume is not present on ML55. OPS should stop and or disable the After_Day_End scheduled task on Magnum and get the After volume snapped prior to 5:00 AM"
blat - -body %body1% -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %subject1% -q
