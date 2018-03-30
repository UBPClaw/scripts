echo off

REM Gremlin U$ is the AFTER VOLUME
REM Nova U$ is the BEFORE VOLUME

if not exist \\nova\u$\UV goto Fail
goto GOOD
:FAIL
Call E:\Scripts\NetApp\MonthEnd\MonthEndEmails\AfterMonthEndVolumeSnapFailed.bat
goto END
:GOOD
Call E:\Scripts\Netapp\Monthend\MonthEnd_Start_Services.bat
:END
