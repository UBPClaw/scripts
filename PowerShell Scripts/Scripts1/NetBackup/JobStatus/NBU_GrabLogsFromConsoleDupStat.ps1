Function get-Unixdate ($UnixDate) {
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}


$BupDt = (get-date (get-date).AddDays(-3) -f M/d/yyyy)
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}

remove-item \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMedLocation_$FileDate.txt


remove-item \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMedia.txt
remove-item \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMediaII.txt
remove-item \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMedLocation.txt

$QLogs = gc \\gremlin\d$\BKD_LOGS\NBULOGS\NBULogsToSQL_$FileDate.txt |
	Where-Object {$_.split(",")[5] -match "Weekly" -or $_.split(",")[5] -match "Monthly" -or $_.split(",")[5] -match "Full" }
	
	
	foreach ($line in $QLogs )
	
		{
		
			$Jobid = $line.split(",")[0]
			$Policy = $line.split(",")[4]
			$BupID = $line.split(",")[13]
			
			$Img =psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BupID |
				where-object {$_-notmatch "IMAGE" -and $_-notmatch "HISTO" -and $_-notmatch "\\"}
			
			#$Jobid +","+$Policy+","+$BupID
			
			
			
			foreach ($object in $Img)
					{
						$Imgg = $object.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]
						#$UnixDate = $object.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[12]
						#$DateConv = (get-Unixdate $UnixDate).ToShortDateString()
						$final = $Jobid + "," + $Policy + "," + $Imgg + "," + $BupID 
						$final | Sort-Object -Unique | Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMedia.txt -append
					}
					
			
			
			
			
		}
	
	$GMedia = gc \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMedia.txt | Sort-Object -Unique  | Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMediaII.txt
	
	
	
	$GMediaII = gc \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMediaII.txt 
		
			foreach ($item in $GMediaII)
				{
			
					$BJobId = $item.split(",")[0]
					$Bpolicy = $item.split(",")[1]
					$Bcode = $item.split(",")[2]
					$BbupID = $item.split(",")[3]
					
				
# This is where we are using the NetBackup command bpmedialist to return the required details of the MediaID\Barcode.
# We want both the expiration date of the MediaID\Barcode and the Volume pool it resides in. The volume pool will tell us
# if the media is on or off site.

					$TapeExpire = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpmedialist" -m $Bcode -L |
						Where-Object {$_-match "expiration"} |
						ForEach-Object {$_-replace "expiration = ",""} |
						Foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
						foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
						
# Getting the volume pool. The volume pools are labled with a number. It is much easier to determin what is going on by the
# actual name of the volume pool. This is why I am using an IF statement. Volume pool 9 = offsite Volume Pool 10 = Onsite.
# It is possible for the MediaID\Barcode to exist in a pool besides 9 or 10 but we will handle that in another release.
			
					$MedPool = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpmedialist" -m $Bcode -L |
						Where-Object {$_-match "vmpool"}
			
							if ($MedPool  -eq "vmpool = 10")
			                  	
								{
									$MedPool  = "Onsite"
								}
					
							elseif ($MedPool  -eq "vmpool = 9")
					
								{
									$MedPool  = "Offsite"
								}
							
# Output The Backup Date, Policy name, Barcode, Volume Pool, and the Experation Date to a csv file. 			
		$FileDate + "," + $BJobId + "," + $Bpolicy + "," + $Bcode + "," + $MedPool + "," + $BbupID + "," + $TapeExpire | Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\Duplication\DupMedLocation_$FileDate.txt -append
		          }
				  
				  
				  
				  