set objFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject( "WScript.Shell" )
logfile = "\\DAKOTA\APPS\CIS\DAYEND\BEGINBACKUP.TXT"

'The syntaxt between do and loop waits for a file before calling the mirror snap 
'bat file. The file will be provided by the CIS process, which is controlled by
'the CIS programmers
 
do until objFSO.FileExists(logfile)
loop


'Delete the file enddayend.txt to reset this script for the next day.

objFSO.DeleteFile(logfile)


'This command will be used to call the bat file which snaps the Mirror(After)
'We will replace the c:\ThisWorked.bat with the correct snap bat file.

'WScript.Echo("All Done Dude!")


oShell.Run "E:\Scripts\stop_services.bat", 0, True 



