@echo off
rem ****************************
rem * Setup Paths and Log-File *
rem ****************************
set source1=w:\UV\Accounts\Mitchell1\CISPUB83
set destination1=F:\UV\accounts\Mitchell1\CISPUB83.DVLP
set logfile=Copy_to_Dev



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
robocopy %source1% %destination1% /MIR /COPY:DAT /R:2 /W:5 /NP /S /LOG:C:\Scripts\%logfile%.log /TEE
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
goto end
:Error4
cls
echo.
echo The destination folder '%destination1%' must be be present for this script to run!
echo.
pause
goto end


:End
