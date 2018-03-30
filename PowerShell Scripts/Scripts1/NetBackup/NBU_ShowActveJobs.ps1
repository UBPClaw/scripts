Remove-Item \\gremlin\d$\BKD_LOGS\NBULOGS\ActiveJobs.txt
$GactiveJobs = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpdbjobs" -ignore_parent_jobs -noheader |
    where-object {$_-match "Active" -and $_-notmatch "Done"}  | 
	ForEach-Object {$_-replace "  root","root"}|
	foreach-object {$_ -replace " {1,}",","}|
	foreach-object {$_ -replace "root,",""}|
	foreach-object {$_ -replace ",AM"," AM"}|
	foreach-object {$_ -replace ",PM"," PM"}|
	foreach-object {$_ -replace "Active,",""} |
	Foreach-object {$_+"`n"} 
		
	foreach ($object in $GactiveJobs)
	{
		for ($i =0;$i -lt 8;$i++) 
		{
	 		$temptype = $object.split(",",[StringSplitOptions]::RemoveEmptyEntries)[$i]
			#$Policy = $object.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
			$type = $type + $temptype
			
		}
		$type
	}
	
	
#$i = 0
#$gPolicyInfo = $(while ($i -le $gPolicySched.count) 
	#{$gPolicyName[$i] +  "," + 
		#$gPolicyMedS[$i] + "," + 
		#$gPolicySched[$i] + "," + 
		#$gPolicyClient[$i] + "," + 
		#$gPolicyStartD[$i] + "," + 
		#$gPolicyStartT[$i] + "," + 
		#$gPolicyStartAP[$i] + "," + 
		#$gPolicyEndD[$i] + "," + 
		#$gPolicyEndT[$i] + "," + 
		#$gPolicyEndAP[$i] + "," + 
		#$gPolicySize[$i] + "," + 
	#$gPolicyElapsed[$i];$i++})