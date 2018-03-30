
# This script Updates multiple files for importing into the SQL
# SQL Proj NBU database on the SQLPROJ server.
# 1. Update Policy File - Updates a file containing nbu policy name
# 2. Update Policy Schedule - Updates the schedules for each policy
# 3. Update the StorageUnit policy - Updates the storage unit for
#    each policy.



# 1. Update Policy File

$dadate = get-date -f M-d-yyyy
ren D:\BKD_LOGS\Policies\Policies_latest.txt Policies_$dadate.txt
bppllist | Out-File D:\BKD_LOGS\Policies\Policies_latest.txt

# END POLICY FILE UPDATE




# 2. Update Policy Sechedule

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

# END UPDATE POLICY SCHEDULE




# 3. UPDATE STORAGE UNIT POLICY



# This script gets the Storage unit used by each policy for each schedule; Daily, weekly, Monthly, and even the catalog which is
# labled as FULL

Remove-Item D:\BKD_LOGS\StorageUnits\DSSU.txt
$Gpolicy = bppllist 

foreach ($Policy in $Gpolicy)

{

### DAILY ############################################
		$Pschedule = "Daily"
		$GpolSched = bpplsched $Policy  -L -label $Pschedule |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
					
									
		$GpolRes = bpplsched $policy  -L -label $Pschedule |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
				foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				
				if ($GpolSched -ne $NUL)
				{
					$GpolSched  + "," + $GpolRes | Out-File D:\BKD_LOGS\StorageUnits\DSSU.txt -append
				}	
### DAILY ############################################					
		$Pschedule = "Weekly"
		$GpolSched1 = bpplsched $Policy  -L -label $Pschedule |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
									
		
		
		
		$GpolRes1 = bpplsched $policy  -L -label $Pschedule |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
				foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				if ($GpolSched1 -ne $NUL)
				{
				$GpolSched1 + "," + $GpolRes1 | Out-File D:\BKD_LOGS\StorageUnits\DSSU.txt -append	
		        }
### FULL ############################################				
		$Pschedule = "Full"
		$GpolSched2 = bpplsched $Policy  -L -label $Pschedule |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
					
					
				
		$GpolRes2 = bpplsched $policy  -L -label $Pschedule |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
			 	foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				if ($GpolSched2 -ne $NUL)
				{
				$GpolSched2 + "," + $GpolRes2 | out-file D:\BKD_LOGS\StorageUnits\DSSU.txt -append	
		        }
#### MONTHLY #####################################################		
		$Pschedule = "Monthly"
		$GpolSched3 = bpplsched $Policy  -L -label $Pschedule |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
					
					
		
		
		$GpolRes3 = bpplsched $policy  -L -label $Pschedule |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
				foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				if ($GpolSched3 -ne $NUL)
				{
				$GpolSched3 + "," + $GpolRes3 | Out-File D:\BKD_LOGS\StorageUnits\DSSU.txt -append
				}
### MANUAL ######################################################				
		$Pschedule = "Manual"
		$GpolSched4 = bpplsched $Policy  -L -label $Pschedule |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
					
					
		
		
		$GpolRes4 = bpplsched $policy  -L -label $Pschedule |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
				foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				if ($GpolSched4 -ne $NUL)
				{
				$GpolSched4 + "," + $GpolRes4 | Out-File D:\BKD_LOGS\StorageUnits\DSSU.txt -append
				}
				

}


# END UPDATE STORAGE UNIT POLICY

