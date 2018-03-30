logfile = "\\dakota\apps\cis\dayend\Test.TXT"
set objFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject( "WScript.Shell" )
 
do until objFSO.FileExists(logfile)
loop

'if objFSO.FileExists(logfile) then
'WScript.Echo("All Done Dude!")
'else
'WScript.Echo("Didn't work!")
'END IF


objfso.DeleteFile(logfile)
oShell.Run "E:\Scripts\EmailFiles\TestVBS.bat", 0, True 



