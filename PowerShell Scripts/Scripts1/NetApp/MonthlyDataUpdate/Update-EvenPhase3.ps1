#Requires -Version 2.0

#*******************************************************************************
# Phase 3 for Even Monthly Data Update
# Sync ranger_dp_even volume to vfs02_even_fc volume in Hosting
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
$m35 = connect-nacontroller -name m35

#Restrict the volume
Set-NaVol vfs02_even_fc -Restricted -Controller $m35

# Initialize the SnapMirror
Invoke-NaSnapmirrorInitialize -Source M45:ranger_dp_even -Destination M35:vfs02_even_fc -Controller $m35

# -- WAIT: (Takes about 1 hour, to check status connect to m35 and run "get-nasnapmirror M35:vfs02_even_fc -Controller $m35")
write-host "Phase 3 complete, check status in 1 hour if State is Snapmirrored go to the next phase. SSH to M35 and run snapmirror status to check."
