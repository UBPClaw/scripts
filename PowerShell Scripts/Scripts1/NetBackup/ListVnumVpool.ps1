$poolNum = psexec \\gremlin "D:\program files\veritas\volmgr\bin\vmpool" -list_all |
	Where-Object { $_-match "pool number" } |
	ForEach-Object {$_-replace "pool number:  ",""}
	$poolNum.count
	
	
	

	$poolname = psexec \\gremlin "D:\program files\veritas\volmgr\bin\vmpool" -list_all |
	Where-Object { $_-match "pool name" } |
	ForEach-Object {$_-replace "pool name:  ",""}
	
	               



$i = 0 
Write-Host   Pool Number and Name
Write-Host "--------------------------"
 $(while ($i -le $poolNum.count) {$poolNum[$i]+" "+$poolname[$i];$i++}) 
 
 
 $goaway =Read-Host "Press any key to exit"


	