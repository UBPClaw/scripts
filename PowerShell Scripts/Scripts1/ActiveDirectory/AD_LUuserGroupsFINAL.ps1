# START
# Function
# Enumerate users in groups and nested groups

function get-NestedMembers ($group){  

# The the object is not a group or if the group is out of the container
# Replace what would be the members of the group with the text "Unable to Enumberate Users"
# We will have to handle these minimul occurances outside of this script.
if ($group.objectclass -eq $NUL)

	{
		"Unable to Enumerate Users"
		return
	}
  if ($group.objectclass[1] -eq 'group') {  
        write-verbose "Group $($group.cn)"  
    $Group.member |% {  
      $de = new-object directoryservices.directoryentry("LDAP://$_")  
      if ($de.objectclass[1] -eq 'group') {  
        get-NestedMembers $de  
      }  
      Else {  
        $de.DisplayName  
      }  
    }  
  } 
  Else { 
    Throw "$group is not a group" 
  }  
} 

# END
# Function

# START
# Function
# Enumerate users in local groups


function get-members{
param($groupName)

Get-QADGroupMember -Identity $groupName | foreach {
if($_.type -eq "user") {$_.name}
elseif($_.type -eq "group") {$_.name; get-members -groupName $_.CanonicalName}

}
}

# END
# Function
# get-members "Dakota\Administrators"


# *********************************************** END FUNCTIONS ****************************************************

# Remove the final file created by this script prior to executing again.
	remove-item \\malibu\IT\SOX\SOX_Perm_Audit.txt

# ******************* Begin Enumerating Target folders getting group names and group permissions *************************

# Set Variables. The variables listed below are determined by the actual file server, share and folder(s) that are needed
# for gathering permissions. 

	$FServer = "Dakota"
	$Share = "Dept"
	$SFold = "SRFin"
	$DC = "H1"

# Get a list of Top level folders at the location detailed in the variables section above. 
# Scrape away unwanted text and then output to a temp file.

	dir \\$FServer\$Share\$SFold | where-object {$_.PsIsContainer} | select name | Out-File  c:\FGperms\FoldersTemp.txt
	gc c:\FGperms\FoldersTemp.txt | 
	Where-Object {$_-ne ""} |
	Where-Object {$_-notmatch "----"} |
	Where-Object {$_-notmatch "Name"} | Out-File \\malibu\IT\SOX\Folders.txt
	
# Input the tempfolder created above, use the Get-Acl cmdlet to retreive the groups and permissons 
# Scrape away unwanted text and then output to a temp file.

	$Folder = gc \\malibu\IT\SOX\Folders.txt

	foreach ($Target in $Folder)
		{
			$ThePerms  =  Get-Acl \\$FServer\$Share\$SFold\$Target | ForEach-Object {$_.access} | 
			select-Object FileSystemRights,IdentityReference | Where-Object {$_.IdentityReference -notmatch "S-"} |
			ForEach-Object {$_-replace $_.FileSystemRights,("$Target $_.FileSystemRights")} 
			$ThePerms | format-custom FileSystemRights,IdentityReference |
			Out-File \\malibu\IT\SOX\GroupsWPerms.txt -append
		}
		
# Input the temp file created above, scrape away unwanted text, make changes to text
# and then output to a temp file

	$GWPfile = gc \\malibu\IT\SOX\GroupsWPerms.txt |
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
	foreach-object {$_-replace "DeleteSubdirectoriesAndFiles, Write, ReadAndExecute, ChangePermissions, TakeOwnership,","DWRECT,"} |
	foreach-object {$_-replace "REPAIR\\",""} | out-file \\malibu\IT\SOX\GroupsWPermsII.txt -append
	
# Input the last temp file, seperate the fields with a comma and then out put to a temp file.
# The temp file will include the file server name, the Share name, The Share folder name, the sub folder, the permissions and the group
	
	$GWPfile2 = gc \\malibu\IT\SOX\GroupsWPermsII.txt

	foreach ($GWPline in $GWPfile2)

		{
			$Fold = $GWPline.split(",")[0]
			$Perm = $GWPline.split(",")[1]
			$Grup = $GWPline.split(",")[2]
			$FServer+ "," + $Share + "," + $SFold + "," + $Fold + "," + $Perm + "," + $Grup |	
			out-file  \\malibu\IT\SOX\GroupsWPermsIII.txt -append
		}



# ******************************* INPUT Text File and Spit out all members of the group ***********************************

# Input the temp file created above, enumerate the members for each group
# This section will use the functions created at the beginning of this script

 $Gtest = gc \\malibu\IT\SOX\GroupsWPermsIII.txt
	foreach ($DaGroup in $Gtest)

		{
			$FServer = $DaGroup.split(",")[0]
			$Share = $DaGroup.split(",")[1]
			$SFold = $DaGroup.split(",")[2]
			$Gfold = $DaGroup.split(",")[3]
			$Gperm = $DaGroup.split(",")[4]
			$Ggrp = $DaGroup.split(",")[5]
		
			if ($Ggrp -eq "Administrators")
			{
				#Use the function created above to get the members of this local group.
				$GLocMembs = get-members "$FServer\Administrators" 
				foreach ($Lmember in $GLocMembs)
				{
					$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + $Lmember + "," + $Gperm | 
					Out-File \\malibu\IT\SOX\SOX_Perm_Audit.txt -append
				}
			}
				
			elseif ($Ggrp -eq "Domain Admins")
			
			{
				#Use the function created above to get the members of this local group
				$GLocMembs = get-members "$DC\Domain Admins" 
				foreach ($Lmember in $GLocMembs)
				{
					$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + $Lmember + "," + $Gperm | 
					Out-File \\malibu\IT\SOX\SOX_Perm_Audit.txt -append
				}
			}
				
			elseif ($Ggrp -eq "Authenticated Users")
			
				{
					$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + "Any Domain Account" + "," + $Gperm | 
					Out-File \\malibu\IT\SOX\SOX_Perm_Audit.txt -append
				}
							
			else
			
				{
					# Use the function created above to get the members of the AD global groups.
					$group = new-object directoryservices.directoryentry("LDAP://cn=$Ggrp,ou=Groups,ou=users,ou=all,dc=corp,dc=mitchellrepair,dc=com") 
					$1 = get-nestedMembers $group
					foreach ($deal in $1)
						{
							$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + $deal + "," + $Gperm | 
							Out-File \\malibu\IT\SOX\SOX_Perm_Audit.txt -append
						}
				}
							
		}	
				

# Cleanup - Remove all the temp files created above.

Remove-Item \\malibu\IT\SOX\FGperms.txt
remove-item \\malibu\IT\SOX\FoldersTemp.txt
remove-item \\malibu\IT\SOX\Folders.txt
Remove-Item \\malibu\IT\SOX\final.txt
Remove-Item \\malibu\IT\SOX\GroupsWPerms.txt
Remove-Item \\malibu\IT\SOX\GroupsWPermsII.txt
Remove-Item \\malibu\IT\SOX\GroupsWPermsIII.txt