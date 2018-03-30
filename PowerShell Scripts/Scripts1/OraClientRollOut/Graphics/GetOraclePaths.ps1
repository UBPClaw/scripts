# dot source file to add registry functions         
. \\malibu\it\NTServers\Scripts\LibraryRegistry.ps1

$edpc= gc C:\Workdir\Meps\GraphicsDept\Graphicspc2.txt

foreach($entry in $edpc)
{  
$giveittome=(get-regvalue "$entry" "System\CurrentControlSet\Control\Session Manager\Environment" "Path" "EXP").svalue | foreach {$_.split(";",[StringSplitOptions]::RemoveEmptyEntries)[0]} 
$giveittome + " " + $entry
 }