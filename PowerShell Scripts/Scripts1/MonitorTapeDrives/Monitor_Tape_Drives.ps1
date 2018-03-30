Remove-Item d:\temp\drivestatus\drivestatus.txt
Remove-Item d:\temp\drivestatus\drivestatusII.txt
Remove-Item d:\temp\drivestatus\drivestatusIII.txt
Remove-Item d:\temp\drivestatus\drivestatusIV.txt
$BupHost = "gremlin"
vmoprcmd -dp -h $BupHost |  where-object {$_ -match "UP" -or $_-match "Down"} | Out-File d:\temp\drivestatus\drivestatus.txt
#Get-Content d:\temp\drivestatus.txt | Select-Object -First 17 | Out-File d:\temp\drivestatus\drivestatusII.txt
# Get-Content d:\temp\drivestatusII.txt | Select-Object -Last 9 |
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
	
	
	$logs = gc d:\temp\drivestatus\drivestatusIV.txt
	
	foreach ($line in $logs)
	{
		$drivenum = $line.split(",")[0]
		$status = $line.split(",")[1]
		$status
		if ($status -eq "DOWN")
			
				{
						
						
							$body = $drivenum + " " + $status # | % {$_ +"`n"}
							$sender = "backupadmin@mitchell1.com"
							$recipient = "backupadmin@mitchell1.com,8584445735@messaging.sprintpcs.com,6196726959@vtext.com"
							#$recipient = "backupadmin@mitchell1.com"
							$server = "smtp.corp.mitchellrepair.com"
							$subject = "Tape Drive Down" 
							$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
							$client = new-object System.Net.Mail.SmtpClient $server
							$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
							$client.Send($msg)
				}
	}		