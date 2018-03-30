# ==========================================================================================================
# 
# Microsoft PowerShell File 
# 
# NAME: Get-Emp4SQL.ps1
# 
# DATE: 10-11-07
# 
# COMMENT: The script exports out Full Name, First Name, Last Name, Email Address, sam account id, Title, Phone, Office, and Department for 
# Mitchell1 Employees to a csv file. Requires the Quest Snapin to be installed on the pc running the script
# ==========================================================================================================

Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

# Add the Quest Snapin to use the QAD commandlets
add-pssnapin Quest.ActiveRoles.ADManagement

# Change Log Path to your needs
$Userlog = "C:\temp\UsersOU4sp.csv"
$Managerlog = "C:\temp\ManagersOU4sp.csv"
$RemoteUserlog = "C:\temp\RemoteUsersOU4sp.csv"
$RightFaxExcludelog = "C:\temp\RightfaxexcludeOU4sp.csv"
$Adminlog = "C:\temp\AdminOU4sp.csv"
$log = "\\malibu\it\SQL_Import_Files\M1EmpSearch_Info.csv"
$pttLog = "\\sod-fil-01-pv\Production\ProjectTimeTracking\M1Emp.csv"
$rlog = "\\malibu\it\SQL_Import_Files\RepairSalesReps_Info.csv"
$glog = "\\malibu\it\SQL_Import_Files\Distribution_Group_Info.csv"

# Get the Full Name, First Name, Last Name, External Email Address for each User in Users OU
Get-QADUser -ou "corp.mitchellrepair.com/all/users/users" | select-object Name,givenname,sn,mail,samaccountname,title,PhoneNumber,Office,Department | export-csv $Userlog -notype

# Get the Full Name, First Name, Last Name, External Email Address for each User in Managers OU
Get-QADUser -ou "corp.mitchellrepair.com/all/users/managers" | select-object Name,givenname,sn,mail,samaccountname,title,PhoneNumber,Office,Department | export-csv $Managerlog -notype

# Get the Full Name, First Name, Last Name, External Email Address for each User in the RemoteUsers OU
Get-QADUser -ou "corp.mitchellrepair.com/all/users/remoteusers" | select-object Name,givenname,sn,mail,samaccountname,title,PhoneNumber,Office,Department | export-csv $RemoteUserlog -notype
 	
# Get the Full Name, First Name, Last Name, External Email Address for each User in RightFax Exclude OU
Get-QADUser -ou "corp.mitchellrepair.com/all/users/rightfax exclude" | select-object Name,givenname,sn,mail,samaccountname,title,PhoneNumber,Office,Department | export-csv $RightFaxExcludelog -notype

# Get the Full Name, First Name, Last Name, External Email Address for each User in Users OU in the Admin OU
Get-QADUser -ou corp.mitchellrepair.com/all/admin/users | select-object Name,givenname,sn,mail,samaccountname,title,PhoneNumber,Office,Department | export-csv $Adminlog -notype

# Combine all csv files into 1
import-csv $Userlog,$Managerlog,$RemoteUserlog,$RightFaxExcludelog,$Adminlog | export-csv $log -notype

# remove temp csv files
remove-item $Userlog,$Managerlog,$RemoteUserlog,$RightFaxExcludelog,$Adminlog

# Get the Full Name, First Name, Last Name, External Email Address for each Contact in Repair Sales Reps OU
get-QADObject -SearchRoot 'corp.mitchellrepair.com/all/contacts/repair sales reps' -Type Contact -IncludedProperties givenname,sn,mail | select-object Name,givenname,sn,mail | export-csv $rlog -notype

# Get the Full Name and Email Address for each Distribution Group
get-QADObject -SearchRoot 'corp.mitchellrepair.com/Users/Distribution Lists' -Type Group -IncludedProperties mail | select-object Name,mail | export-csv $glog -notype

# copy file to sod-fil-01-pv for Project Time Tracking
copy-item -path $log -destination $pttLog
