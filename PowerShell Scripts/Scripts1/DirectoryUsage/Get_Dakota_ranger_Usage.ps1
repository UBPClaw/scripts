


$Gfiles = Get-ChildItem \\Dakota\dept | where {$_.PsIsContainer} | select-object name | Out-File c:\Temp\DakotaUsage\DakotaDept.txt -append

$Gfiles2 = gc c:\Temp\DakotaUsage\DakotaDept.txt | select -Skip 3



foreach ($line in $Gfiles2)
	
{
$tEST = Get-ChildItem \\Dakota\Dept\$line -Recurse  | Measure-Object -property length -sum  
"{0:N2}" -f ($tEST.sum / 1MB) + "@" + $line | Out-File c:\Temp\DakotaUsage\DakotaDept.txt -Append
}