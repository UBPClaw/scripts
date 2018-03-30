
$TapeInfo = gc D:\BKD_LOGS\Media\ATIMntn\atimntn.txt

	foreach ($tape in $TapeInfo)
	
	{

$TapeExpire = bpmedialist -m $tape -L |
#bpmedialist -m 000011 -L |
						Where-Object {$_-match "expiration"} |
						ForEach-Object {$_-replace "expiration = ",""} |
						Foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
						foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
						
						if ($TapeExpire -eq $null)
			
				{
						$TapeExpire = "NA"
				}

					

$dinsity = bpmedialist -m $tape -L |
#bpmedialist -m 000011 -L |
						Where-Object {$_-match "density"} |
						ForEach-Object {$_-replace "density = ",""} |
						Foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
						foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
						
						if ($dinsity -eq $null)
			
				{
						$dinsity = "NA"
				}



						
$vmpool = bpmedialist -m $tape -L |
#bpmedialist -m 000011 -L |
						Where-Object {$_-match "vmpool"} |
						ForEach-Object {$_-replace "vmpool = ",""} |
						Foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
						foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
						
						if ($vmpool -eq $null)
			
				{
						$vmpool = "NA"
				}
						

$TapeExpire + "," + $Tape + "," + $dinsity + "," + $vmpool | out-file D:\BKD_LOGS\Media\ATIMntn\TapeReport.txt -append

}

							
			
			
			$Final = $Tape + "," + $dinsity + "," + vmpool + "," + $TapeExpire
			$Final
			
		       
			
			
		}	
			
				
					