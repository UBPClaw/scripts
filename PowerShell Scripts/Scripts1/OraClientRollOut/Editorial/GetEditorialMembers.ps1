# The Mitchell Domain    [adsi] "LDAP://dc=corp;dc=mitchellrepair;dc=com"
remove-Item C:\Workdir\Meps\EditorialDeptUID.txt
$group = [adsi] "LDAP://cn=editorial dept,cn=distribution lists,cn=users,dc=corp,dc=mitchellrepair,dc=com" 
$group1 = $group.member | foreach {$_.split("=",[StringSplitOptions]::RemoveEmptyEntries)[1]} 
$group2 = $group1 | foreach {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]} 

foreach ($entry in $group2) 
{
$domain = [adsi] "LDAP://dc=corp,dc=mitchellrepair,dc=com"
$searcher = New-Object System.DirectoryServices.DirectorySearcher $domain
$searcher.filter = "(&(objectclass=user)(DisplayName=$entry))"
$userresult = $searcher.FindOne()
$user = $userresult.getdirectoryEntry()
$user.get("SAMACCOUNTNAME")| Out-File C:\Workdir\Meps\EditorialDeptUID.txt -Append -encoding ASCII

#To see a more fancy output, enable the line below.
#"Network ID(" + $user.get("SAMACCOUNTNAME")+")" + "DISPLAY NAME" + "(" + $user.get("DISPLAYNAME") +")"
}








