Remove-Item \\gremlin\d$\bkd_logs\StorageUnits\StorageUnits.txt

bpstulist -L |
	Where-Object {$_-match "Label:"} |
	ForEach-Object {$_-replace "Label:                ",""} |Sort-Object | Out-File \\gremlin\d$\bkd_logs\StorageUnits\StorageUnits.txt
	
	gc \\gremlin\d$\bkd_logs\StorageUnits\StorageUnits.txt