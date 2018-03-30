$Today = get-date -f M/d/yyyy
$FileDate = $Today | ForEach-Object {$_-replace "\/","_"}
Import-Csv  \\gremlin\d$\BKD_LOGS\BackupPaths\BUpPathRPT_$FileDate.csv |
Where-Object {$_.Policy -eq "FILER_IT"} |
select  policy,BupPath
