$CitrixMeps = gc c:\Temp\CitrixMeps.txt
$CitrixMeps

foreach ($MepsPerson in $CitrixMeps)
{

(get-content \\dakota\user\$MepsPerson\ts\WINDOWS\MEPSClient.ini) | 
Foreach-Object {$_ -replace '^SERVERS=.+$',"SERVERS=PRODUCTION=meps-prod,TEST=meps-test,DEVELOPMENT=meps-devl"} | 
Set-Content \\dakota\user\$MepsPerson\ts\WINDOWS\MEPSClient.ini

}


    $body = "Please sign on and validate" 
	$sender = "administrator@mitchell1.com"
	$recipient = "8584445735@messaging.sprintpcs.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "MEPSCLIENT.INI has been updated" 
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)