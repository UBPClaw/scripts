# Create Functions for Script to run
function New-RandomPassword{
    #Set Password Length
    $Size=5   
    $Bytes = new-object System.Byte[] $Size 
    #Specify Characters to Choose from
    $Chars = "abcdefghijkmnpqrstuvwxyz".ToCharArray()
    $Chars += "ABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray()
    $Chars += "23456789".ToCharArray()
    #Set Password to null
    $Password = ""
    $Crypto = new-object System.Security.Cryptography.RNGCryptoServiceProvider
    # Now we need to fill array of bytes with a 
    # cryptographically strong sequence of random nonzero values. 
    $Crypto.GetNonZeroBytes($Bytes)
    $password = [string]::join("", ($Bytes | foreach{ $Chars[$_ % ($Chars.Length - 1)]}))
    #Add Number to end of password to meet complexity requirements
    $complex = "aB8"
    $password = "$password$complex"
    # Finally, return the random password back
    "$Password"
    }

function Set-UserAccess {
	param (
		[String]$Path,
		[String]$User,
		[String]$Permission
	)
	if (Test-Path -Path $Path -PathType Container) {
		## Get the current ACL.
		$acl = Get-Acl -Path $Path
 
		## Setup the access rule.
		$allInherit = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit", "ObjectInherit"
		$allPropagation = [System.Security.AccessControl.PropagationFlags]"None"
		$AR = New-Object System.Security.AccessControl.FileSystemAccessRule($User, $Permission, $allInherit, $allPropagation, "Allow")
 
		## Check if Access already exists.
		if ($acl.Access | Where { $_.IdentityReference -eq $User}) {
			$accessModification = New-Object System.Security.AccessControl.AccessControlModification
			$accessModification.value__ = 2
			$modification = $false
			$acl.ModifyAccessRule($accessModification, $AR, [ref]$modification) | Out-Null
		} else {
			$acl.AddAccessRule($AR)
		}
		Set-Acl -AclObject $acl -Path $Path
		Return $true
	} else {
		Return $false
	}
}

Function Write-Log {
   Param([string]$msg,[string]$file)
   Write-Host "$msg"
   $msg | Out-File -FilePath $file -Append
}

Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

$log = "E:\Scripts\Logs\UserImport"+(Time-Stamp)+".txt"
$FileInput = '\\malibu\it\NTServers\Docs\SAGE_Sales_Logix\RemoteUsers.txt'
#$FileInput = '\\malibu\it\NTServers\Docs\SAGE_Sales_Logix\TestRemoteUsers.txt'
#*****************************
#* Retrieve User info        *
#* Header needs to be        *
#* user,lname,fname,sitecode *
#*****************************
import-csv $FileInput | ForEach-Object {
				$user = $_.user
				$lname = $_.lname
				$fname = $_.fname
				$sitecode = $_.sitecode
				#Generate password to variable
				$NewPassword=New-RandomPassword
								
				#Create local user
				$hostname = "genesis"
				$objOU = [adsi] “WinNT://$hostname”
				$objUser = $objOU.Create("User", $user)
				$objUser.SetPassword($NewPassword)
				$objUser.SetInfo()
				$objUser.description = "$fname $lname, Site Code $sitecode"
				$objUser.SetInfo()
				$objUser.UserFlags = 64 + 65536 # ADS_UF_PASSWD_CANT_CHANGE + ADS_UF_DONT_EXPIRE_PASSWD
				$objUser.SetInfo()
								
				#Create Directory
				$path = "\\$hostname\ftproot\$user"
				New-Item -Name $_.user -Path \\$hostname\ftproot -ItemType Directory
				New-Item -Name FailedTrans -Path $path -ItemType Directory
				New-Item -Name InFiles -Path $path -ItemType Directory
				New-Item -Name OutFiles -Path $path -ItemType Directory
				$Access = $hostname+"\"+$user
				$Permission = "Read"
				$Permission2 = "Modify"
				Set-UserAccess -Path $path -User $Access -Permission $Permission
				Set-UserAccess -Path $path\FailedTrans -User $Access -Permission $Permission2
				Set-UserAccess -Path $path\InFiles -User $Access -Permission $Permission2
				Set-UserAccess -Path $path\OutFiles -User $Access -Permission $Permission2
				
				Write-Log "User $user, $fname $lname, Site Code $sitecode with password $NewPassword has been created" $log
		}