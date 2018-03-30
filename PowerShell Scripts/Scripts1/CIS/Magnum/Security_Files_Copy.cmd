@echo off
rem ****************************
rem * Setup Paths and Log-File *
rem ****************************
set source1=F:\UV\Accounts\Mitchell1\CISPUB83.DVLP
set destination1=W:\UV\Accounts\Mitchell1\CISPUB83
set logfile=Security_Files_Copy


rem ***************
rem * Setup Email *
rem ***************
set SendTo1=dataadmin@mitchell1.com,CisProgrammers@mitchell1.com
set SendFrom1=%computername%.mitchellrepair.com
set SMTPServer1=smtp.mitchellrepair.com
set SubjectSuccess1="The %logfile% has finished"
set BodySuccess1="The '%~0' script has finished on %computername%."
set SubjectFail1="The %logfile% did not run"
set BodyFail1="The '%~0' script did not run on %computername%. The '%source1%' path does not exist."


rem ******************************************
rem * DO NOT modify anything below this line *
rem ******************************************
rem * Check for Utilities and Folders *
rem ***********************************
:TryAgain
if not exist %windir%\system32\robocopy.exe goto error1
if not exist %windir%\system32\blat.exe goto error2
if not exist %source1% goto TryAgain
rem if not exist %source1% goto error3
if not exist %destination1% goto error4


rem ******************
rem * Start Robocopy *
rem ******************
robocopy %source1% %destination1% SECURITY SEWK /COPY:DAT /R:2 /W:5 /NP /LOG:C:\Scripts\%logfile%.log /TEE


rem ************************
rem * Send Completed Email *
rem ************************
blat - -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %SubjectSuccess1% -body %BodySuccess1%
goto end


rem ******************
rem * Error Messages *
rem ******************
:Error1
cls
echo.
echo The file 'robocopy.exe' must be in the '%windir%\system32' folder for this script to run!
echo.
pause
goto end
:Error2
cls
echo.
echo The file 'blat.exe' must be in the '%windir%\system32' folder for this script to run!
echo.
pause
goto end
:Error3
blat - -to %SendTo1% -from %SendFrom1% -server %SMTPServer1% -mailfrom %SendFrom1% -subject %SubjectFail1% -body %BodyFail1%
goto end
:Error4
cls
echo.
echo The destination folder '%destination1%' must be be present for this script to run!
echo.
pause
goto end


:End