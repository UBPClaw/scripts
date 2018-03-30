set objFSO = CreateObject("Scripting.FileSystemObject")
Set oShell = CreateObject( "WScript.Shell" )
logfile = "\\DAKOTA\APPS\CIS\monthend\monthend.txt"

'The syntaxt between do and loop waits for a file before calling the mirror snap 
'bat file. The file will be provided by the CIS process, which is controlled by
'the CIS programmers
 
do until objFSO.FileExists(logfile)
loop


'Delete the file enddayend.txt to reset this script for the next day.

objFSO.DeleteFile(logfile)


'To Test, Uncomment out the below line, and comment in the actual working line.

oShell.Run "E:\Scripts\EmailFiles\TestVBS.bat", 0, True

'This is what's happening This vbs script will be scheduled to run each monthend date.
'When the CIS programmer creates the file \\dakota\apps\CIS\MonthEnd\monthend.txt 
'the script will call the E:\Scripts\MonthEnd\Monthend_stopServices.bat
'The \\dakota\apps\CIS\MonthEnd\monthend.txt will then be deleted, and the script will exit.
'See E:\Scripts\MonthEnd\MonthEnd_Stop_Services.bat to see the remaining process.

'oShell.Run "E:\Scripts\MonthEnd\MonthEnd_Stop_Services.bat", 0, True 






