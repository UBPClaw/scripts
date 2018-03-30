$GWeeklyPol = gc \\gremlin\d$\BKD_LOGS\Policies\WeeklyPols.txt
$StartDate = "1/14/2009"
$EndDate = "1/16/2009"

foreach ($WeeklyPol in $GWeeklyPol)
	{
		$BupID = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -policy $WeeklyPol -d $StartDate -e $EndDate -sl Weekly -L -idonly | 
			Where-Object {$_-notmatch "CINC"} |	
			foreach {$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[5]}
			
				if ($BupID -eq $NULL)
				{
					}
					else
						{
			
							psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BupID -L |
								Where-Object {$_-match "ID:" } |
								Where-Object {$_-notmatch "Backup ID:" } |
								Where-Object {$_-notmatch "Request Pid:" } |
								Where-Object {$_-notmatch "Job ID" } |
								Where-Object {$_-notmatch "Data_Classification_ID:" } |
								Where-Object {$_-notmatch "\\" } |
								ForEach-Object {$_-replace " ID:               ",""} | Sort-Object -Unique |
			
								Out-File \\gremlin\d$\BKD_LOGS\Policies\ImageCount\$WeeklyPol.txt -Append
								}
		
	}


# To get a simple summary of an image, use the bpimagelist -backupid "id" -U  Replace the "id" with the actuall backupid i.e. gremlin_1232068060
