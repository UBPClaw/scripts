

$today = get-date -f M/dd/yyyy
$today

	
	$Rcomputer = "qa1web"
	$Elog = "Application"
	$Evelog = new-object system.diagnostics.eventlog("$Elog", "$Rcomputer")
	$Report = $Evelog.entries | where {$_.TimeWritten.ToShortDateString() -eq "3/30/2009" -and $_.EventID -eq "1001" } | select TimeWritten,Source,EventId | out-string
	$Report
	#where {$_.TimeWritten.ToShortDateString() -eq $Today -and $_.EventID -eq "1309" -and $_.Source -eq "ASP.NET 2.0.50727.0"} | select TimeWritten,Source,EventId | out-string
	
	
	if ($Report.EventID -eq $NUL)
	
		{
			"No EVENTS"
		}
					
			
			else
			
			 {
				$body = $Report
				$sender = "dataadmin@mitchell1.com"
				$recipient = "bryan.debrun@mitchell1.com"
				$recipient = "dataadmin@mitchell1.com,mohanan.gopalan@mitchell1.com"
				$server = "smtp.corp.mitchellrepair.com"
				$subject = "Application Event Alert on " + $Rcomputer + " " + $Elog + " Log " 
				$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
				$client = new-object System.Net.Mail.SmtpClient $server
				$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
				$client.Send($msg)
			}
				

	
	
	