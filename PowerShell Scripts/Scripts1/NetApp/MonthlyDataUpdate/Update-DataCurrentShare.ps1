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

# Delete share \\ranger\Data_Current though Computer Management
remove-nacifsshare Data_Current -controller $ranger

# Update Ranger share - Open Computer Manager from workstation and connect to "RANGER">System Tools>Shared Folders>Shares>Change folder path for "Data_Next" to "C:\vol\ranger_dp_XXXX\dp\DataProcess\Data" > Administrators Full; others read>Finish
$Date = get-date -Format y
add-NaCifsShare Data_Current /vol/ranger_dp_even/dp/DataProcess/Data -comment "$Date" -controller $ranger


# -- WAIT: (Til data has been approved by QA/Editoral)
write-host "Dont forget to check Data_Current mount on Anglia" 