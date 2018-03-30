

Remove-Item d:\bkd_logs\Schedules\DAILYBUPSCHED.txt

# The command below returns all policies. If I wanted to, I could select only those policies that are active. Some policies are not activated
# and I would rather not include those in the list but that would include the DPR policies. There are 3 DPR policies; DPR_DD1, DPR_S and DPR_T
# Both DPR_S and T are launched by the command line and do not have a schedule. So, when I am retrieving daily backups, because these two
# policies do not have a schdule, they will not show up. Therefore, I am using the DPR_DD1 policy as a place holder. It is not active but it
# has a schedule.

$Gpolicy = bppllist 

$Pschedule = "Daily"


	foreach ($policy in $Gpolicy)
		{


			$GpolSched = bpplsched $policy  -L -label $Pschedule |
			Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
					ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
					ForEach-Object {$_-replace "   Monday","$policy,$Pschedule,Monday,"} |
					ForEach-Object {$_-replace "   Tuesday","$policy,$Pschedule,Tuesday,"} |
					ForEach-Object {$_-replace "   Wednesday","$policy,$Pschedule,Wednesday,"} |
					ForEach-Object {$_-replace "   Thursday","$policy,$Pschedule,Thursday,"} |
					ForEach-Object {$_-replace "   Friday","$policy,$Pschedule,Friday,"} |
					ForEach-Object {$_-replace "   Saturday","$policy,$Pschedule,Saturday,"} |
					ForEach-Object {$_-replace "   Sunday","$policy,$Pschedule,Sunday,"} |
					foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
	
	$GpolSched.count
	
	$policy + "1"
	
	
	
$GpolSched2 = bpplsched $policy  -L -label $Pschedule |
	Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday" -and
				  $_-notmatch "Week"}|
	
	ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
	ForEach-Object {$_-replace "   Monday","$policy,Monday,"} |
	ForEach-Object {$_-replace "   Tuesday","$policy,Tuesday,"} |
	ForEach-Object {$_-replace "   Wednesday","$policy,Wednesday,"} |
	ForEach-Object {$_-replace "   Thursday","$policy,Thursday,"} |
	ForEach-Object {$_-replace "   Friday","$policy,Friday,"} |
	ForEach-Object {$_-replace "   Saturday","$policy,Saturday,"} |
	ForEach-Object {$_-replace "   Sunday","$policy,Sunday,"} |
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1]} 
	
	$policy + "2"
 
 	$GpolSched2.count
	



$i = 0
$gsked = $(while ($i -le $GpolSched.count) { $GpolSched[$i] + $GpolSched2[$i];$i++}) 


$gsked | Out-File d:\bkd_logs\Schedules\DAILYBUPSCHED.txt -append

}
# ************************************** WEEKLY ************************************************************


$Gpolicy = bppllist 

$Pschedule = "Weekly"


	foreach ($policy in $Gpolicy)
		{


			$GpolSched = bpplsched $policy  -L -label $Pschedule |
			Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
					ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
					ForEach-Object {$_-replace "   Monday","$policy,$Pschedule,Monday,"} |
					ForEach-Object {$_-replace "   Tuesday","$policy,$Pschedule,Tuesday,"} |
					ForEach-Object {$_-replace "   Wednesday","$policy,$Pschedule,Wednesday,"} |
					ForEach-Object {$_-replace "   Thursday","$policy,$Pschedule,Thursday,"} |
					ForEach-Object {$_-replace "   Friday","$policy,$Pschedule,Friday,"} |
					ForEach-Object {$_-replace "   Saturday","$policy,$Pschedule,Saturday,"} |
					ForEach-Object {$_-replace "   Sunday","$policy,$Pschedule,Sunday,"} |
					foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
	
	$GpolSched.count
	
	$policy + "1"
	
	
	
$GpolSched2 = bpplsched $policy  -L -label $Pschedule |
	Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday" -and
				  $_-notmatch "Week"}|
	
	ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
	ForEach-Object {$_-replace "   Monday","$policy,Monday,"} |
	ForEach-Object {$_-replace "   Tuesday","$policy,Tuesday,"} |
	ForEach-Object {$_-replace "   Wednesday","$policy,Wednesday,"} |
	ForEach-Object {$_-replace "   Thursday","$policy,Thursday,"} |
	ForEach-Object {$_-replace "   Friday","$policy,Friday,"} |
	ForEach-Object {$_-replace "   Saturday","$policy,Saturday,"} |
	ForEach-Object {$_-replace "   Sunday","$policy,Sunday,"} |
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1]}
	
	$policy + "2"
 
 	$GpolSched2.count
	



$i = 0
$gsked = $(while ($i -le $GpolSched.count) { $GpolSched[$i] + $GpolSched2[$i];$i++}) 


$gsked | Out-File d:\bkd_logs\Schedules\DAILYBUPSCHED.txt -append

}


 ************************************** MONTHLY ************************************************************


$Gpolicy = bppllist 

$Pschedule = "Monthly"


	foreach ($policy in $Gpolicy)
		{


			$GpolSched = bpplsched $policy  -L -label $Pschedule |
			Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
					ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
					ForEach-Object {$_-replace "   Monday","$policy,$Pschedule,Monday,"} |
					ForEach-Object {$_-replace "   Tuesday","$policy,$Pschedule,Tuesday,"} |
					ForEach-Object {$_-replace "   Wednesday","$policy,$Pschedule,Wednesday,"} |
					ForEach-Object {$_-replace "   Thursday","$policy,$Pschedule,Thursday,"} |
					ForEach-Object {$_-replace "   Friday","$policy,$Pschedule,Friday,"} |
					ForEach-Object {$_-replace "   Saturday","$policy,$Pschedule,Saturday,"} |
					ForEach-Object {$_-replace "   Sunday","$policy,$Pschedule,Sunday,"} |
					foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
	
	$GpolSched.count
	
	$policy + "1"
	
	
	
$GpolSched2 = bpplsched $policy  -L -label $Pschedule |
	Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday" -and
				  $_-notmatch "Week"}|
	
	ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
	ForEach-Object {$_-replace "   Monday","$policy,Monday,"} |
	ForEach-Object {$_-replace "   Tuesday","$policy,Tuesday,"} |
	ForEach-Object {$_-replace "   Wednesday","$policy,Wednesday,"} |
	ForEach-Object {$_-replace "   Thursday","$policy,Thursday,"} |
	ForEach-Object {$_-replace "   Friday","$policy,Friday,"} |
	ForEach-Object {$_-replace "   Saturday","$policy,Saturday,"} |
	ForEach-Object {$_-replace "   Sunday","$policy,Sunday,"} |
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1]}
	
	$policy + "2"
 
 	$GpolSched2.count
	



$i = 0
$gsked = $(while ($i -le $GpolSched.count) { $GpolSched[$i] + $GpolSched2[$i];$i++}) 


$gsked | Out-File d:\bkd_logs\Schedules\DAILYBUPSCHED.txt -append

}



