


$Gpolicy = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" 
$Pschedule = "Daily"

Remove-Item \\gremlin\d$\BKD_LOGS\BackupPaths\NBuSU_$Pschedule.txt
            
#$Gpolicy = "NT_Prelude"
foreach ($policy in $Gpolicy)
{



$GpolSched = @(psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $policy  -L -label $Pschedule |
	Where-Object {$_-match "Schedule:"} |
	ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule,"} ) 
	$GpolSched.count
	$GpolSched + " " + "For Schedule"
	
$GpolRes = @(psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplsched" $policy  -L -label $Pschedule |
	Where-Object {$_-match "Residence:"} |
	ForEach-Object {$_-replace "  Residence:       ",""} |
	ForEach-Object {$_-replace "\(specific",""} |
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]})
	$GpolRes.count
	$GpolRes + " " + "For Storage Unit"
	

$i = 0

$gsked = $(while ($i -le $GpolSched.count) { $GpolSched[$i] + $GpolRes[$i];$i++}) 


$gsked | Out-File \\gremlin\d$\BKD_LOGS\BackupPaths\NBuSU_$Pschedule.txt -append
}


