#The NBU console keeps only 3 days of entries. For troubleshooting, projecting and other projects,
#we need to track these jobs for as far back as we can.
#This script will be scheduled on the Canyon server to run at the beginning of every day.
#It will gather the logs for the previous day and append them to \\gremlin\d$\BKD_LOGS\NBUJOBS.txt
#I will then write more scripts to build reports from the this master log file.

$dadate = (get-date (get-date).AddDays(-1) -f M/d/yyyy)
psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpdbjobs" -ignore_parent_jobs -noheader |
    where-object {$_-match "$dadate"}  | Out-File \\gremlin\d$\BKD_LOGS\NBUJOBS.txt -append
	
	
	
		    $body="The logs can be found at \\gremlin\d$\BKD_LOGS\NBUJOBS.txt"
			$sender = "backupadmin@mitchell1.com"
			$recipient = "bryan.debrun@mitchell1.com"
			#$recipient = "backupadmin@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "NBU Console files for" + " " + $dadate + " " + "have been added to the master log."
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
			$client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)