#*********************************************************************************
# Even Monthly Data Update
# Create copy of xterra_data_production
# must be run on computer that has JAMS Client installed and Compellent Powershell
#*********************************************************************************


#How to handle errors 
#"SilentlyContinue": do not print, continue 
#"Continue": Print, continue (this is the default) 
#"Stop": Halt the command or script 
#"Inquire": Ask the user what to do 
$ErrorActionPreference = "Inquire"

# Variables to run script
$JAMSUser = "Compellent"
$JAMSHostingUser = "m1hosting srv-deploy"
$JAMSDefaultServer = "powc-jams-01-pv.corp.mitchellrepair.com"
$schost = "powc-sto-01-pp"
$SRCvolumename = "xterra_data_production"
$DESvolumename = "Monthly_Data_Even"
$DESservername = "vfs02"
$month = (get-date).tostring("y")

# Modules Needed
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
Write-Host "Loading required module and snapin..." 
get-mymodule -name JAMS
add-pssnapin Compellent.StorageCenter.PSSnapin

# Get Compellent Password from JAMS
Write-Host "Getting credentials from JAMS..."
[System.Management.Automation.PSCredential]$cred = Get-JAMSCredential $JAMSUser
[System.Management.Automation.PSCredential]$credhosting = Get-JAMSCredential $JAMSHostingUser

# Instantiate Connection to Storage Center
Write-Host "Connecting to storage center $schost..."
$connection = Get-SCConnection -HostName $schost -User $cred.UserName -Password $cred.Password -Save $schost -Default

# Instantiate Session to Hosting Server
Write-Host "Creating pssession to $DESservername..."
$s = New-PSSession $DESservername -credential $credhosting

# Add Compellent Snapon on Hosting Server
Write-Host "Loading required snapin on $DESservername..."
Invoke-Command -Session $s -ScriptBlock {add-pssnapin Compellent.StorageCenter.PSSnapin}

# Set Variables on Hosting Server
Write-Host "Creating variables on $DESservername..."
Invoke-Command -Session $s -ScriptBlock {
	$drive = "J"
	$path = "J:\DataProcess"
	$month = (get-date).tostring("y")
	$newreplayname = "Monthly Data $month"
	$DESservername = "vfs02"
}

# Get Existing Volume Name
Write-Host "Getting current disk on $DESservername..."
$CurrentDisk = Invoke-Command -Session $s -ScriptBlock {Get-CMLVolume -AccessPath J:}

if ($CurrentDisk -eq $null)
{
	Write-Host "Unable to find Disk on $DESservername" -ForegroundColor Red
	break;
}

# Remove Existing Share 
Write-Host "Removing Share on $DESservername..."
Invoke-Command -Session $s -ScriptBlock {Remove-SmbShare Staging -Confirm:$false}

# Remove Existing Volume
Write-Host "Removing volume from $schost..."
get-scvolume $CurrentDisk.Label | remove-scvolume -SkipRecycleBin -Confirm:$false

# Rescan Server 
Write-Host "Rescanning $DESservername to remove volume..."
Invoke-Command -Session $s -ScriptBlock {Rescan-CMLDiskDevice -Server $DESservername -RescanDelay 5}

# Get Destination Server from Storage Center
$DESserver = Get-SCServer -Name $DESservername

if ($DESserver -eq $null)
{
	Write-Host "Unable to find server $DESservername on Storage Center $schost!" -ForegroundColor Red
	break;
}

# Create Replay
$newreplayname = "Monthly Data $month"
New-SCReplay (Get-SCVolume -Name $SRCvolumename) -MinutesToLive 1440 -Description $newreplayname

# Get last replay from volume
Write-Host "Checking for available replays for this volume..."
$replays = Get-SCReplay -SourceVolumeName $SRCvolumename | where{$_.State -eq "Frozen"}

if ($replays -eq $null -or $replays.Count -eq 0)
{
	Write-Host "No frozen replays were found for volume $volumename!" -ForegroundColor Red
	break;
}

# We want only the most recent replay
$latestreplay = $replays[-1]

# Create View
# $newreplayname = "Monthly Data $month"
Write-Host "Creating view from replay..."
$replayview = New-SCVolume -SourceSCReplay $latestreplay -Name $newreplayname

# Map View to server
Write-Host "Mapping new replay view to server..."
New-SCVolumeMap -SCVolume $replayview -SCServer $DESserver
 
# Need to mount volume and create the Data_Next share
# Rescan Server 
Write-Host "Rescanning server for new volume..."
Invoke-Command -Session $s -ScriptBlock {Rescan-CMLDiskDevice -Server $DESservername -RescanDelay 5}

#Turn Off Read Only
Write-Host "Turning off Read Only for the new volume..."
Invoke-Command -Session $s -ScriptBlock {Get-Disk | Where-Object IsOffline –Eq $True | Set-Disk –IsReadOnly $False}

#Online the Disk
Write-Host "Online the new volume..."
Invoke-Command -Session $s -ScriptBlock {Get-Disk | Where-Object IsOffline –Eq $True | Set-Disk –IsOffline $False}

# Set the volume Label
Write-Host "Changing Volume Label..."
Invoke-Command -Session $s -ScriptBlock {	Set-Volume -NewFileSystemLabel $newreplayname -DriveLetter $drive}

# Create Staging Share 
Write-Host "Creating Share on $DESservername..."
Invoke-Command -Session $s -ScriptBlock {New-SmbShare -Name Staging -Path $path -FullAccess Administrators -ReadAccess Everyone}

# Remove Remote Powershell Session
Remove-PSSession $s
