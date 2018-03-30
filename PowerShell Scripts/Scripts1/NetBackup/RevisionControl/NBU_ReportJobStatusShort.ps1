
# ==================================================================================================================
# Microsoft PowerShell File
# \\malibu\it\NTServers\Scripts\NetBackup\NBU_ReportJobStatusShort.ps1
# Date 10/24/2008
# Bryan K. DeBrun
# This script takes the log created in MS Powershell Script \\malibu\it\NTServers\Scripts\NetBackup\BuildLogsFromNBUconsole.ps1
# scrapes away the unwanted entries, and outputs a comma delimited file that can be imported into an access database or excel
# spread sheet. I am currently importing this data into the tbl_NbJobs table in the  MS Access 97 database NBU_Jobs.
# This database is located at \\malibu\it\backups.
# ==================================================================================================================


# The bppllist command is a NetBackup command wich returns all Net Backup policies.
# I am using psexec to launch the bppllist command remotely.
# psexec must exist on the machine running this script. This returns a list of all NBU Policies.

$gP = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist"



# Clean up. Remove the file prior to creating a new file.

Remove-Item \\gremlin\d$\BKD_LOGS\PolLogs\PolInfo.txt


# Data Retrieval
# Return the desired information for each policy retrieved with the bppllist command above
# We are digging/scaping the logfile we create with the BuildLogsFromNBUconsole.ps1 script.
# With this data, we can identify the policy, whether it is a Daily, or Weekly job, the amount of time the job ran,
# when the job started and how much data was backed up. We will do this for each policy that exists in the Net Backup World.
# Each object will be stored ina seperate vriable. Once the entire log is parsed, we will retrive each variable/object and line
# them up for output.

foreach ($gPolicy in $gP)

{

# Scrape away everything but the Policy Name and assign the output to a variable.

$gPolicyName = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]})
	$gPolicyName

# Scrape away everything but the Media server name and assign the output to a variable.
# The media server is the actual NBU server that processed tha backup. Knowing this information
# will let us know how busy each of the two media servers are; Gremlin, Nova.

$gPolicyMedS = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1]})
	$gPolicyMedS
	

# Scrape away everything but the Schedule name.
# We are looking for the Schedule name; Weekly, Daily, or Monthly. These are the only schedules
# that are assigned int he M1 NBU world.

$gPolicySched = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[2]})
	$gPolicySched
	

	
	
# Scrape away everything but the client name.
# This will tell us what server was getting backed up.
# Some policies backup multiple clients.

$gPolicyClient = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[3]})
	$gPolicyClient




# Scrape away everything but the elapsed time of the backup.
# This will tell us how long the backup took to complete.

$gPolicyElapsed = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[4]})
	$gPolicyElapsed
	
	

# Scrape away everything but the Start Date.
# This will tell us the date in which the job launched.
# This is just teh date, not the time. I.E. 10/28/2008

$gPolicyStartD = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[5]})
	$gPolicyStartD
	

	
	
# Scrape away everything but the Start Time.
# This will tell us the time in which the job launched.
# This is just the time, I.E. 05:12:23

$gPolicyStartT = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[6]})
	$gPolicyStartT
	

	
# Scrape away everything but AM or PM.
# This will tell us morning or evening.


$gPolicyStartAP = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[7]})
	$gPolicyStartAP
		

# Scrape away everything but the end Date.
# This will tell us the date in which the job launched.
# This is just teh date, not the time. I.E. 10/28/2008

$gPolicyEndD = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]})
	$gPolicyEndD
	
	

# Scrape away everything but the End Time.
# This will tell us the time in which the job launched.
# This is just the time, I.E. 05:12:23

$gPolicyEndT = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	             $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[9]})
	$gPolicyEndT
	
	
# Scrape away everything but AM or PM.
# This will tell us morning or evening.	

$gPolicyEndAP = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[10]})
	$gPolicyEndAP
	
	
# Scrape away everything but the status
# This lets us know if the job completed. 0 = complete, 1 = partialy

$gPolicyStat = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[11]})
	$gPolicyStat
	
				

# Scrape away everything but the size of the backup
# this will tell us how much data was backed up.

$gPolicySize = @(gc \\gremlin\d$\BKD_LOGS\NBUJOBS.txt | 
	Where-Object {$_ -match $gPolicy} |
	Where-Object {$_ -match "Weekly" -or
	              $_ -match "Daily" -or
				  $_ -match "Monthly"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","" } |
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[12]})
	$gPolicySize
	
		

# Line up the data.
# Gather the data extracted for each variable above and output to a text file. The output will be comma dilimeted.
	
$i = 0
$gPolicyInfo = $(while ($i -le $gPolicySched.count) 
	{$gPolicyName[$i] +  "," + 
		$gPolicyMedS[$i] + "," + 
		$gPolicySched[$i] + "," + 
		$gPolicyClient[$i] + "," + 
		$gPolicyStartD[$i] + "," + 
		$gPolicyStartT[$i] + "," + 
		$gPolicyStartAP[$i] + "," + 
		$gPolicyEndD[$i] + "," + 
		$gPolicyEndT[$i] + "," + 
		$gPolicyEndAP[$i] + "," + 
		$gPolicySize[$i] + "," + 
	$gPolicyElapsed[$i];$i++})
	
	
# Out put the comma dilimeted values the the file listed below.

$gPolicyInfo | Out-File \\gremlin\d$\BKD_LOGS\PolLogs\PolInfo.txt -append


}

	
	
	
# Final Text Scrape
# Retrieve the output from "Line up the data." 
# It is possible that there could be missing data. For example, the policy failed or was still running when the backup log was created.
# This means that the size or elapsed time would not have been created. When this happens, we will see ,, (Two or more commans). This is
# actually good. We now have something common to search and replace. We will replace ,, with 0. This will make our final output a bit
# clearer. 
# We then rewrite the final output overwriting the PolicyInfo.txt file created in "Line up the data."
	
	
$path = "\\gremlin\d$\BKD_LOGS\PolLogs\PolInfo.txt"
$gPInfo = @(gc \\gremlin\d$\BKD_LOGS\PolLogs\PolInfo.txt |
	foreach-object {$_-replace ",AM"," AM" } |
	foreach-object {$_-replace ",PM"," PM" } |
	foreach-object {$_-replace ",,,,",",0,0,0" } |
	foreach-object {$_-replace ",,,",",0,0" } |
	foreach-object {$_-replace ",,",",0,"} |
	Where-Object {$_ -notmatch ",0,0,0"}) 
	
$gPInfo | sort | get-unique |out-file  $path
$gPInfo.count


# END SCRIPT