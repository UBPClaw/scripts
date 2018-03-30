#***********************************************
#* MonitorNBUDB.ps1                            *
#* Created 05-06-08                            *
#* Created by Bryan DeBrun                     *
#* Purpose Monitor the Net Backup Database     *
#* Server  Gremlin                             *
#* Run From Canyon                             *
#***********************************************


# Assign the Time for creating logs
$dadate = (get-date).toString('yyyy-MM-dd-hh:mm:ss')


# Create the function the writes the log file.
Function Write-Log 
{
   Param([string]$msg,[string]$file)
   Write-Host "$msg"
   $msg | Out-File -FilePath $file -Append
}


# Set the location of the log file
$log = "\\gremlin\d$\temp\MonitorNBU\"+"NBUDBmonitor.log"


#The line below is for testing a NBUDB down. To test uncomment the line below and comment the working line just below it.
#$checkNBUDB = "NBUDB is down dude!" 

# Run a remote application on gremlin. The nbdb_ping utility will ping the Backup Database.
$checkNBUDB = psexec \\gremlin "D:\program files\veritas\netbackup\bin\nbdb_ping" 

		if($checkNBUDB -eq "Database [NBDB] is alive and well on server [NB_GREMLIN].")
		{
			Write-log "$dadate NBU Database is UP" $log
		        $body=$offsite | % {$_+"`n"}
			$sender = "backupadmin@mitchell1.com"
			#$recipient = "bryan.debrun@mitchell1.com"
			#$recipient = "backupadmin@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "The Net Backup Database is up"
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
			$client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)
			
		}
		else
		{
			Write-log "$dadate NBU Database is Down" $log
			$body=$offsite | % {$_+"`n"}
			$sender = "backupadmin@mitchell1.com"
			$recipient = "bryan.debrun@mitchell1.com"
			$recipient = "OPSOnCall@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "The Net Backup Database is Down!" 
			$body = "Follow the following document for processing this error."
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
			$client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)	 
		}

				
	
	
