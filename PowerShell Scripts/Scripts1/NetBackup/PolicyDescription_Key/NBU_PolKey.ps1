remove-item D:\BKD_LOGS\PolicyDescription\Pkey.txt

$getKey = bppllist |
		
		Where-Object {$_-notmatch "Vault"}

	foreach ($Policy in $getKey)
	
		{
			$p2 = bppllist $Policy |
			
				where-object {$_-match "KEY"}|
				ForEach-Object {$_-replace "KEY ",""}
			$policy + "," + $p2 | Out-File D:\BKD_LOGS\PolicyDescription\Pkey.txt -append
		
		}