# Defrag-CIS.ps1
# Script to defrag the w: volume for encore using Powershell and WMI

# First - get the volumes via WMI
$v=gwmi win32_volume -computer "encore"

# Now get the cis volume
$v1=$v | where {$_.name -eq "W:\"}

# Defrag the volume
$v1.defrag($true)
