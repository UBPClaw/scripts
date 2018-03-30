Remove-Item \\gremlin\d$\BKD_LOGS\TapesOffsite\sendoffsite.txt
$gcd=get-date -f MM/dd/yyyy
$gcd2=get-date -f M/d/yyyy
$file=get-childitem "\\gremlin\d$\Program Files\VERITAS\NetBackup\vault\sessions\Offsite-Vault" -recurse | Where-Object {$_.LastWriteTime -like "*$gcd*" -or $_.LastWriteTime -like "*$gcd2*" -and $_.Name -like "*eject.list*"}

foreach ($list in $file)
{
$gc=get-content $list.fullname | % {$_.split(" ")} | ? {$_ -like "*00*"} | Out-File \\gremlin\d$\BKD_LOGS\TapesOffsite\sendoffsite.txt -append
$sendtapes = gc \\gremlin\d$\BKD_LOGS\TapesOffsite\sendoffsite.txt
$body=$sendtapes | % {$_ +"`n"}
}
# $body=$gc | % {$_+"********************************************************************************************************************************" }

$sender = "backupadmin@mitchell1.com"
#$recipient = "bryan.debrun@mitchell1.com"
$recipient = "backupadmin@mitchell1.com"
$server = "smtp.corp.mitchellrepair.com"
$subject = "The following tapes should go off site "+ $gcd 
$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
$client = new-object System.Net.Mail.SmtpClient $server
$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
$client.Send($msg)