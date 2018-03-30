Function move-iislogs ($Source,$Target) {
$Moving1 = $Source 
$Moving2 = $Target
    $YestDay = (get-date (get-date).AddDays(-1) -f yyMMdd)
 	$logs = Get-ChildItem ($Source) |
		where {$_.name -match "u_ex"+$YestDay } 
		$logs 
		foreach ($File in $Logs)
			{
			if ($File -eq $NUL)
            
			{
             write-host "No files!"
			}
			else
			{
				Move-Item $Moving1\$File $Moving2
				#$Moving1 + " " + $File + " " + $Moving2 
                #write-host "There are files"
				}
				}
		
}

$ghost = gc env:computername
$SK5 = "W3SVC3"
$OD5 = "W3SVC2"


$SK5Source = "E:\Logfiles\$SK5"
$SK5Target = "\\vfs02\Transfers\IISLOGS\$ghost\$SK5"

$OD5Source = "E:\Logfiles\$OD5"
$OD5Target = "\\vfs02\Transfers\IISLOGS\$ghost\$OD5"




move-iislogs $SK5Source $SK5Target 

move-iislogs $OD5Source $OD5Target 