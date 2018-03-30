
Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\AllImages.txt

$DlyBupDt = (get-date (get-date).AddDays(-1) -f M/d/yyyy)

$Pol1 = gc \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.csv | 
	Where-Object {$_-notmatch "Policy,Status" -and $_-notmatch ",0" -and $_-notmatch "Vault_" -and $_-notmatch "CATALOG"}



# The -Policy represents the actual policy. The -d represents the date and -e represents the end date. For the purpose of this script, we
# are getting only the previous day. Therefore, the -d and -e date are the same day.

foreach ($Pol2 in $Pol1)

	{
	$Policy = $Pol2.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
	$image = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -policy $Policy -d $DlyBupDt -e $DlyBupDt |
	   Where-Object {$_-match "IMAGE"}  | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\AllImages.txt -append
	
			
						
						
				}
   
   
