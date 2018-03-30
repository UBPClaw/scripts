REM This Bat file will UnFreeze the Cluster.
REm and start the UniRPCService,the UniverseTelnetService, and the UniverseResouceServce.
REM The UniverseResouceServce is automatically started by the UniverseTelnetService.

if exist \\eagle\w$ goto EAGLE
psexec \\XLR hares -online UniRPCService -sys XLR

psexec \\XLR hares -online UniverseTelnetService -sys XLR

REM echo Begin day End>\\dakota\apps\CIS\Dayend\BEGINDAYEND.TXT 

goto END

:EAGLE
psexec \\eagle hares -online UniRPCService -sys EAGLE

psexec \\eagle hares -online UniverseTelnetService -sys EAGLE

goto END

:END
call E:\Scripts\MonthEnd\Monthend_CheckForBeforeU.bat

REM This script will start the services shown above, and then call E:\Scripts\MonthEnd\LookFor_XLR_X.bat
REM See E:\Scripts\MonthEnd\LookFor_XLR_X.bat for the remaining process.

