
# This script gets the Storage unit used by each policy for each schedule; Daily, weekly, Monthly, and even the catalog which is
# labled as FULL

Remove-Item \\gremlin\d$\BKD_LOGS\StorageUnits\DSSU.txt
$Gpolicy = bppllist

foreach ($Policy in $Gpolicy)

{
		
		$GpolSched = bpplsched $Policy  -L -label Daily |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
					
									
		$GpolRes = bpplsched $policy  -L -label Daily |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
				foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				
				if ($GpolSched -ne $NUL)
				{
					$GpolSched  + "," + $GpolRes | Out-File \\gremlin\d$\BKD_LOGS\StorageUnits\DSSU.txt -append
				}	
					
		
		$GpolSched1 = bpplsched $Policy  -L -label Weekly |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
									
		
		
		
		$GpolRes1 = bpplsched $policy  -L -label Weekly |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
				foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				if ($GpolSched1 -ne $NUL)
				{
				$GpolSched1 + "," + $GpolRes1 | Out-File \\gremlin\d$\BKD_LOGS\StorageUnits\DSSU.txt -append	
		        }
				
		
		$GpolSched2 = bpplsched $Policy  -L -label Full |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
					
					
				
		$GpolRes2 = bpplsched $policy  -L -label Full |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
			 	foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				if ($GpolSched2 -ne $NUL)
				{
				$GpolSched2 + "," + $GpolRes2 | out-file \\gremlin\d$\BKD_LOGS\StorageUnits\DSSU.txt -append	
		        }
		
		$GpolSched3 = bpplsched $Policy  -L -label Monthly |
				Where-Object {$_-match "Schedule:"} |
	            ForEach-Object {$_-replace "Schedule:          $Pschedule","$policy,$Pschedule"}  
					
					
		
		
		$GpolRes3 = bpplsched $policy  -L -label Monthly |
				Where-Object {$_-match "Residence:"} |
				ForEach-Object {$_-replace "  Residence:       ",""} |
				ForEach-Object {$_-replace "\(specific",""} |
				foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
				foreach {$_-replace "Gremlin-Nova","TAPE"} |
				foreach {$_-replace "Nova-LTO2","TAPE"} |
				foreach {$_-replace "Gremlin-LTO2","TAPE"}
				
				if ($GpolSched3 -ne $NUL)
				{
				$GpolSched3 + "," + $GpolRes3 | Out-File \\gremlin\d$\BKD_LOGS\StorageUnits\DSSU.txt -append
				}
}