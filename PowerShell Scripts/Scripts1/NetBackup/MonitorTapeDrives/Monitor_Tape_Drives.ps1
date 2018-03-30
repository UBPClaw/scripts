# ==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: Monitor_Tape_Drives.ps1
#
# Location: \\malibu\it\NTServers\Scripts\NetBackup\MonitorTapeDrives
#
# DATE: 9/30/2011
#
# Author: Bryan DeBrun
#
# COMMENT: This script runs the netbackup command vmoprcmd which reports the status of tape drives 
#==============================================================================================

# Remove obsolete text files

Remove-Item d:\temp\drivestatus\drivestatus.txt
Remove-Item d:\temp\drivestatus\drivestatusII.txt
Remove-Item d:\temp\drivestatus\drivestatusIII.txt
Remove-Item d:\temp\drivestatus\drivestatusIV.txt

# Assign a variable to the host
$BupHost = "gremlin"
$document = "See document <\\malibu\it\Docs\NetBackup\How to troubleshoot down NetBackup drives.txt>"

# Execute the NetBackup command to check Tap Drive Status and out put the results to a text file
vmoprcmd -dp -h $BupHost |  where-object {$_ -match "UP" -or $_-match "Down"} | Out-File d:\temp\drivestatus\drivestatus.txt


# Get the content of the text file created above, scrape away unwanted text and output the results to a text file
 Get-Content d:\temp\drivestatus\drivestatus.txt |	
	ForEach-Object {$_ -replace ",","*"} |
	ForEach-Object {$_ -replace "  0",""} |
	ForEach-Object {$_ -replace "  1",""} |
	ForEach-Object {$_ -replace "  2",""} |
	ForEach-Object {$_ -replace "  3",""} |
	ForEach-Object {$_ -replace "  4",""} |
	ForEach-Object {$_ -replace "  5",""} |
	ForEach-Object {$_ -replace "-","NA"} |
	foreach-object {$_ -replace " {1,}",","}|

	Out-File d:\temp\drivestatus\drivestatusII.txt


# Get the content of the text file created above and remove the beginning comma, the trailing comma
# and out put each to a text file."
$RemoveMe = Get-Content d:\temp\drivestatus\drivestatusII.txt

	foreach ($deal in $RemoveMe)
		{
			$deal.TrimStart(",")| Out-File d:\temp\drivestatus\drivestatusIII.txt -Append  
				
		}
	
$RemoveMeII = Get-Content d:\temp\drivestatus\drivestatusIII.txt

	foreach ($dealII in $RemoveMeII)
		{
			$dealII.TrimEnd(",")| Out-File d:\temp\drivestatus\drivestatusIV.txt -Append
				
		}
	
# Get the content from the text file above, assign variables check for a status of "DOWN" and send an email.	
	$logs = gc d:\temp\drivestatus\drivestatusIV.txt
	
	foreach ($line in $logs)
		{
			$drivenum = $line.split(",")[0]
			$status = $line.split(",")[1]
		
			$status
			
				if ($status -eq "DOWN")
			
					{
							$body = $drivenum + " " + $status + " " + $document   # | % {$_ +"`n"}
							$sender = "backupadmin@mitchell1.com"
							$recipient = "backupadmin@mitchell1.com,8584445735@messaging.sprintpcs.com,6196726959@vtext.com,opsoncall@mitchell1.com"
							#$recipient = "backupadmin@mitchell1.com"
							$server = "smtp.corp.mitchellrepair.com"
							$subject = "Tape Drive Down" 
							$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
							$client = new-object System.Net.Mail.SmtpClient $server
							$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
							$client.Send($msg)
					}
	}		