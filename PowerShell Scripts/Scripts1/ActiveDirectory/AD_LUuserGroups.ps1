# ==================================================================================================================
# \\\malibu\it\NTServers\Scripts\ActiveDirectory\AD_LUuserGroups.ps1
# Date 11/07/2008
# Bryan K. DeBrun
# This script will return the group membership of the user entered in the user variable below.
# As of 11/07/2008, this script will work only for those in the All,Users,Users OU. I need to make it work for
# Any OU.
# ==================================================================================================================
$UserName =Read-Host "Enter The Full Name Of The User"


$root=([adsi]"").distinguishedName
$ou=[adsi]("LDAP://OU=Users,OU=Users,OU=All,"+$root)


# here targetCN should be the exact CN for interested user in your AD
$user=$ou.psbase.children.find("cn=$UserName")
$groups = $user.memberof
foreach($group in $groups)
{
$strGroup = $group.split(',')[0]
$strGroup = $strGroup.split('=')[1]
$strGroup
}

$goaway =Read-Host "Press any key to exit"