#***********************************************
#* MonitorDiskSpace.ps1                        *
#* Created 05-09-08                            *
#* Created by Bryan DeBrun                     *
#* Purpose Monitor Disk space on Gremlin       *
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
$log = "\\gremlin\d$\temp\MonitorNBU\"+"Diskspacemonitor.log"


if (gwmi win32_logicaldisk -computer gremlin | where {$_.deviceid -eq "D:"} | ? -f{$_.FreeSpace -lt 27384398848})

{
			Write-log "$dadate Running out of Disk space." $log
			$body=$offsite | % {$_+"`n"}
			$sender = "backupadmin@mitchell1.com"
			$recipient = "bryan.debrun@mitchell1.com"
			$recipient = "OPSOnCall@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "Running out of disk space on Gremlin!" 
			$body = "Delete some NBU log files <D:\program files\veritas\netbackup\logs>."
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
			$client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)		
}
else
{
			Write-log "$dadate Plenty of disk space" $log
		        $body=$offsite | % {$_+"`n"}
			$sender = "backupadmin@mitchell1.com"
			$recipient = "bryan.debrun@mitchell1.com"
			#$recipient = "backupadmin@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "Disk Space Check on Gremlin OK"
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
			$client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)	
}




