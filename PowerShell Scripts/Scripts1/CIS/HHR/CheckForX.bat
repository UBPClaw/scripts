echo off

REM ML55 Y$ is the AFTER VOLUME
REM HHR X$ is the BEFORE VOLUME



if not exist \\HHR\x$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\EmailFiles\BeforeVolumeSnapFailed.bat
goto END
:GOOD
Call E:\Scripts\Start_Services.bat
:END
