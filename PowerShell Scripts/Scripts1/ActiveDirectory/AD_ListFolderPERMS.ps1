
Remove-Item c:\FGperms\FGperms.txt
Remove-Item c:\FGperms\Temp1.txt
Remove-Item c:\FGperms\Temp2.txt
remove-item c:\FGperms\FoldersTemp.txt
remove-item c:\FGperms\Folders.txt

dir \\dakota\dept\finance | where-object {$_.PsIsContainer} | select name | Out-File  c:\FGperms\FoldersTemp.txt
gc c:\FGperms\FoldersTemp.txt | 
Where-Object {$_-ne ""} |
Where-Object {$_-notmatch "----"} |
Where-Object {$_-notmatch "Name"} | Out-File c:\FGperms\Folders.txt

$Folder = gc c:\FGperms\Folders.txt

foreach ($Target in $Folder)

{

Get-Acl  \\dakota\dept\finance\$Target |

Select -expand access | Select-Object IdentityReference,FileSystemRights | where-object {$_.IdentityReference -notmatch "S-"} |
Out-File c:\FGperms\FGperms.txt -append

$GPerms = gc c:\FGperms\FGperms.txt |
Where-Object {$_-ne ""} |
Where-Object {$_-notmatch "-----------------"} |
Where-Object {$_-notmatch "IdentityReference"} |
Where-Object {$_-notmatch "FileSystemRights"} |
ForEach-Object {$_-replace ", Synchronize",""} |
ForEach-Object {$_-replace "                FullControl","FullControl"}|
ForEach-Object {$_.split("\\",[StringSplitOptions]::RemoveEmptyEntries)[1]} |
# This statement replaces the Second space only with a comma. So, if you have multiple spaces and want to replace all spaces with a comma,
# use this statement. If you simply try to replace space with a comma, you will get a comma for each space.
foreach-object {$_ -replace " {2,}",","} | Out-File c:\FGperms\Temp1.txt




$Temp1 = gc c:\FGperms\Temp1.txt

foreach ($Temp1Line in $Temp1)

	{
	
		   	$Grp = $Temp1Line.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
			$per = $Temp1Line.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
			
			$target + "," + $Grp + "," + $per | Out-File c:\FGperms\Temp2.txt -append
			
	}


$Temp2 = gc c:\FGperms\Temp2.txt |

Where-Object {$_-notmatch "Authenticated Users"} |
Where-Object {$_-notmatch "Administrators"} |
Where-Object {$_-notmatch "Domain Admins"}

foreach ($Temp2Line in $Temp2)

	{
	
		    $T2Trg = $Temp2Line.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
			$T2Grp = $Temp2Line.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
			$T2per = $Temp2Line.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
			
		
			
									
					$group = [adsi] "LDAP://cn=$T2Grp,ou=Groups,ou=users,ou=all,dc=corp,dc=mitchellrepair,dc=com" 
					$group1 = $group.member | foreach {$_.split("=",[StringSplitOptions]::RemoveEmptyEntries)[1]} 
					$group2 = $group1 | foreach {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]} | Sort-Object
					
												
		 		$T2Grp + "," + $group2 | Out-File c:\FGperms\final.txt -append
	
	}	
}