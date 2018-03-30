
Remove-Item \\gremlin\d$\BKD_LOGS\VolumePools\*.txt

$GpoolNum = psexec \\gremlin "D:\program files\veritas\volmgr\bin\vmpool" -list_all |
	Where-Object {$_-match "pool number:"} |
	ForEach-Object {$_-replace "pool number:  ",""}
	
	foreach ($pnumber in $GpoolNum)
		{
			psexec \\gremlin "D:\program files\veritas\volmgr\bin\vmquery" -p $pnumber | 
			where-object {$_-match "media ID:"} |
			ForEach-Object {$_-replace "media ID:              ",""} |
			Out-File \\gremlin\d$\BKD_LOGS\VolumePools\$pnumber.txt
		}
		
	