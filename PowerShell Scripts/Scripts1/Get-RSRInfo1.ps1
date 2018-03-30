# =====================================================================================================
# 
# Microsoft PowerShell File 
# 
# NAME: Get-RSRInfo1.ps1
# 
# DATE: 7-10-07
# 
# COMMENT: The script exports out Full Name, First Name, Last Name, Email Address for Repair Sales Reps
#          to a csv file. Requires the Quest Snapin to be installed on the pc running the script
# =====================================================================================================

Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

# Add the Quest Snapin to use the QAD commandlets
add-pssnapin Quest.ActiveRoles.ADManagement

# Change Log Path to your needs
$log = "\\malibu\it\SQL_Import_Files\RepairSalesReps_Info.csv"

# Get the Full Name, First Name, Last Name, External Email Address for each Contact
get-QADObject -SearchRoot 'corp.mitchellrepair.com/all/contacts/repair sales reps' -Type Contact -IncludedProperties givenname,sn,mail | select-object Name,givenname,sn,mail | export-csv $log -notype
