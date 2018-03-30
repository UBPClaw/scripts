


$Gfiles = Get-ChildItem \\dakota\user | where {$_.PsIsContainer} | select-object name | Out-File c:\Temp\DakotaUsage\User.txt -append

$Gfiles2 = gc c:\Temp\DakotaUsage\user.txt | select -Skip 3



foreach ($line in $Gfiles2)
	
{
$tEST = Get-ChildItem \\dakota\user\$line -Recurse  | Measure-Object -property length -sum  
"{0:N2}" -f ($tEST.sum / 1MB) + "@" + $line | Out-File c:\Temp\DakotaUsage\UserOut.txt -Append
}