echo off

REM Gremlin U$ is the AFTER VOLUME
REM Nova U$ is the BEFORE VOLUME

if not exist \\nova\u$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\MonthEnd\MonthEndEmails\Nova_U_NotThere.bat
goto END
:GOOD
Call E:\Scripts\MonthEnd\MonthEndEmails\Nova_U_There.bat
:END
