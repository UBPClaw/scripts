

Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\OnOff.csv
Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\OnOffSite.csv

$Header = "Policy,BupDate,BupID,Sched"
$Header | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\OnOff.csv -append

$DlyBupDt = (get-date (get-date).AddDays(-1) -f M/d/yyyy)


$Pol1 = gc \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.csv | 
	Where-Object {$_-notmatch "Policy,Status" -and $_-notmatch ",0" -and $_-notmatch "Vault_" -and $_-notmatch "CATALOG"}
	
	foreach ($Pol2 in $Pol1)
	{
	 $Policy = $Pol2.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]


$Duplicate = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -policy $Policy -d $DlyBupDt |
    Where-Object {$_-match "IMAGE"}
	 
	 if ($Duplicate -eq $NULL)
	 	
			{
				 $BupID = "NA";$Sched = "NA" 
				 $Policy + "," + $DlyBupDt + "," + $BupID + "," + $Sched | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\OnOff.csv -append
				
				}
				
				Else
				{
				

     $BupID = $Duplicate.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[5]
	 $Sched = $Duplicate.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[10]
		 	
	$Policy + "," + $DlyBupDt + "," + $BupID + "," + $Sched | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\OnOff.csv -append
	
	}
	}
	
	import-Csv \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\OnOff.csv | Export-Csv \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\OnOffSite.csv -notype
	
	