$ghost = gc env:computername
$YestDay = (get-date (get-date).AddDays(-1 ) -f yyMMdd)
$logLoc = "E:\logfiles"
$Target = "\\vfs02\Transfers\IISLOGS"


$iiss = Get-WmiObject -Namespace "root\webadministration" -Class site |
where {$_.ServerAutoStart -eq "True"}
	
	foreach ($Wsite in $iiss)
		{
			$name = $wsite.name
	        $id = $wsite.id
			#$name + " " + $id
	  New-Item $Target\$name -type directory		
# Get yesterday's log. This is what we want to use
# if we miss days, use the get all logs section
	#logs = Get-ChildItem $logloc\W3SVC$id |
		      #here {$_.name -match "u_ex"+$YestDay } 
              
 # Get all logs - Rem out after running
     $logs = Get-ChildItem $logloc\W3SVC$id |
		      where {$_.name -match "u_ex"} 
			  
			 
			  foreach ($IIsfile in $logs)
			  
			  	{
				    $filename = $IIsfile.name -replace  $IISfile.extension, ""
					$newname = "${FileName}_${ghost}.log"
					Rename-Item -Path $IIsfile.fullname -NewName $Newname
					Move-Item $logloc\W3SVC$id\$Newname $Target\$name
			  
			  
			    }
			  
			  			  
		
			  
		      
	}