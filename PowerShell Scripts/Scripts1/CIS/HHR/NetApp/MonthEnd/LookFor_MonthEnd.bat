echo off
:Notthereyet
if not exist \\dakota\apps\CIS\monthend\monthend.txt goto Notthereyet
goto itsthere
:itsthere
Call "E:\Scripts\NetApp\MonthEnd\MonthEnd_Stop_Services.bat"
:END

REM This script will loop until the monthend.txt file is created by the Oncall CIS person. Once the file
REM exists, the MonthEnd_Stop_Services.bat file will be launched.
