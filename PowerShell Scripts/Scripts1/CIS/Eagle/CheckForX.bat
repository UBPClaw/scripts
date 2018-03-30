echo off

REM XLR Y$ is the AFTER VOLUME
REM XLR X$ is the BEFORE VOLUME



if not exist \\xlr\x$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\EmailFiles\BeforeVolumeSnapFailed.bat
goto END
:GOOD
Call E:\Scripts\Start_Services.bat
:END
