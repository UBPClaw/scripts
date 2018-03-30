#$tdsdate = Get-Date -Format dddd

$1 = Get-ChildItem -Name c:\test

foreach ($File in $1)
	{
		$2 = Import-Csv c:\test\$File |
		
		    select Policy,Client,SchedLbl,BupDate,KBS |
				where-object {$_.Policy -eq "NT_CIS_Before_Dayend_DD1"}
				
				#foreach ($Thing in $2)
				#{
				
			 #"{0,-20} {1,-10} {2,-10} {3,-10} {4,-10}" -f  $Thing.Policy, $Thing.Client, $Thing.SchedLbl, $Thing.BupDate, $Thing.KBS
			  
			  $2 | Format-Table -AutoSize
			  }
			#}
			
			