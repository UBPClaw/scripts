echo off

REM After snapping from DPR02, there should be an F: drive on NOVA




if not exist \\Nova\F$\Data goto Fail
goto GOOD
:FAIL
Call E:\Scripts\DPR02\EMAIL\Nova_F_DPR02SnapFailed.bat
goto END
:GOOD
:END
