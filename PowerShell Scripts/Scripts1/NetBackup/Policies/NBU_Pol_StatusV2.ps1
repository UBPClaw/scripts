$PolList = bppllist
 
foreach ($policy in $PolList)
 	{
 		$ActivePol = bppllist $policy -L |
 			where-object {$_-match "Active:" } |
			ForEach-Object {$_-replace "Active:            yes","1"} |
			ForEach-Object {$_-replace "Active:            no","0" }
			                           
			
			$policy + "," + $ActivePol | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyStat_Jan232012.txt -append
			}
			
			
			
	
