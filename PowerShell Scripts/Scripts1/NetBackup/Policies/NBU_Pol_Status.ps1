 $PolList = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist"
 Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv
 Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.csv
 $Header = "Policy,Status"
 $Header | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv -append
foreach ($policy in $PolList)
 	{
 		$ActivePol = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" $policy -L |
 			where-object {$_-match "Active:" } |
			ForEach-Object {$_-replace "Active:            yes","1"} |
			ForEach-Object {$_-replace "Active:            no","0" }
			                           
			
			$policy + "," + $ActivePol | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv -append
			}
			
			
			Import-Csv \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv | Export-Csv \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.csv -notype
	
