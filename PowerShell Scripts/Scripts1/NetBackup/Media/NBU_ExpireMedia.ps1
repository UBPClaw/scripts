Remove-Item d:\BKD_LOGS\Media\ExpireMe.txt
Remove-Item d:\BKD_LOGS\Media\ExpireMedia.txt


$Today = get-date -f MM/dd/yyyy
$yesterday = (get-date (get-date).AddDays(-1) -f MM/dd/yyyy)
#$Min1 = (get-date (get-date).AddDays(+1) -f MM/dd/yyyy)
#$Min2 = (get-date (get-date).AddDays(+2) -f MM/dd/yyyy)
#$Min3 = (get-date (get-date).AddDays(+3) -f MM/dd/yyyy)
#$Min4 = (get-date (get-date).AddDays(+4) -f MM/dd/yyyy)
#$Min5 = (get-date (get-date).AddDays(+5) -f MM/dd/yyyy)
#$Min6 = (get-date (get-date).AddDays(+6) -f MM/dd/yyyy)
#$Min7 = (get-date (get-date).AddDays(+7) -f MM/dd/yyyy)
$Min8 = (get-date (get-date).AddDays(+8) -f MM/dd/yyyy)





$gSlots = vmquery -p 4|
	where-object {$_-match "robot slot:"}|
	ForEach-Object {$_-replace "robot ",""}|
	ForEach-Object {$_-replace "            ",""}|
	ForEach-Object {$_-replace "Slot:",""}|
	Foreach-object {$_+"`n"} | Sort-Object
	
	$gSlots.count
	
	if ($gSlots.count -lt 5)
	
			{
				$Expire = bpmedialist -p Onsite -L |
					Where-Object {$_-match "expiration"} |
					foreach-object {$_-replace "expiration = ",""}  |
					foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
					foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
	
	
				$Media = bpmedialist -p Onsite -L |
					Where-Object {$_-match "media_id"} |
	                foreach-object {$_-replace "media_id = ",""} |
					ForEach-Object {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]} 
	
	
				$i = 0 

 					$EpireMed = $(while ($i -le $Expire.count) {$Expire[$i]+","+$Media[$i];$i++}) 
 					$EpireMed | Out-File d:\BKD_LOGS\Media\ExpireMe.txt -append 
 
 						
			 	 $GDate = gc d:\BKD_LOGS\Media\ExpireMe.txt 
				 $emailbody = gc d:\BKD_LOGS\Media\ExpireMe.txt | Where-Object {$_-gt $yesterday -and $_-lt $Min8} | Sort-Object 

foreach ($entry in $GDate)
	{
		
		
		$entry | Where-Object {$_-gt $yesterday -and $_-lt $Min8} |
		foreach-object {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]} | Out-File d:\BKD_LOGS\Media\ExpireMedia.txt -append
		  
		  }
				  
				  $GexpMed = gc d:\BKD_LOGS\Media\ExpireMedia.txt
		          $GexpMed.count
				  
				  				  
				  
				  foreach ($TapeID in $GexpMed)
		  			{
					bpexpdate -m $TapeID -d 0 -force
					
					
					}

						
		
	
	$body = "We are expiring " + $GexpMed.count + " tapes `n" + $emailbody | ForEach-Object {$_+"`n"}
	$sender = "backupadmin@mitchell1.com"
	#$recipient = "bryan.debrun@mitchell1.com,8584445735@messaging.sprintpcs.com"
	$recipient = "backupadmin@mitchell1.com,8584445735@messaging.sprintpcs.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "The Scrath Pool is Below 5 tapes. The following tapes have been expired from the Onsite Pool and moved to the Scrath Pool" 
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)
				
				}
				
				else
				
					{
						"Your Good"
						
						}



	
	