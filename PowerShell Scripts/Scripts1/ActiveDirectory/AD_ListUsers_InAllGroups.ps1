Remove-Item c:\DomainGroups.txt
Remove-Item c:\GroupMembers.txt

Get-QADGroup | select name  | Out-File c:\DomainGroups.txt -append
#foreach {$_-replace $_, "`"$_`""} |
#foreach {$_-replace " ",""} |
#foreach {$_-replace "\}",""}

$Ggroups = gc c:\DomainGroups.txt |
Where-Object {$_-ne "" -and $_-notmatch "Name" -and $_-notmatch "----"} 

foreach ($groups in $Ggroups)

	{
	
		$Gs = Get-QADGroupMember $groups | select name |
		foreach {$_-replace "$_","`"$groups,$_`""} |
		foreach {$_-replace "@\{Name=",""} |
        foreach {$_-replace "\}",""} |
		Out-File c:\GroupMembers.txt -append
	
	}


#Get-QADGroupMember "G_Web_RightFax" | select name