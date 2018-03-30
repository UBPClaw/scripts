#Requires -Version 2.0

#*******************************************************************************
# Phase 2 for odd Monthly Data Update
# Add Clone of ranger_dp_fc volume to Ranger
# and update Data_Next Share
#*******************************************************************************

#Check for Needed Module
Function Get-MyModule 
{ 
Param([string]$name) 
if(-not(Get-Module -name $name)) 
{ 
if(Get-Module -ListAvailable | 
Where-Object { $_.name -eq $name }) 
{ 
Import-Module -Name $name 
$true 
} #end if module available then import 
else { $false } #module not available 
} # end if not module 
else { $true } #module already loaded 
} #end function get-MyModule 
get-mymodule -name "DataONTAP"

# Login to the NetApp Controllers
$m45 = connect-nacontroller -name m45
$ranger = connect-nacontroller -name m45 -Vfiler ranger

# Reduce size of the volume currently 420GB (350GB + 20%)
Set-NaVolSize ranger_dp_odd 420g -Controller $m45 

# If volume is not already assigned to the vfiler remove # from the next line
Set-NaVfilerStorage ranger -AddStorage ranger_dp_odd -Controller $m45

# Update Ranger share - Open Computer Manager from workstation and connect to "RANGER">System Tools>Shared Folders>Shares>Change folder path for "Data_Next" to "C:\vol\ranger_dp_XXXX\dp\DataProcess\Data" > Administrators Full; others read>Finish
remove-nacifsshare Data_Next -controller $ranger
sleep 10
$Date = get-date -Format y
add-NaCifsShare Data_Next /vol/ranger_dp_odd/dp/DataProcess/Data -comment "$Date" -controller $ranger

# Delete Snapshot that was created on ranger_dp_fc - Volumes>Snapshots>Manage>Select from 'View Volume' dropdown menu "Ranger_dp_fc">View button> Check "ranger_dp_XXXX">Delete - 
Remove-NaSnapshot ranger_dp_fc ranger_dp_odd -Controller $m45 -Confirm:$false

# -- WAIT: (Til data has been approved by QA/Editoral)
write-host "Phase 2 complete. Dont forget to check Data_Next mount on Anglia" 