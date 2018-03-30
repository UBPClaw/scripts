#Get New User Information

#*************************
#* Retrieve User info    *
#*************************
param ($user = $(read-host "Enter User Name"),
	   $lname = $(read-host "Enter Last Name"),
	   $fname = $(read-host "Enter First Name"),
	   $sitecode = $(read-host "Enter Site Code")
	  )


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


#Generate password to variable
$NewPassword=New-RandomPassword

#Create local user
$hostname = "genesis"
#$user = "test"
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
New-Item -Name $user -Path \\$hostname\ftproot -ItemType Directory
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

$NewPassword

#Send Email
#$sender = "net.admin@mitchell1.com"
#$recipient = "net.admin@mitchell1.com,TechSupport1stLevel@mitchell1.com,QATeam@Mitchell1.com,mitftp@intetics.com" 
#$server = "smtp.corp.mitchellrepair.com"
#$subject = "Password changed for oem202 FTP folder access on ftp.mitchell1.com " + [System.DateTime]::Now
#$body = "The new password for the oem202 ftp login is " + $NewPassword + "."
#$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
#$client = new-object System.Net.Mail.SmtpClient $server
#$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
#$client.Send($msg)