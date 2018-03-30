echo off

REM After snapping from DPR01, there should be an T: drive on Gremlin




if not exist \\Gremlin\T$\Data goto Fail
goto GOOD
:FAIL
Call E:\Scripts\DPRBackup\EMAIL\Gremlin_T_DPRSnapFailed.bat
goto END
:GOOD
:END
