
Remove-Item "\\gremlin\d$\BKD_LOGS\BackupPaths\BUpClient.txt"
$gP = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist"

#$gPolicy = "NT_Systems_C"

foreach ($gPolicy in $gP)
{
$gPClient = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" $gPolicy -L |
	              Where-Object {$_ -match "Client/HW/OS/Pri:"} |
				  foreach-object {$_-replace "Client/HW/OS/Pri:  ","$gPolicy," } |
				  foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
				  Out-File \\gremlin\d$\BKD_LOGS\BackupPaths\BUpClient.txt -append
				 
				
				  
}