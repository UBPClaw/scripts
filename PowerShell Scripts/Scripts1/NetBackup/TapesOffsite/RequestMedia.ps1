# ==========================================================================
#
# Microsoft PowerShell File
#
# NAME: ScratchPoolMedia.ps1
#
# DATE: 11/27/2007
#
# Author: Bryan DeBrun
#
# COMMENT: Tell OPS which tapes to request from iron mountain
# ==========================================================================

$GetDate = Get-Date -Format yyMMdd

# If the offsitemedia.txt file exists, remove it

# Get a list of tapes that which are offsite and are scheduled to be returnned.
# The number 4 signifies that the tape is offsite and is ready to be returnned to
# the scratch pool. The number 4 represents the scratch pool.
# The 4  Offsite means the tape is in the scratch pool being returnned from the 
# offsite pool. 

 $QueryOffsiteMedia = vmquery -v offsite_LT02 -w |
	where-object {$_ -match "  4  Offsite"} | 
	foreach { $_.split(" ", [StringSplitOptions]::RemoveEmptyEntries)[0]}

# Configure email message. The email will tell OPs which tapes to request from
# Iron Mountain.

$body=$QueryOffsiteMedia | % {$_+"`n"}
$sender = "backupadmin@mitchell1.com"
#$recipient = "bryan.debrun@mitchell1.com"
$recipient = "backupadmin@mitchell1.com"
$server = "smtp.corp.mitchellrepair.com"
$subject = "The following tapes should be requested for return "+ $gcd 
$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
$client = new-object System.Net.Mail.SmtpClient $server
$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
$client.Send($msg)


# This is for CYA. In the event that requested tapes get removed from the library
# and the email listing the tapes scheduled to be returnned gets deleted. We can 
# look in the directory below to see which tapes need returnned that day.
$QueryOffsiteMedia | 
Out-File D:\BKD_LOGS\Media\MediaTracker\MediaReturn\$GetDate.txt -append

# Remove the tape from the library. When the tapes are actually delivered and
# if there is available slots in the library, we can add the tapes back into
# the library by inserting as many tapes as we have empty slots for and then
# running an inventory on the robot.

foreach ($tape in $QueryOffsiteMedia)
 
	{
	   $slot =  vmquery -m $tape |
			where-object {$_-match "robot slot:"}|
			ForEach-Object {$_-replace "robot ",""}|
			ForEach-Object {$_-replace "            ",""}|
			ForEach-Object {$_-replace "Slot:",""}
	
				if ($slot -eq $NUL)
	
				{
	 				vmdelete -m $tape 
	 
				}
	
	}