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

# Update Ranger share - Open Computer Manager from workstation and connect to "RANGER">System Tools>Shared Folders>Shares>Change folder path for "Data_Next" to "C:\vol\ranger_dp_XXXX\dp\DataProcess\Data" > Administrators Full; others read>Finish
remove-nacifsshare Data_Current -controller $ranger
$Date = get-date -Format y
add-NaCifsShare Data_Current /vol/ranger_dp_odd/dp/DataProcess/Data -comment "$Date" -controller $ranger

# -- WAIT: (Til data has been approved by QA/Editoral)
write-host "Phase 2 complete." 