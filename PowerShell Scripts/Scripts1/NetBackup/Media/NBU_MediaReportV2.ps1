
remove-item D:\temp\mediastatus.txt
$MediaIDList = bpmedialist -l 

foreach ($Media in $MediaIDList  )
		{
			$mediaID = $Media.split(" ")[0]
			
		
			$mediaID

$MediaStatus = bpmedialist -m $mediaID -l

foreach ($line in $MediaStatus )
		{
			$vpool =  $line.split(" ")[12]
			$status = $line.split(" ")[14]
			
				#if ($status -eq "1")
			
				#{
						#$status = "FROZEN"
				#}
		

$RobSlot = vmquery -m $mediaID|
	Where-Object {$_-match "robot slot:"} |
	foreach-object {$_-replace "robot slot:            ",""}	
	if ($RobSlot  -eq $NULL)
		{
			$RobSlot  = ""
			
			}
			
			else
			{
			}
			$RobSlot  


$Assd = vmquery -m $mediaID |
	Where-Object {$_-match "assigned:"} |
	foreach-object {$_-replace "assigned:              ",""}
	$Assigned = $Assd.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($Assigned    -eq $NULL)
		{
			$Assigned   = ""
			
			}
			
			elseif ($Assigned    -eq "---")
				{
					$Assigned    = ""
				}
			$Assigned



$LstMt = vmquery -m $mediaID |
	Where-Object {$_-match "last mounted:"} |
	foreach-object {$_-replace "last mounted:          ",""}
	$LstMount = $LstMt.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($LstMount    -eq $NULL)
		{
			$LstMount   = ""
			
			}
			
			elseif ($LstMount    -eq "---")
				{
					$LstMount    = ""
				}
			$LstMount  

$NumMounts= vmquery -m $mediaID |
	Where-Object {$_-match "number of mounts:"} |
	foreach-object {$_-replace "number of mounts:      ",""}
	
	if ($NumMounts    -eq $NULL)
		{
			$NumMounts   = ""
			
			}
			
			elseif ($NumMounts    -eq "---")
				{
					$NumMounts    = ""
				}
			$NumMounts 


$Expire= bpmedialist -m $mediaID -L |
	Where-Object {$_-match "expiration"} |
	foreach-object {$_-replace "expiration = ",""}
	$Expiration1 = $Expire.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]
	$Expiration = $Expiration1.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($Expiration    -eq $NULL)
		{
			$Expiration   = ""
			
			}
			
			elseif ($Expiration    -eq "---")
				{
					$Expiration    = ""
				}
			$Expiration


			$mediaID + "," + $status + "," + $vpool + "," + $RobSlot + "," + $Assigned + "," + $LstMount + "," + $Expiration + "," + $NumMounts | out-file d:\temp\mediastatus.txt -append
}

}
	





