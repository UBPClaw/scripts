$BackupID = "nova_1234648803"


$MCopyCount = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BackupID |
	Where-Object {$_-match "FRAG" -and $_-notmatch ":" -and $_-notmatch "\\"} |  
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]} | Sort-Object -Unique
	$MCopyCount | Sort-Object -Unique
	
	
	foreach ($pmedia in $MCopyCount)
		{
			$Vpool = psexec \\gremlin "D:\program files\veritas\Volmgr\bin\vmquery" -m $pmedia |
				Where-Object {$_-match "volume pool:"} |
				foreach {$_-replace "volume pool:          ",""}
				
			$Vslot = psexec \\gremlin "D:\program files\veritas\Volmgr\bin\vmquery" -m $pmedia |
				Where-Object {$_-match "robot slot:"} |
				foreach {$_-replace "robot slot:          ",""}
				
				$BackupID + " " + $pmedia + " " + $Vpool + " " + $Vslot
	
		}
	
	
	
	
	
	
	
	
	
   


   			