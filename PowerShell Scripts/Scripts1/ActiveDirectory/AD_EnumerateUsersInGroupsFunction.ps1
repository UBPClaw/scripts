# START
# Function
# Enumerate users in groups and nested groups

function get-NestedMembers ($group){  

if ($group.objectclass -eq $NUL)

	{
		"Unable to Enumberate Users"
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

#$Gtest = gc C:\FGperms\Groupstest.txt
 $Gtest = gc C:\FGperms\GroupsWPermsIII.txt

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
				
					$GLocMembs = get-members "Dakota\Administrators" 
					
						foreach ($Lmember in $GLocMembs)
						
							{
						
								$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + $Lmember + "," + $Gperm | Out-File C:\FGperms\GroupsTestII.txt -append
							}
								 
					
				}
				
				elseif ($Ggrp -eq "Domain Admins")
			
				{
				
					$GLocMembs = get-members "H1\Domain Admins" 
					
						foreach ($Lmember in $GLocMembs)
						
							{
						
								$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + $Lmember + "," + $Gperm | Out-File C:\FGperms\GroupsTestII.txt -append
							}
				}
				
				elseif ($Ggrp -eq "Authenticated Users")
			
				{
					
					$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + "Any Domain Account" + "," + $Gperm | Out-File C:\FGperms\GroupsTestII.txt -append
					
				}
				
				
								
		
			else
			
				{



					$group = new-object directoryservices.directoryentry("LDAP://cn=$Ggrp,ou=Groups,ou=users,ou=all,dc=corp,dc=mitchellrepair,dc=com") 
					$1 = get-nestedMembers $group
					
					
												
							

								foreach ($deal in $1)

									{
											
										$FServer + "," +  $Share + "," +$SFold + "," + $Gfold + "," + $Ggrp + "," + $deal + "," + $Gperm | Out-File C:\FGperms\GroupsTestII.txt -append
										#$Gfold + "," + $Ggrp + "," + $Gperm + "," + $Lmember
										#$Ggrp + "," + $deal | Out-File C:\FGperms\GroupsTestII.txt -append
										}
									}
							
				}	
	