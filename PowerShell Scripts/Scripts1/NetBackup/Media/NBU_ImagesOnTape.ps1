$Gimages = gc D:\BKD_LOGS\Media\MediaTracker\outgoing.txt

foreach ($tape in $Gimages)

	{
		$images = bpimmedia -mediaid $tape |
		Where-Object {$_-match "IMAGE"} #| Out-File D:\BKD_LOGS\Media\MediaTracker\MediaReturn\MediaTracker.txt -append
		
		foreach ($ImageOnTape in $images)
		
				{
				
					$tape + "," +$ImageOnTape | Out-File D:\BKD_LOGS\Media\MediaTracker\MediaReturn\MediaTracker.txt -append
				}
	}