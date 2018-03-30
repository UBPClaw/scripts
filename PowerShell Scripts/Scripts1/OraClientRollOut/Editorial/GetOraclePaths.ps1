# dot source file to add registry functions         
. \\malibu\it\NTServers\Scripts\LibraryRegistry.ps1


#Locate the path of where the editorial account names exist.
$edpc= gc C:\Workdir\Meps\Editorial\editpc2.txt

foreach($entry in $edpc)
{  
$giveittome=(get-regvalue "$entry" "System\CurrentControlSet\Control\Session Manager\Environment" "Path" "EXP").svalue | foreach {$_.split(";",[StringSplitOptions]::RemoveEmptyEntries)[0]} 
$giveittome + " " + $entry
 }