$GJobid = bpdbjobs -most_columns |
	Where-Object {$_-match "sav01"} 
	
$GJobState = bpdbjobs -most_columns |
	Where-Object {$_-match "sav01"}
		
	$ID = $GJobid.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0] 
	$State = $GJobState.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
	
	if ($State -eq "5")
		{ 
		    $body="Status of Colo WebData restore " + " State = " + $State + "`n" + "(0 is queued, 1 is Active, 2 is re-queued, 3 is Done, 4 is Suspended and 5 is incomplete )"
			$sender = "backupadmin@mitchell1.com"
			$recipient = "bryan.debrun@mitchell1.com"
			#$recipient = "backupadmin@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "Colo Restore Status" + " JOB ID = " + $ID + " JOB STATE = " + $State 
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
		    $client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)
			
			bpdbjobs -resume $ID 
			
			}
			
			else
			{
			
		    $body="Status of Colo WebData restore " + " State = " + $State + "`n" + "(0 is queued, 1 is Active, 2 is re-queued, 3 is Done, 4 is Suspended and 5 is incomplete )"
			$sender = "backupadmin@mitchell1.com"
			$recipient = "bryan.debrun@mitchell1.com"
			#$recipient = "backupadmin@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "Colo Restore Status" + " JOB ID = " + $ID + " JOB STATE = " + $State 
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
		    $client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)
			}
	
	