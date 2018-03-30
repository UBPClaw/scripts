

$Gpolicy = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" 
$Pschedule = "Monthly"
Remove-Item C:\Workdir\Nbackup\Schedules\$Pschedule.txt


foreach ($policy in $Gpolicy)
{


#$policy = "NT_Prelude"
$GpolSched = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $policy  -L -label $Pschedule |
	Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday"-and
				  $_-notmatch "Week"} |
	
	ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
	ForEach-Object {$_-replace "   Monday","$policy,$Pschedule,Monday,"} |
	ForEach-Object {$_-replace "   Tuesday","$policy,$Pschedule,Tuesday,"} |
	ForEach-Object {$_-replace "   Wednesday","$policy,$Pschedule,Wednesday,"} |
	ForEach-Object {$_-replace "   Thursday","$policy,$Pschedule,Thursday,"} |
	ForEach-Object {$_-replace "   Friday","$policy,$Pschedule,Friday,"} |
	ForEach-Object {$_-replace "   Saturday","$policy,$Pschedule,Saturday,"} |
	ForEach-Object {$_-replace "   Sunday","$policy,$Pschedule,Sunday,"} |
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
	
	$GpolSched.count
	
	$policy + "1"
	
	
	
$GpolSched2 = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $policy  -L -label $Pschedule |
	Where-Object {$_-match "Schedule:" -or 
		          $_-match "Monday"  -or
				  $_-match "Tuesday" -or 
				  $_-match "Wednesday" -or
				  $_-match "Thursday" -or
				  $_-match "Friday" -or
				  $_-match "Saturday" -or
				  $_-match "Sunday" -and
				  $_-notmatch "Week"}|
	
	ForEach-Object {$_-replace "Schedule:          $Pschedule",""}  |
	ForEach-Object {$_-replace "   Monday","$policy,Monday,"} |
	ForEach-Object {$_-replace "   Tuesday","$policy,Tuesday,"} |
	ForEach-Object {$_-replace "   Wednesday","$policy,Wednesday,"} |
	ForEach-Object {$_-replace "   Thursday","$policy,Thursday,"} |
	ForEach-Object {$_-replace "   Friday","$policy,Friday,"} |
	ForEach-Object {$_-replace "   Saturday","$policy,Saturday,"} |
	ForEach-Object {$_-replace "   Sunday","$policy,Sunday,"} |
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1]}
	
	$policy + "2"
 
 	$GpolSched2.count
	



$i = 0
$gsked = $(while ($i -le $GpolSched.count) { $GpolSched[$i] + $GpolSched2[$i];$i++}) 


$gsked | Out-File C:\Workdir\Nbackup\Schedules\$Pschedule.txt -append
}
