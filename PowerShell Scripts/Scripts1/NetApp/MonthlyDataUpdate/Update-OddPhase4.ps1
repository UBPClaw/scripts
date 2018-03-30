#Requires -Version 2.0

#*******************************************************************************
# Phase 4 for odd Monthly Data Update
# Quiesce and Break vfs02_odd_fc from ranger_dp_odd
# Update Staging Share on vfs02
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
$vfs02 = connect-nacontroller -name m35 -VFILER vfs02

# When Synch is complete Quiesce the Snapmirror
Invoke-NaSnapmirrorQuiesce M35:vfs02_odd_fc -Controller $m35 

# Break the Snapmirror
Invoke-NaSnapmirrorBreak M35:vfs02_odd_fc -Controller $m35 -Confirm:$false

# VFS02 Staging Share
remove-nacifsshare Staging -controller $vfs02
sleep 10
$Date = get-date -Format y
add-NaCifsShare Staging /vol/vfs02_odd_fc/dp/DataProcess -comment "$Date" -controller $vfs02

# Hosting Complet
write-host "Poway Hosting Complete, proceed to Colo"
