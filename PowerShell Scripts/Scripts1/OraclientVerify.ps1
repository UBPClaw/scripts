# This script will return the System Path of each machine in a text file
# If the path doesn't begin with P:\OracleClient\10.2.0\rt1\bin, then the client needs to be applied
# Replace the path of the machine list with the desired path.



# dot source file to add registry functions         
. \\malibu\it\NTServers\Scripts\LibraryRegistry.ps1

$edpc= gc \\malibu\it\Oracle\InstallLogs\oranetinstall.txt

foreach($entry in $edpc)
{  
$giveittome=(get-regvalue "$entry" "System\CurrentControlSet\Control\Session Manager\Environment" "Path" "EXP").svalue | foreach {$_.split(";",[StringSplitOptions]::RemoveEmptyEntries)[0]} 
$giveittome + " " + $entry
 }
