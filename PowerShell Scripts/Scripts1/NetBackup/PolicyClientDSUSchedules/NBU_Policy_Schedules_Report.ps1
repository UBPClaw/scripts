$tdsdate = Get-Date -Format dddd
$Sunday = Import-Csv  \\gremlin\d$\BKD_LOGS\policies\PolicySchedRpt.csv |
	 where-Object {$_.Day -eq "Sunday" -and $_.Time -ne "000:00:00" -and $_.Sched -eq "Weekly"} | 
	 		select Policy,Sched,Day,Time |  sort-object Time | Format-table -AutoSize
			
$Monday = Import-Csv  \\gremlin\d$\BKD_LOGS\policies\PolicySchedRpt.csv |
	 where-Object {$_.Day -eq "Monday" -and $_.Time -ne "000:00:00" -and $_.Sched -eq "Weekly"} | 
	 		select Policy,Sched,Day,Time |  sort-object Time | Format-table -AutoSize
			
$Tuesday = Import-Csv  \\gremlin\d$\BKD_LOGS\policies\PolicySchedRpt.csv |
	 where-Object {$_.Day -eq "Tuesday" -and $_.Time -ne "000:00:00" -and $_.Sched -eq "Weekly"} | 
	 		select Policy,Sched,Day,Time |  sort-object Time | Format-table -AutoSize	
			
$Wednesday = Import-Csv  \\gremlin\d$\BKD_LOGS\policies\PolicySchedRpt.csv |
	 where-Object {$_.Day -eq "Wednesday" -and $_.Time -ne "000:00:00" -and $_.Sched -eq "Weekly"} | 
	 		select Policy,Sched,Day,Time |  sort-object Time | Format-table -AutoSize
			
$Thursday = Import-Csv  \\gremlin\d$\BKD_LOGS\policies\PolicySchedRpt.csv |
	 where-Object {$_.Day -eq "Thursday" -and $_.Time -ne "000:00:00" -and $_.Sched -eq "Weekly"} | 
	 		select Policy,Sched,Day,Time |  sort-object Time | Format-table -AutoSize
			
$Friday = Import-Csv  \\gremlin\d$\BKD_LOGS\policies\PolicySchedRpt.csv |
	 where-Object {$_.Day -eq "Friday" -and $_.Time -ne "000:00:00" -and $_.Sched -eq "Weekly"} | 
	 		select Policy,Sched,Day,Time |  sort-object Time | Format-table -AutoSize

$Saturday = Import-Csv  \\gremlin\d$\BKD_LOGS\policies\PolicySchedRpt.csv |
	 where-Object {$_.Day -eq "Saturday" -and $_.Time -ne "000:00:00" -and $_.Sched -eq "Weekly" } | 
	 		select Policy,Sched,Day,Time |  sort-object Time | Format-table -AutoSize	 

$Sunday
$Monday
$Tuesday
$Wednesday
$Thursday
$Friday
$Saturday
