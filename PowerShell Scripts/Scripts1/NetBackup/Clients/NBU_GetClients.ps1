
remove-item D:\BKD_LOGS\Clients\clients.txt
$P1 = bppllist |
		
		Where-Object {$_-notmatch "Vault"}

	foreach ($Policy in $P1)
	
		{
			$p2 = bppllist $Policy | 
	    		Where-Object {$_-match "CLIENT"}
	    		
	    		if ($p2 -eq $null)
			
				{
						$p2 = ""
				}
	    		
				
				ForEach-Object {$_-replace "CLIENT","$Policy"} |
				ForEach-Object {$_-replace ".corp.mitchellrepair.com",""} |
				ForEach-Object {$_-replace ".mitchell1.com",""}
				
				
								
					foreach ($line in $p2)
						{
							$Pol = $line.split(" ")[0]
				            $Clnt = $line.split(" ")[1]
				            
				            if ($Clnt -eq $null)
			
				{
						$Clnt = "NC"
				}
				            
				            
				
							$Policy + "," + $Clnt | Out-File D:\BKD_LOGS\Clients\clients.txt -append
						}
				
				
		}
