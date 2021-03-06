# Needed to send results of script to a log while also displaying the results on screen.
Function Write-Log 
{
   Param([string]$msg,[string]$file)
   Write-Host "$msg"
   $msg | Out-File -FilePath $file -Append
}


function New-RandomPassword{
    #Set Password Length
    $Size=8   
    $Bytes = new-object System.Byte[] $Size 
    #Specify Characters to Choose from
    $Chars = "abcdefghijkmnpqrstuvwxyz".ToCharArray()
    $Chars += "ABCDEFGHIJKLMNPQRSTUVWXYZ".ToCharArray()
    $Chars += "23456789".ToCharArray()
    #Set Password to null
    $Password = ""
    $Crypto = new-object System.Security.Cryptography.RNGCryptoServiceProvider
    # Now we need to fill array of bytes with a 
    # cryptographically strong sequence of random nonzero values. 
    $Crypto.GetNonZeroBytes($Bytes)
    $password = [string]::join("", ($Bytes | foreach{ $Chars[$_ % ($Chars.Length - 1)]}))
    # Finally, return the random password back
    "$Password"
	}

	
	$log = "\\malibu\it\NTServers\Scripts\PasswordChange\UPWD.log"
	$Users = gc \\malibu\it\NTServers\Scripts\PasswordChange\users.txt
	foreach ($dude in $users)
	{
	$Newuser= New-RandomPassword
	
	#Test string
	#$User = [adsi] "LDAP://H1/CN=$dude,OU=Users,OU=Users,OU=All,DC=corp,DC=mitchellrepair,DC=com"
	$user = [adsi] "LDAP://H3/CN=$dude,OU=Special Accounts,OU=Users,OU=All,DC=corp,DC=mitchellrepair,DC=com"
	$user.psbase.invoke("setpassword","$Newuser")
	$user.SetInfo()
		$dude + "    " + $Newuser 
		Write-log "Password change for $dude   $Newuser" $log
	}
	
  
 