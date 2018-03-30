
$shares = "\\ranger\root$","\\dakota\root$","\\dakota\Arch_Sata_Root$","\\malibu\it","\\colorado\root$"
function Get-DriveSpace
{
	$driveinfo = (New-Object -com scripting.filesystemobject).getdrive("$_") 
	if (($driveinfo.freespace/1GB) -lt 15){
		#Send Email
		$sender = "net.admin@mitchell1.com"
		$recipient = "opsoncall@mitchell1.com"
		$server = "smtp.corp.mitchellrepair.com"
		$subject = "OnStor Low Disk Space Alert for " + $_
		$body = "The freespace on " + $_  + " is " + ($driveinfo.freespace/1GB).tostring("0.00") + " GB.`n`nSee `"\\malibu\it\NTServers\Docs\How To - Add Disk to Onstor Volume.txt`""
		$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
		$msg.Priority = "High"
		$client = new-object System.Net.Mail.SmtpClient $server
		$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
		$client.Send($msg) 
	 }
}
$shares | %{Get-DriveSpace}
