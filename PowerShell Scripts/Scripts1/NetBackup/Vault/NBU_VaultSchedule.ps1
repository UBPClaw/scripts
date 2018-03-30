remove-item \\gremlin\d$\BKD_LOGS\Vault\VaultSched.txt
$tdsdate = Get-Date -Format dddd
$header = "Vault,Day,Time"
$header | Out-File \\gremlin\d$\BKD_LOGS\Vault\VaultSched.csv

$GVault = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" 
	#Where-Object {$_-match "Vault"}
	


 
 
	foreach ($vault in $GVault)
		{


			$GVaultSched = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $vault  -L |
			Where-Object {$_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
					ForEach-Object {$_-replace "Schedule:          $GVault",""}  |
					ForEach-Object {$_-replace "   Monday","$vault,Monday"} |
					ForEach-Object {$_-replace "   Tuesday","$vault,Tuesday"} |
					ForEach-Object {$_-replace "   Wednesday","$vault,Wednesday"} |
					ForEach-Object {$_-replace "   Thursday","$vault,Thursday"} |
					ForEach-Object {$_-replace "   Friday","$vault,Friday"} |
					ForEach-Object {$_-replace "   Saturday","$vault,Saturday"} |
					ForEach-Object {$_-replace "   Sunday","$vault,Sunday"} |
					foreach-object {$_ -replace " {1,}",","} | Out-File \\gremlin\d$\BKD_LOGS\Vault\VaultSched.txt -append
					
							
					
					}
	
	$GVaultScheds = gc \\gremlin\d$\BKD_LOGS\Vault\VaultSched.txt
	
	foreach ($schedule in $GVaultScheds)
	
		{
	
	                $Day = $schedule.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
					$1Time = $schedule.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
					$2Time = $schedule.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
										
					$Day + "," + $1Time + "," + $2Time | Out-File \\gremlin\d$\BKD_LOGS\Vault\VaultSched.csv -append
					
					}
					
					
					Import-Csv \\gremlin\d$\BKD_LOGS\Vault\VaultSched.csv | export-csv \\gremlin\d$\BKD_LOGS\Vault\VaultSchedRpt.csv -notype
					
					
					
					Import-Csv  \\gremlin\d$\BKD_LOGS\Vault\VaultSchedRpt.csv |
	 where-Object {$_.Day -eq $tdsdate -and $_.Time -ne "000:00:00"} | select Vault,Day,Time | format-table
	