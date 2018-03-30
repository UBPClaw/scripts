Remove-Item c:\FGperms\FGperms.txt
Remove-Item c:\FGperms\Temp1.txt
Remove-Item c:\FGperms\Temp2.txt
remove-item c:\FGperms\FoldersTemp.txt
remove-item c:\FGperms\Folders.txt
Remove-Item c:\FGperms\final.txt
Remove-Item c:\FGperms\GroupsWPerms.txt
Remove-Item C:\FGperms\GroupsWPermsII.txt
Remove-Item C:\FGperms\GroupsWPermsIII.txt

$FServer = "Dakota"
$Share = "Dept"
$SFold = "Finance"

dir \\$FServer\$Share\$SFold | where-object {$_.PsIsContainer} | select name | Out-File  c:\FGperms\FoldersTemp.txt
gc c:\FGperms\FoldersTemp.txt | 
Where-Object {$_-ne ""} |
Where-Object {$_-notmatch "----"} |
Where-Object {$_-notmatch "Name"} | Out-File c:\FGperms\Folders.txt

$Folder = gc c:\FGperms\Folders.txt

foreach ($Target in $Folder)

{

$ThePerms  =  Get-Acl \\dakota\dept\finance\$Target | ForEach-Object {$_.access} | 
select-Object FileSystemRights,IdentityReference | Where-Object {$_.IdentityReference -notmatch "S-"} |
ForEach-Object {$_-replace $_.FileSystemRights,("$Target $_.FileSystemRights")} 
$ThePerms | format-custom FileSystemRights,IdentityReference |
Out-File c:\FGperms\GroupsWPerms.txt -append

}

$GWPfile = gc c:\FGperms\GroupsWPerms.txt |
ForEach-Object {$_-replace "@{FileSystemRights=",""} | 
ForEach-Object {$_-replace "Synchronize",""} |
ForEach-Object {$_-replace "; IdentityReference=",","} |
ForEach-Object {$_-replace ", ,",","} |
ForEach-Object {$_-replace "}.FileSystemRights",""} |
ForEach-Object {$_-replace "}",""} |
foreach-object {$_-replace " {2,}",","} |
foreach-object {$_-replace "BUILTIN\\",""} |
foreach-object {$_-replace "NT AUTHORITY\\",""} |
foreach-object {$_-replace "CreateFiles, ReadAndExecute,","CRE,"} |
foreach-object {$_-replace "ReadData, CreateFiles, ExecuteFile, ReadPermissions,","RCER,"} |
foreach-object {$_-replace "REPAIR\\",""} | out-file C:\FGperms\GroupsWPermsII.txt -append

$GWPfile2 = gc C:\FGperms\GroupsWPermsII.txt

foreach ($GWPline in $GWPfile2)

	{

		$Fold = $GWPline.split(",")[0]
		$Perm = $GWPline.split(",")[1]
		$Grup = $GWPline.split(",")[2]

		$FServer+ "," + $Share + "," + $SFold + "," + $Fold + "," + $Perm + "," + $Grup |	out-file  C:\FGperms\GroupsWPermsIII.txt -append
	}
#ForEach-Object {$_.split("\@")[0]}