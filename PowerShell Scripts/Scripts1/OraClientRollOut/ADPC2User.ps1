# ==============================================================================================
# 
# Microsoft PowerShell File 
# 
# NAME: ADPC2User.ps1
# 
# DATE: 1-11-07
# 
# COMMENT: Find all computers in Active Directory, if they respond to ping log last logged on user
# 
# ==============================================================================================

#Function To ping computer to see if it is alive
Function Ping-Name {
	  PROCESS { $wmi = get-wmiobject -query "SELECT * FROM Win32_PingStatus WHERE Address = '$_'"
	   if ($wmi.StatusCode -eq 0) {
	   	  $_
 	   } else {
 	   Write-Log "$_ not answering ping" $ErrorLog
 	   }
   }
}

#Funtion to get the time and date to string
Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

#Funtion to write to screen and to logfile
Function Write-Log {
   Param([string]$msg,[string]$file)
   Write-Host "$msg"
   $msg | Out-File -FilePath $file -Append
}

#Function to get remote registry keys
function get-remoteregistry([string]$Path,[string]$computer)
{
  if($path -eq "")
   {
     return "A valid path should be provided"
   }
  #split the path to get a list of subkeys that we will need to access
  $subpath=$path.split("\");
  if($subpath[0] -eq "HKLM:")
   {
     $root="LOCALMACHINE";
   }
  elseif($subpath[0] -eq "HKCU:")
   {
     $root = "CurrentUser";
   }
  else
   {
     return "path is not valid";
   }
 
  #Access Remote Registry Key using OpenRemoteBaseKey method. The syntax shown below is
  #used to access static methods on types
   $rootkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($root,$computer)
   
   #Traverse the registry hierarchy
   $key=$rootkey;
   for($i=1;$i -lt $subpath.count;$i++)
    {
      $key=$key.opensubkey($subpath[$i]);
    }
 
	#Add required properties to the RegistryKey object using add-member cmdlet. The cast to psobject is
	# needed to make the members that are added stick. We add Property Value names, and subkeys for the 
	# RegistryKey as properties.
 
	$key = [psobject]$key;
	If ($key -ne $null) {
	$key | add-member NoteProperty Property $Key.GetValueNames();
	$key | add-member NoteProperty SubKeys $key.GetSubkeyNames();
	$key | add-member NoteProperty PSChildName $key.Name }
	 return $key;
	}


# Change Log Path to your needs
$log = "C:\workdir\meps\ADPC2User"+(Time-Stamp)+".log"
$ErrorLog = "C:\workdir\meps\errorlog"+(Time-Stamp)+".log"

#Start Logging
Write-Log "Starting at $([System.DateTime]::NOW)" $log

#Find All computers in Active Directory
$ldapQuery = "(&(objectCategory=computer))"
$de = new-object system.directoryservices.directoryentry
$ads = new-object system.directoryservices.directorysearcher -argumentlist $de,$ldapQuery
$complist = $ads.findall()

#Ping all computers, return last logged on users that answer ping and log
$complist | % {
    $cn = $_.properties['cn']
    $cn | Ping-Name | % {
  	$rv=get-remoteregistry -path hklm:"\Software\Microsoft\Windows NT\CurrentVersion\WinLogon" -computer $_
    $lastuser = $rv.GetValue("DefaultDomainName") + "\" + $rv.GetValue("DefaultUserName")
    write-Log "$_ - $lastuser" $log
    $lastuser = "Check PC"
  }
}

Write-Log "End Check at $([system.DateTime]::NOW)" $log
 