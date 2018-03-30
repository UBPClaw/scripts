#Run from a system that has a drive mapped to Q:\dakota\dept

$TheDirectory = "\\dakota\dept\1stlevel"

Get-ChildItem $TheDirectory | where {$_.PsIsContainer} | select-object name | Out-File C:\Temp\DakotaUsage\1stLevel.txt -Encoding unicode
 gc C:\Temp\DakotaUsage\1stlevel.txt | select -Skip 3 | Out-File C:\Temp\DakotaUsage\1stlevelII.txt -Encoding unicode
# gc C:\Temp\DakotaUsage\DeptUsage.txt | Where-Object {$_ -ne'NULL'} | Out-File C:\Temp\DakotaUsage\DeptUsageFinal.txt -Append 

# Remove-Item C:\Temp\DakotaUsage\DeptUsage.txt
 
 $GetDept = gc C:\Temp\DakotaUsage\1stlevelII.txt  
 
 foreach ($FolderDept in $GetDept)
		
		{
		
			
			
			#$ScanDirectory =  Get-ChildItem $TheDirectory\$FolderDept -Recurse| Measure-Object -property length -sum
			#"{0:N2}" -f ($ScanDirectory.sum / 1MB) + " MB" 
			#$FinalOut = $FolderDept + "  " + $ScanDirectory | Out-File c:\Temp\DakotaUsage\Didthiswork.txt
			#$FolderDept = "Doug"
			#diruse /m \\dakota\dept\1stlevel\$FolderDept | where-object {$_ -notmatch "Size" -and $_-notmatch "SUB-TOTAL"}|
			#foreach {$_ -replace "TOTAL:",""} |out-File C:\Temp\DakotaUsage\DepusageReport.txt -append
			diruse /m "\\dakota\dept\1stlevel\$FolderDept" |out-File C:\Temp\DakotaUsage\DepusageReport.txt -append
			
			$FolderDept
			}
			
			