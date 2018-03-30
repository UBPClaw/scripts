$dadateOut = (get-date (get-date).AddDays(-1) -f M-d-yyyy)

$StU = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpstulist" -L |
	Where-Object {$_-match "Label:"} |
	ForEach-Object {$_-replace "Label:                ",""}


foreach ($Sunit in $StU)
{

$1 = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpstulist" -label $Sunit -L |
	foreach { $_.split(":",[StringSplitOptions]::RemoveEmptyEntries)[1]} |
	foreach { $_-replace ' {2,}',''} |
	foreach { $_-replace '"',""} 
	
		$2 = ""
		foreach ($item in $1)
		{
	
			$2 = $2 + $item + "," 
	
		}
		$2.TrimStart(",").TrimEnd(",") | Out-File \\gremlin\d$\bkd_logs\StorageUnits\StorageUnitProperties_$dadateOut.txt -append
	}
	
