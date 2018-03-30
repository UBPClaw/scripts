
Remove-Item \\gremlin\d$\BKD_LOGS\JobStatus\WIP\Kbsonly.csv
Remove-Item \\gremlin\d$\BKD_LOGS\JobStatus\WIP\WeeklyTotals.txt
Remove-Item \\gremlin\d$\BKD_LOGS\JobStatus\WIP\WeeklyDailyTotals.txt

$Gfile = Get-ChildItem -Name \\gremlin\d$\BKD_LOGS\JobStatus\BUPTotals

foreach ($File in $Gfile)
	{
	
	
	
	
		$Gsum = Import-Csv \\gremlin\d$\BKD_LOGS\JobStatus\BUPTotals\$File | where {$_.KBS -ne "" -and $_.SchedLbl } |
		#-eq "Weekly" } |
		measure-object kbs -sum  |
		
		 
			
		 Select-Object @{name="Total Size(MB)";Expression={"{0:N0}" -f ($_.sum)}}
		
		#$Gsum = "{0:N0}" -f $Gsum
		
		
		foreach ($date in $Gsum)
		
			{
				$2 = $File + $date |
				 foreach-object {$_-replace "BUPREPORTS_","" } | 
				 foreach-object {$_-replace ".csv@\{Total Size\(MB\)="," " } |
				 foreach-object {$_-replace "\}","" } |
				 foreach-object {$_-replace "_","/" }  
				
				 
				 	$2 | out-file \\gremlin\d$\BKD_LOGS\JobStatus\WIP\WeeklyDailyTotals.txt -append
					
					
				}
					
			
						
					 
						 
			  }
			  
			  
	 $3 = gc \\gremlin\d$\BKD_LOGS\JobStatus\WIP\WeeklyDailyTotals.txt
	 $Heaser = "kbs" | Out-File \\gremlin\d$\BKD_LOGS\JobStatus\WIP\Kbsonly.csv -append
					 
					 foreach ($Entry in $3)
					 
					 	{
					 
					 			
								$Entry.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1] | 
								foreach-object {$_-replace ",","" } | Out-File \\gremlin\d$\BKD_LOGS\JobStatus\WIP\Kbsonly.csv -append
						  
			
						  
						  
						  
						  }
						  
						  
						  
						  
						  
$GKBS = Import-Csv \\gremlin\d$\BKD_LOGS\JobStatus\WIP\Kbsonly.csv | measure-object kbs -sum  |
		Select-Object @{name="Weekly Total Size(KB)";Expression={"{0:N0}" -f ($_.sum)}} |
		Out-File \\gremlin\d$\BKD_LOGS\JobStatus\WIP\WeeklyTotals.txt -append
		
		
		

GC \\gremlin\d$\BKD_LOGS\JobStatus\WIP\WeeklyDailyTotals.txt
Gc \\gremlin\d$\BKD_LOGS\JobStatus\WIP\WeeklyTotals.txt
		
		
		
		
		
		
	
	
		
		
		