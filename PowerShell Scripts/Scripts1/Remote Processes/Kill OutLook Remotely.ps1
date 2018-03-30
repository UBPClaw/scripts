
# Kill a process on a remote machine
$computer = "RB6203";
$processToKill = "OUTLOOK.exe";
$process = Get-WmiObject -Class Win32_Process -Filter "Name = '$processToKill'" -ComputerName $computer;
if($process -eq $null)
{	# If null then the process may not be running
	Write-Host -ForegroundColor Red "Couldn't get process $processToKill on $computer";
	sleep(10);
	exit;
}
else
{
	Write-Host "Attempting to Kill $processToKill on $computer";
}
# Kill the process and get exit status 0 = OK
$status = $process.InvokeMethod("Terminate", $null);
switch($status)
{
	0 { Write-Host -ForegroundColor Green "Killed $processToKill on $computer"};
	default { Write-Host -ForegroundColor Red "Error, couldn't kill $processToKill on $computer"};
 
}; 


Read more: More Powershell Nuggets | youdidwhatwithtsql.com http://www.youdidwhatwithtsql.com/more-powershell-nuggets/239#ixzz1PU8xxhaM