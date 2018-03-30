echo off

REM Gremlin U$ is the AFTER VOLUME
REM Nova U$ is the BEFORE VOLUME



if not exist \\gremlin\y$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\EmailFiles\AfterVolumeSnapFailed.bat
goto END
:GOOD
Call E:\Scripts\EmailFiles\End_Dayend.bat
:END
