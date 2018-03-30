#((Get-ChildItem \\dakota\dept\1stLevel -Recurse) |Measure-Object -Sum Length).sum



$Gfiles = Get-ChildItem \\dakota\dept\1stLevel | where {$_.PsIsContainer} | select-object name | Out-File c:\Temp\DakotaUsage\getreal.txt -append

$Gfiles2 = gc c:\Temp\DakotaUsage\getreal.txt | select -Skip 3



foreach ($line in $Gfiles2)
	
{
$tEST = Get-ChildItem \\dakota\dept\1stLevel\$line -Recurse  | Measure-Object -property length -sum  
"{0:N2}" -f ($tEST.sum / 1MB) + "," + $line | Out-File c:\Temp\DakotaUsage\getrealOut.txt -Append
}