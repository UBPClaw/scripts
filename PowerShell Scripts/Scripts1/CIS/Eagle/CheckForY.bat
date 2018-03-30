echo off

REM XLR Y$ is the AFTER VOLUME
REM XLR X$ is the BEFORE VOLUME



if not exist \\xlr\y$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\EmailFiles\AfterVolumeSnapFailed.bat
goto END
:GOOD
Call E:\Scripts\EmailFiles\End_Dayend.bat
:END
