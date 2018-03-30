# =====================================================================================================
# 
# Microsoft PowerShell File 
# 
# NAME: Get-GroupInfo.ps1
# 
# DATE: 7-11-07
# 
# COMMENT: The script exports out Full Name and Email Address for Distribution Groups
#          to a csv file. Requires the Quest Snapin to be installed on the pc running the script
# =====================================================================================================

Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

# Add the Quest Snapin to use the QAD commandlets
add-pssnapin Quest.ActiveRoles.ADManagement

# Change Log Path to your needs
$log = "\\malibu\it\SQL_Import_Files\Distribution_Group_Info.csv"

# Get the Full Name and Email Address for each Distribution Group
get-QADObject -SearchRoot 'corp.mitchellrepair.com/Users/Distribution Lists' -Type Group -IncludedProperties mail | select-object Name,mail | export-csv $log -notype
