#Requires -Version 2.0

#*******************************************************************************
# Phase 1 for odd Monthly Data Update
# Create Clone of ranger_dp_fc volume
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

# Delete share \\ranger\Data_Previous though Computer Management
#remove-nacifsshare Data_Previous -controller $ranger

# Offline and Delete volume ranger_dp_previous in FilerView on M45
#Set-NaVol ranger_dp_previous -Controller $m45 -Offline | Remove-NaVol -Confirm:$false 

# Rename the either ranger_dp_odd to ranger_dp_previous
#Rename-NaVol ranger_dp_odd ranger_dp_previous -Controller $m45

# Create share \\ranger\Data_Previous pointing at C:\vol\ranger_dp_previous\dp\DataProcess\Data (Administrators Full Control, Everyone Read)
#add-NaCifsShare Data_Previous /vol/ranger_dp_previous/dp/DataProcess/Data -controller $ranger
# Removed Data_Previous By BTS on May 26 2015

# Offline and Delete volume ranger_dp_odd in FilerView on M45
Set-NaVol ranger_dp_odd -Controller $m45 -Offline | Remove-NaVol -Confirm:$false 

# Create Snapshot off of ranger_dp_fc
New-NaSnapshot ranger_dp_fc ranger_dp_odd -Controller $m45

# Create Flexclone using the snapshot ranger_dp_odd
New-NaVolClone -ParentVolume ranger_dp_fc  -CloneVolume ranger_dp_odd  -ParentSnapshot ranger_dp_odd -SpaceReserve none -Controller $m45

# Split Flexclone 
Start-NaVolCloneSplit ranger_dp_odd -Controller $m45 

# -- WAIT: (Takes about 16 hours, to check status connect to m45 and run "Get-NaVolCloneSplit ranger_dp_odd -Controller $m45")
write-host "Phase 1 complete, return tomorrow for next phase."