

Remove-Item \\gremlin\d$\BKD_LOGS\MonthEnd\MonthEMedia.csv
$Header2 = "Policy,MediaID,Expiration,Location"
$Header2 | out-file \\gremlin\d$\BKD_LOGS\MonthEnd\MonthEMedia.csv -append

$GMMedia = gc \\gremlin\d$\BKD_LOGS\MonthEnd\MonthEnd.csv |
	where {$_-match "NT_CIS_After_MonthEnd" -or $_-match "NT_CIS_Before_MonthEnd" -or $_-match "FILER_Finance_MonthEnd"} 
	#$GMMedia
	
	foreach ($item in $GMMedia)
	{
	$Policy = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
	$BUPID = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
	#$Policy
	#$BUPID
	
	foreach ($BUP in $BUPID)
	{
	$GBupInfo = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BUP |
		Where-Object {$_-match "FRAG"} |
		ForEach-Object {$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]} | Sort-Object -unique 
		
		foreach ($ID in $GBupInfo)
			{
				$GTapeInfo = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpmedialist" -m $ID -L |
					Where-Object {$_-match "expiration"} |
						ForEach-Object {$_-replace "expiration = ",""} |
						Foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
						foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
						
						
						$MedPool = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpmedialist" -m $ID -L |
						Where-Object {$_-match "vmpool"}
			
							if ($MedPool  -eq "vmpool = 10")
			                  	
								{
									$MedPool  = "Onsite"
								}
					
							elseif ($MedPool  -eq "vmpool = 9")
					
								{
									$MedPool  = "Offsite"
								}
								
								elseif ($MedPool  -eq "vmpool = 5")
					
								{
									$MedPool  = "Off Long"
								}
				
				$Policy + "," + $ID + "," + $GTapeInfo + "," + $MedPool | out-file \\gremlin\d$\BKD_LOGS\MonthEnd\MonthEMedia.csv -append
						
				
				}
		
	
	
	}
	
	}
	
	
	
	
	
	
	
	