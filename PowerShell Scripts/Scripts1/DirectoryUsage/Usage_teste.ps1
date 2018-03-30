
$Gfiles = Get-ChildItem C:\Temp | where {$_.PsIsContainer} | select-object name | Out-File c:\Temp\Usage_Test.txt -append

$Gfiles2 = gc c:\Temp\Usage_Test.txt | select -Skip 3



foreach ($line in $Gfiles2)
	
{
$tEST = Get-ChildItem c:\Temp\$line -Recurse  | Measure-Object -property length -sum
#$tEST.Sum / 1MB #+  "  " + $line
#$tEST.sum / 1MB + "@" + $line | Out-File c:\Temp\Usage_TestOut.txt -Append
"{0:N2}" -f ($tEST.sum / 1MB) + "@" + $line | Out-File c:\Temp\Usage_TestOut.txt -Append

}