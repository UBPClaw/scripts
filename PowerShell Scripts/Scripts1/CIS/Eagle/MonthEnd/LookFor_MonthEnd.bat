echo off



:Notthereyet
if not exist \\dakota\apps\CIS\monthend\monthend.txt goto Notthereyet
goto itsthere
:itsthere
rem Call "E:\Scripts\MonthEnd\MonthEndTest\TestVBS.bat"
Call "E:\Scripts\MonthEnd\MonthEnd_Stop_Services.bat"
:END

REM This script will loop until the monthend.txt file is created by the Oncal CIS person. Once the file
REM exists, the MonthEnd_Stop_Services.bat file will be launched.
REM The  MonthEnd_Stop_Services.bat does the following
REM ***** hares -offline UniRPCService -sys EAGLE
REM ***** hares -offline UniverseTelnetService -sys EAGLE
REM ***** hares -offline UniverseResourceService -sys EAGLE
REM ***** pskill tl_server.exe

REM The E:\Scripts\MonthEnd\MonthEnd_Create_SnapShot_Before.cmd is then called.