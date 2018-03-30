echo off

REM After snapping from DPR01, there should be an S: drive on NOVA




if not exist \\Nova\S$\Data goto Fail
goto GOOD
:FAIL
Call E:\Scripts\DPR\EMAIL\Nova_S_DPRSnapFailed.bat
goto END
:GOOD
:END
