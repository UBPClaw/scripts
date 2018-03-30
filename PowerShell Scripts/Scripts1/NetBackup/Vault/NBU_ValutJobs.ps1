$today = get-date -f M/d/yyyy
#$Header = "Vault,Status,Client,MediaS,RunTime,StartDate,StartTime,EndDate,EndTime" 
#$Header | Out-File \\gremlin\d$\BKD_LOGS\Vault\VaultTemp.csv

#$GJobid = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpdbjobs" -L |
    bpdbjobs -L |
	Where-Object {$_-match "Vault"} | 
	foreach-object {$_-replace "  root          Vault","" } |
	foreach-object {$_-replace " PM",",PM" } |
	foreach-object {$_-replace " AM",",AM" } |
	foreach-object {$_-replace "-","" } |
	foreach-object {$_ -replace " {1,}",","} |
	ForEach-Object {$_.TrimStart(",").TrimEnd(",")} |
	
	#Out-File \\gremlin\d$\BKD_LOGS\Vault\Vaulttemp.csv -append
	Out-File d:\BKD_LOGS\Vault\Vaulttemp.csv -append
	
	
	Import-Csv d:\BKD_LOGS\Vault\Vaulttemp.csv | Export-Csv d:\BKD_LOGS\Vault\Vault.csv -notype
	
	
	
	$GetVaultRept = Import-Csv  d:\BKD_LOGS\Vault\Vault.csv |
	select -unique Vault,Status,StartDate | Out-string 
	
	
	$body = $GetVaultRept 
	$sender = "backupadmin@mitchell1.com"
	$recipient = "bryan.debrun@mitchell1.com"
	#$recipient = "backupadmin@mitchell1.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "Vault Job Report for " + $today
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)
	
	
	
