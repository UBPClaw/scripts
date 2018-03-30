echo off

REM XLR Y$ is the AFTER VOLUME
REM XLR X$ is the BEFORE VOLUME



if not exist \\xlr\x$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\MonthEnd\MonthEndEmails\XLR_X_NotThere.bat
goto END
:GOOD
Call E:\Scripts\MonthEnd\MonthEndEmails\XLR_x_There.bat
:END

REM This script makes sure that the BEFORE volume was successfully Snapped, and imported
REM by the Standby Server. It does this by looking for the X: drive on the Standby server.
REM If the snap was not successful, the script will call E:\Scripts\MonthEnd\MonthEndEmails\XLR_X_NotThere.bat
REM If the snap was successful, the script will call E:\Scripts\MonthEnd\MonthEndEmails\XLR_x_There.bat
REM To see the fail process, go to E:\Scripts\MonthEnd\MonthEndEmails\XLR_X_NotThere.bat
REM To see the success process, go to E:\Scripts\MonthEnd\MonthEndEmails\XLR_x_There.bat
