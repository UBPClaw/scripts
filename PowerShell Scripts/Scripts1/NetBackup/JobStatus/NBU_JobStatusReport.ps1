$header = "Policy,Client,BUPID,ClientType,SchedLbl,SchedType,Retention,BupDate,BupTime,TimeTaken,ExpireDate,ExpireTime,BupDateEnd,BupTimeEnd,KBS,CopyCount"| Out-File c:\WeeklyRepts.csv -append

gc c:\test\*.csv |
	Where-Object {$_-match "Weekly"} | Out-File c:\WeeklyRepts.csv -append
	
	Import-Csv c:\WeeklyRepts.csv | export-csv c:\WeeklyReports.csv -notype
	
	
	
	import-Csv  c:\WeeklyReports.csv |
	 where-Object {$_.BupDate -eq "4/2/2009" }  |
	 
	 		select Policy,SchedLbl,BupDate,KBS,TimeTaken  |  sort-object BupDate,Policy | Format-table -AutoSize
