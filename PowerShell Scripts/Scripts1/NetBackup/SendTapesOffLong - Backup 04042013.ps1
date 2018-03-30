# ==================================================================================================================
# \\malibu\it\NTServers\Scripts\NetBackup\SendTapesOffLong.ps1
# Date 10/24/2008
# Bryan K. DeBrun
# This script is to let backupadmin know that there are off long tapes to send off site. Off long means they will
# be off site for 10 years. In the past, we had to manually set the Vault schedule to run for the off long tapes.
# This is because monthend happens on different days of the month. This script will work in junction with setting
# the offlong valut job to run everyday. If there are tapes to send, backupadmin will get an email letting them
# know which tapes to send off site.
# This will be launched using a scheduled task on Canyon.
# ==================================================================================================================

# Get the date. The two variables for date below account for the digits in month in year being 1 or 2.

$gcd=get-date -f MM/dd/yyyy
$gcd2=get-date -f M/d/yyyy

# Do a directory listing and scrpe away what we don't need. We are looking for any tapes that would be ejected today.
# These tapes are listed in the eject list. There could be multiple tapes.

$file=get-childitem "\\gremlin\d$\Program Files\VERITAS\NetBackup\vault\sessions\Offlong-Vault" -recurse | 
	Where-Object {$_.LastWriteTime -like "*$gcd*" -or $_.LastWriteTime -like "*$gcd2*" -and $_.Name -like "*eject.list*"}


# If there are tapes to send, email backup admin with the tape ID's. If not, do nothing.

$gc=@(get-content $file.fullname | % {$_.split(" ")} | ? {$_ -like "*00*"})
$body="Pull the following tapes from the hopper and put them in the container `n
to go offsite. This particular email is for the tapes that will go off site for `n
10 years (offlong). There may or may not be reagular offsite tapes to include in `n
the container. If so, you will receive a seperate email for these tapes.`n
------------------------------------------------------------------------`n `n" + $gc  | % {$_ +"`n"}

$body2 = "Nothing to send of Site for Off Long"


if ($gc.count -eq 0)
{
	$sender = "backupadmin@mitchell1.com"
	$recipient = "backupadmin@mitchell1.com"
	#$recipient = "backupadmin@mitchell1.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "There are no Off Long tapes to send today"+ $gcd 
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body2
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)
}

ELSE
	{
		$sender = "backupadmin@mitchell1.com"
		#$recipient = "bryan.debrun@mitchell1.com"
		$recipient = "backupadmin@mitchell1.com"
		$server = "smtp.corp.mitchellrepair.com"
		$subject = "there is " + " " +  $gc.count +" " + "OffLong tape(s) to add to the offsite container "+ $gcd 
		$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
		$client = new-object System.Net.Mail.SmtpClient $server
		$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
		$client.Send($msg)
	}	