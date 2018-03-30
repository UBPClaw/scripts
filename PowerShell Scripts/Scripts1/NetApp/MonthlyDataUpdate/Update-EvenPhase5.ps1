#Requires -Version 2.0

#*******************************************************************************
# Phase 5 for Even Monthly Data Update
# Sync ranger_dp_even volume to svfs01_even volume at Colo
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

# Login to the NetApp Controller
$g35 = connect-nacontroller -name g35

# Restrict volume 
Set-NaVol svfs01_even -Restricted -Controller $G35

# Initialize the Volume
Invoke-NaSnapmirrorInitialize -Source nam45-nag35:ranger_dp_even -Destination G35:svfs01_even -Controller $g35

# -- WAIT: (Takes about 9 hours, to check status connect to g35 and run "get-nasnapmirror G35:svfs01_even -Controller $g35")
write-host "Phase 5 complete, check status in 9 hours if State is Snapmirrored go to the next phase"
