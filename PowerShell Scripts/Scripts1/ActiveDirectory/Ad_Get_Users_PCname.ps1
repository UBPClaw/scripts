# ==============================================================================================
# 
# Microsoft PowerShell File 
#
# Author: Bryan DeBrun
# 
# NAME: Ad_Get_Users_PCname.ps1
# 
# DATE: 7-21-09
# 
# COMMENT: Find users and then the pc they are logged in to.
#          This script is grabbing each meps user from a text file and searching either and OU or the entire domain for their computer.
#		   In any case, it will take a good chunk of time for the script to finish and especially if we search the entire domain.
#          
#          This script was designed to for MEPS install purposes. We identify MEPS users, their machine and then we deploy meps
#          using a script.
#          
# Requirements: ActiveRoles Management Shell for Active Directory from
#               http://www.quest.com/powershell/activeroles-server.aspx
#               \\malibu\applications\PowerGUI
# ==============================================================================================


remove-Item \\malibu\it\Meps\Meps213_43\Users\EditorialDeptUID.txt
Remove-Item c:\Meps_PC_Install.txt

$group = [adsi] "LDAP://cn=Editorial Dept,cn=distribution lists,cn=users,dc=corp,dc=mitchellrepair,dc=com" 
$group1 = $group.member | foreach {$_.split("=",[StringSplitOptions]::RemoveEmptyEntries)[1]} 
$group2 = $group1 | foreach {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]} 

foreach ($entry in $group2) 
{
$domain = [adsi] "LDAP://dc=corp,dc=mitchellrepair,dc=com"
$searcher = New-Object System.DirectoryServices.DirectorySearcher $domain
$searcher.filter = "(&(objectclass=user)(DisplayName=$entry))"
$userresult = $searcher.FindOne()
$user = $userresult.getdirectoryEntry()
$user.get("SAMACCOUNTNAME")| Out-File \\malibu\it\Meps\Meps213_43\Users\EditorialDeptUID.txt -Append -encoding ASCII


}

$MepsUsers = gc \\malibu\it\Meps\Meps213_43\Users\EditorialDeptUID.txt




foreach ($MepsUser in $MepsUsers)

{


Get-QADComputer -SearchRoot corp.mitchellrepair.com/all/workstations/editorial| 
foreach { Get-WmiObject -Class Win32_ComputerSystem -ComputerName $_.Name } | 
where { $_.UserName -eq "repair\$MepsUser" } | Format-Table Name, UserName | Out-File c:\Meps_PC_Install.txt -Append

}


