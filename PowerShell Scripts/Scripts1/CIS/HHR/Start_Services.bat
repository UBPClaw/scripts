REM This Bat file will UnFreeze the Cluster.
REm and start the UniRPCService,the UniverseTelnetService, and the UniverseResouceServce.
REM The UniverseResouceServce is automatically started by the UniverseTelnetService.

if exist \\eagle\w$ goto EAGLE
psexec \\XLR hares -online UniRPCService -sys XLR

psexec \\XLR hares -online UniverseTelnetService -sys XLR

echo Begin Day End>\\dakota\apps\CIS\Dayend\BEGINDAYEND.TXT 

goto END
:EAGLE
psexec \\eagle hares -online UniRPCService -sys EAGLE

psexec \\eagle hares -online UniverseTelnetService -sys EAGLE

echo Begin Day End>\\dakota\apps\CIS\Dayend\BEGINDAYEND.TXT 

goto END

:END
call E:\Scripts\EmailFiles\Begin_Dayend_Email.bat

