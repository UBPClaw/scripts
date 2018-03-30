
# ==================================================================================================================
# \\malibu\it\NTServers\Scripts\NetBackup\NBU_BuildLogsFromNBUconsole.ps1
# Date 10/24/2008
# Bryan K. DeBrun
# The NBU console keeps only 3 days of entries. For troubleshooting, projecting and other projects,
# we need to track these jobs for as far back as we can.
# This script will be scheduled on the Canyon server to run at 11:00 AM every day.
# It will gather the logs for the previous day and append them to \\gremlin\d$\BKD_LOGS\NBUJOBS.txt
# So, we are building our own log.
# I will then write more scripts to build reports from the this master log file.
# ==================================================================================================================


# Get the date and then subtract 1 day
# This will give us the date of the previous day
$dadate = (get-date (get-date).AddDays(-1) -f M/d/yyyy)
$dadateOut = (get-date (get-date).AddDays(-1) -f M-d-yyyy)

# The NBU command bpdbjobs will capture anything that is in the Net Backup Manager console.  

psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpdbjobs" -ignore_parent_jobs -noheader |
    where-object {$_-match "$dadate"}  | Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\$dadateOut.txt 
	
	
# Send an email to me notifying me that the last day was added to the log. 

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
			
			
			
			
# REBUILD THE LOG AND CREATE THE FINAL LOG

#$dadateOut = (get-date (get-date).AddDays(-1) -f M-d-yyyy)
$Scrape1 = @(gc \\gremlin\d$\BKD_LOGS\NBULOGS\$dadateOut.txt | 
	Where-Object {$_ -match "Backup"} |
	Where-Object {$_ -notmatch "Catalog"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","BYE" } |
	foreach-object {$_-replace "PM                              ","PM,NOENDYET,NOENDTIMEYET,NOSTAT" } |
	foreach-object {$_-replace "AM                              ","AM,NOENDYET,NOENDTIMEYET,NOSTAT" } |
	foreach-object {$_-replace " Catalog Backup                               CATALOG   ","Catalog Backup                           " } |
	foreach-object {$_-replace "SYSTEMCatalog Backup                          ","SYSTEMCatalog Backup                    " } |
	foreach-object {$_-replace "Catalog Backup                           Done             ","Catalog Backup                           Done gremlin     " } |
	foreach-object {$_ -replace " {1,}",","}|
	foreach-object {$_ -replace "BYE,",""}|
	foreach-object {$_ -replace ",AM,"," AM,"}|
	foreach-object {$_ -replace ",PM,"," PM,"}|
	#foreach-object {$_ -replace ",{1,}",""}|
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	#foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]})
	#$gPolicyName
	Out-File \\gremlin\d$\BKD_LOGS\NBULOGSCRAPE\$dadateOut.txt)