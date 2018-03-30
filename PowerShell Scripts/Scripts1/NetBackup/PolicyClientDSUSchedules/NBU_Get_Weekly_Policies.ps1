# This script identifies the policies with a weekly schedule and those without a weekly schedule.

Remove-Item \\gremlin\d$\BKD_LOGS\Policies\WeeklyPols.txt
$Gpolicy = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist"

foreach ($policy in $Gpolicy)
{
$pout = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" $policy -L  |
	Where-Object {$_-match "Weekly"} |
	Where-Object {$_-notmatch "Residence:"} |
	ForEach-Object {$_-replace "Schedule:          ",","}
		
		# Find the policies without a weekly schedule.
		if ($pout -eq $NULL)
			{
				  $policy | Out-File \\gremlin\d$\BKD_LOGS\Policies\Non_WeeklyPols.txt -append
				}
				#Find the policies with a weekly schedule.
				else
					{
						$policy  | Out-File \\gremlin\d$\BKD_LOGS\Policies\WeeklyPols.txt -append
						}
}
	                                 