
$BupDt = (get-date (get-date).AddDays(-3) -f M/d/yyyy)
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}
gc \\gremlin\d$\BKD_LOGS\NBULOGS\NBULOGS_4_24_2009.txt | Where-Object {$_.split(",")[8] -match $BupDt -and $_.split(",")[11] -ne "0"-and $_.split(",")[14] -lt "2" } | Out-File \\gremlin\D$\BKD_LOGS\NBULOGS\NBULogsToSQL.txt