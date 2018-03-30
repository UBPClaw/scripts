#Requires -Version 2.0

#*******************************************************************************
# Phase 5 for odd Monthly Data Update
# Quiesce and Break svfs01_odd from ranger_dp_odd
# Update Staging Share on svfs01
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
$svfs01 = connect-nacontroller -name g35 -Vfiler svfs01

# Quiesce the SnapMirror
Invoke-NaSnapmirrorQuiesce G35:svfs01_odd -Controller $g35

# Break the SnapMirror
Invoke-NaSnapmirrorBreak G35:svfs01_odd -Controller $g35 -Confirm:$false

# SVFS01 Staging Share
remove-nacifsshare Staging -controller $svfs01
sleep 10
$Date = get-date -Format y
add-NaCifsShare Staging /vol/svfs01_odd/dp/DataProcess -comment "$Date" -controller $svfs01

# Colo Complete
write-host "Colo Hosting Complete"