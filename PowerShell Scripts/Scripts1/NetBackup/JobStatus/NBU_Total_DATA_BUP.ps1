$BupDt = (get-date (get-date).AddDays(-1) -f M/d/yyyy)
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}


Remove-Item \\gremlin\d$\BKD_LOGS\NBULOGS\Totals\BupTot.csv
$header = "kbs"
$header | Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\Totals\BupTot.csv -append

gc \\gremlin\d$\BKD_LOGS\NBULOGS\NBULogsToSQL.txt |
	ForEach-Object {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[11]} | Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\Totals\BupTot.csv -append




 Import-Csv \\gremlin\d$\BKD_LOGS\NBULOGS\Totals\BupTot.csv | 
		measure-object kbs -sum |
		
				
			
		Select-Object @{name="$BupDt Total Size(MB)";Expression={"{0:N0}" -f ($_.sum)}} | 
			Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\Totals\BupTotals.csv -append
			
			
			
			$SendTotalsEmail = gc \\gremlin\d$\BKD_LOGS\NBULOGS\Totals\BupTotals.csv  
	
	
	
	$body =$SendTotalsEmail | % {$_ +"`n"}
	$sender = "backupadmin@mitchell1.com"
	$recipient = "bryan.debrun@mitchell1.com"
	#$recipient = "backupadmin@mitchell1.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "NBU Report Total Data BUP" 
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)