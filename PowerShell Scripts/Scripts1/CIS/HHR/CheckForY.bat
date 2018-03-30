echo off

REM ML55 Y$ is the AFTER VOLUME
REM HHR X$ is the BEFORE VOLUME



if not exist \\ML55\y$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\EmailFiles\AfterVolumeSnapFailed.bat
goto END
:GOOD
Call E:\Scripts\EmailFiles\End_Dayend.bat
:END
