
$Schedule = gc \\gremlin\d$\bkd_logs\schedules\DAILYBUPSCHED.txt | Sort-Object |
	Where-Object {$_-match "Tuesday"} |
	Where-Object {$_-notmatch "000:00:00"}
	
	$tempPol = New-Object string[] 4
	
	
	foreach ($Policy in $Schedule)
			{
				for ($i =0;$i -lt 4;$i++) 
				{
	 					$tempPol[$i] = $Policy.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]							
				}
						$pout = "{0,-41} {1,-7} {2,-5} {3,-5} "-f $tempPol[0],$tempPol[1],$tempPol[2],$tempPol[3]  
						$WedOut = $WedOut  + $pout + "`n"
						 
						
					}
					$WedOut = $WedOut + "`n" + "There are" + " " + $Schedule.count + " " + "Scheduled Backups for" + " " + "Wednesday"

	$WedOut