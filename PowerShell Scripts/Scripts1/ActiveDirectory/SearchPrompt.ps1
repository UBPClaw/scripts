$Search4 =Read-Host "1 Search by Network ID and 2 Search by Name"

if ($Search4 -eq 1)
{
$look4me =Read-Host "Enter Network ID"
$domain = [adsi] "LDAP://dc=corp,dc=mitchellrepair,dc=com"
$searcher = New-Object System.DirectoryServices.DirectorySearcher $domain
$searcher.filter = "(&(objectclass=user)(SamAccountName=$look4me))"
$userresult = $searcher.FindOne()
$user = $userresult.getdirectoryEntry()
"Network ID(" + $user.get("SAMACCOUNTNAME")+")" + "DISPLAY NAME" + "(" + $user.get("DISPLAYNAME") +")"
 $goaway =Read-Host "Press any key to exit"
}

else

{
$look4me =Read-Host "Enter Persons First and Last Name"
$searcher = New-Object System.DirectoryServices.DirectorySearcher $domain
$searcher.filter = "(&(objectclass=user)(displayname=$look4me))"
$userresult = $searcher.FindOne()
$user = $userresult.getdirectoryEntry()
"Network ID(" + $user.get("SAMACCOUNTNAME")+")" + "DISPLAY NAME" + "(" + $user.get("DISPLAYNAME") +")"
 $goaway =Read-Host "Press any key to exit"
}
