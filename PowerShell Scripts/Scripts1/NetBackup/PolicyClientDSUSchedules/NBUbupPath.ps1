$Today = get-date -f M/d/yyyy
$FileDate = $Today | ForEach-Object {$_-replace "\/","_"}

$header = "Policy,BupPath"
#$header | Out-File \\gremlin\d$\BKD_LOGS\BackupPaths\BUpPath_$FileDate.csv -append

$gP = bppllist

#$gPolicy = "FILER_Dakota_Backups"

foreach ($gPolicy in $gP)
{
$gPPath = bppllist $gPolicy -L |
	              Where-Object {$_ -match "INCLUDE" -and
				                $_ -notmatch "NEW_STREAM"} |
				  foreach-object {$_-replace "Include:           ","$gPolicy," } | 
				  Out-File \\gremlin\d$\BKD_LOGS\BackupPaths\BUpPath_$FileDate.txt -append
				  
}

#Import-Csv \\gremlin\d$\BKD_LOGS\BackupPaths\BUpPath_$FileDate.csv | export-csv \\gremlin\d$\BKD_LOGS\BackupPaths\BUpPathRPT_$FileDate.csv -notype
#Remove-Item \\gremlin\d$\BKD_LOGS\BackupPaths\BUpPath_$FileDate.csv