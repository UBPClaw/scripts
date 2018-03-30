Function get-Unixdate ($UnixDate) {
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

$DlyBupDt = (get-date (get-date).AddDays(-100) -f M/d/yyyy)                                                                                
$Today = get-date -f M/d/yyyy                                                                                                            
bpimagelist -policy NA_Dakota_User -d $DlyBupDt -e $Today 23:59:59 |                                                                     
Where-Object {$_-match "IMAGE"} |
Where-Object {$_-match "IMAGE"}|
Where-Object {$_-match "Weekly"}|
#Where-Object {$_-match "Weekly" -or "Monthly"}| 
Out-File d:\temp\AllImages.txt -append
                            
$GetNbuImage = gc d:\temp\AllImages.txt
                             
Foreach ($BupId in $GetNbuImage)
{
		
		$ID = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[5]
		$Policy = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[6]
		$AssignedUnixDate = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[13]
		$AssignedUnixDateConv = (get-Unixdate $AssignedUnixDate).ToShortDateString()
		$ExpiredUnixDate = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[15]
		$ExpireDateConv = (get-Unixdate $ExpiredUnixDate).ToShortDateString()
		#The next 3 lines of code are using the backup id to get each piece of media associated with the backup.
		$Img =  bpimagelist -backupid $ID 
		$Img2 = $Img | 
		where-object {$_-notmatch "IMAGE" -and $_-notmatch "HISTO" -and $_-notmatch "\\"}

foreach ($object in $Img2)
					{
						$MedID = $object.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]
						$final = $ID + "," + $Policy + "," + $MedID + "," + $AssignedUnixDateConv + "," + $ExpireDateConv
						$final | Sort-Object -Unique | Out-File d:\temp\Imagelist.txt -append
					}
					
           }   
           
           
           $Gimages = gc d:\temp\Imagelist.txt | Sort-Object -Unique  
		
			foreach ($item in $Gimages)
				{
			                $BupID = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
			                $Bpolicy = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
							$Bcode = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
			     			$BAssignedDate = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[3]
							$BExpDate = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[4]
						
# Getting the volume pool. The volume pools are labled with a number. It is much easier to determin what is going on by the
# actual name of the volume pool. This is why I am using an IF statement. Volume pool 9 = offsite Volume Pool 10 = Onsite.
# It is possible for the MediaID\Barcode to exist in a pool besides 9 or 10 but we will handle that in another release.
			
					$MedPool = bpmedialist -m $Bcode -L |
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
		#$BDate + "," + $Bpolicy + "," + $Bcode + "," + $MedPool + "," + $TapeExpire | Out-File d:\temp\TapeLocation.txt -append  
		$Bpolicy + ","  + $BupID + "," + $Bcode + "," + $BAssignedDate + "," + $BExpDate + "," + $MedPool  | Out-File d:\temp\TapeLocation.txt -append  
		}             