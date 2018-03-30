
 Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.txt
 Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.txt
 Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicySched.csv
 Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicySchedRpt.csv
 Remove-Item  \\gremlin\d$\BKD_LOGS\Policies\PolicyScheds.txt
 
  
$tdsdate = Get-Date -Format dddd
$header = "Policy,Sched,Day,Time"
$header | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicySched.csv
 
 $PolList = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist"
 
 
 
foreach ($policy in $PolList)
 	{
 		$ActivePol = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" $policy -L |
 			where-object {$_-match "Active:" } |
			ForEach-Object {$_-replace "Active:            yes","Active"} |
			ForEach-Object {$_-replace "Active:            no","NotActive" }
			                           
			
			$policy + "," + $ActivePol | where-object {$_-notmatch "CATALOG" -and $_-notmatch "Vault_" -and $_-notmatch "NotActive"}| 
				foreach-object {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]}| Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.txt -append
			
			}
	
	$AlActivePols = gc \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.txt
	
	$Pschedule = "Weekly"
	
	
	foreach ($Pol in $AlActivePols)
		{


			$GPolSched = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $Pol -L -label $Pschedule |
			Where-Object {$_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
					#ForEach-Object {$_-replace "Schedule:          Weekly",$Pschedule}  |
					ForEach-Object {$_-replace "   Monday","$Pol,$Pschedule,Monday"} |
					ForEach-Object {$_-replace "   Tuesday","$Pol,$Pschedule,Tuesday"} |
					ForEach-Object {$_-replace "   Wednesday","$Pol,$Pschedule,Wednesday"} |
					ForEach-Object {$_-replace "   Thursday","$Pol,$Pschedule,Thursday"} |
					ForEach-Object {$_-replace "   Friday","$Pol,$Pschedule,Friday"} |
					ForEach-Object {$_-replace "   Saturday","$Pol,$Pschedule,Saturday"} |
					ForEach-Object {$_-replace "   Sunday","$Pol,$Pschedule,Sunday"} |
					foreach-object {$_ -replace " {1,}",","} | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyScheds.txt -append
					
							
					
					}
					
					
	$AlActivePols = gc \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.txt
	
	$Pschedule = "Daily"
	
	
	foreach ($Pol in $AlActivePols)
		{


			$GPolSched = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $Pol -L -label $Pschedule |
			Where-Object {$_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
					#ForEach-Object {$_-replace "Schedule:          Daily",$Pschedule}  |
					ForEach-Object {$_-replace "   Monday","$Pol,$Pschedule,Monday"} |
					ForEach-Object {$_-replace "   Tuesday","$Pol,$Pschedule,Tuesday"} |
					ForEach-Object {$_-replace "   Wednesday","$Pol,$Pschedule,Wednesday"} |
					ForEach-Object {$_-replace "   Thursday","$Pol,$Pschedule,Thursday"} |
					ForEach-Object {$_-replace "   Friday","$Pol,$Pschedule,Friday"} |
					ForEach-Object {$_-replace "   Saturday","$Pol,$Pschedule,Saturday"} |
					ForEach-Object {$_-replace "   Sunday","$Pol,$Pschedule,Sunday"} |
					foreach-object {$_ -replace " {1,}",","} | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyScheds.txt -append
					
							
					
					}
					
					
					
					
	$AlActivePols = gc \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.txt
	
	$Pschedule = "Monthly"
	
	
	foreach ($Pol in $AlActivePols)
		{


			$GPolSched = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $Pol -L -label $Pschedule |
			Where-Object {$_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
					#ForEach-Object {$_-replace "Schedule:          Daily",$Pschedule}  |
					ForEach-Object {$_-replace "   Monday","$Pol,$Pschedule,Monday"} |
					ForEach-Object {$_-replace "   Tuesday","$Pol,$Pschedule,Tuesday"} |
					ForEach-Object {$_-replace "   Wednesday","$Pol,$Pschedule,Wednesday"} |
					ForEach-Object {$_-replace "   Thursday","$Pol,$Pschedule,Thursday"} |
					ForEach-Object {$_-replace "   Friday","$Pol,$Pschedule,Friday"} |
					ForEach-Object {$_-replace "   Saturday","$Pol,$Pschedule,Saturday"} |
					ForEach-Object {$_-replace "   Sunday","$Pol,$Pschedule,Sunday"} |
					foreach-object {$_ -replace " {1,}",","} | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyScheds.txt -append
					
							
					
					}
	
	$GPolicyScheds = gc \\gremlin\d$\BKD_LOGS\Policies\PolicyScheds.txt
	
	foreach ($schedule in $GPolicyScheds)
	
		{
	
	                $Day = $schedule.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
					$Sched = $schedule.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
					$1Time = $schedule.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
					$2Time = $schedule.split(",",[StringSplitOptions]::RemoveEmptyEntries)[3]
										
					$Day + "," + $Sched + "," + $1Time + "," + $2Time | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicySched.csv -append
					
					}
					
					
					
	
	
	
					
					Import-Csv \\gremlin\d$\BKD_LOGS\Policies\PolicySched.csv | export-csv \\gremlin\d$\BKD_LOGS\Policies\PolicySchedRpt.csv -notype
					
					
					
					#Import-Csv  \\gremlin\d$\BKD_LOGS\Policies\PolicySchedRpt.csv |
	# where-Object {$_.Day -eq $tdsdate -and $_.Time -ne "000:00:00"} | select Vault,Day,Time |  sort-object Time | format-table
			
			
	
