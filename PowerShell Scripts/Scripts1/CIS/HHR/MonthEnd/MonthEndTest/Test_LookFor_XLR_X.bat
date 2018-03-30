
echo off



REM***This bat file is for testing purposes only.


REM XLR Y$ is the AFTER VOLUME
REM XLR X$ is the BEFORE VOLUME



if not exist \\xlr\x$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\MonthEnd\MonthEndTest\Test_XLR_X_NotThere.bat
goto END
:GOOD
Call E:\Scripts\MonthEnd\MonthEndTest\Test_XLR_x_There.bat
:END
