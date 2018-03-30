# Functions for Script
Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

Function Write-Log {
   Param([string]$msg,[string]$file)
   Write-Host "$msg"
   $msg | Out-File -FilePath $file -Append
}

function Check-Name{
$searcher=New-Object DirectoryServices.DirectorySearcher
$searcher.Filter="(&(objectcategory=person)(objectclass=contact)(cn="+$Name+"))"
$results=$searcher.FindOne()
if ($results.path.length -gt 1)
     { 
     return $true
     }
    else
     {
     return $false
     }
 }

function Check-Email{
$searcher=New-Object DirectoryServices.DirectorySearcher
$searcher.Filter="(&(objectcategory=person)(objectclass=contact)(targetAddress=SMTP:"+$ExternalEmail+"))"
$results=$searcher.FindOne()
if ($results.path.length -gt 1)
     { 
     return $true
     }
    else
     {
     return $false
     }
 }


# Input File. Exported from Snapon AD
$FileInput = 'C:\workdir\Snapon\Exchange\SnaponInfo20090112095127.csv'
#$FileInput = 'C:\workdir\Snapon\Exchange\snaponimporttest.csv'

# Log File.
$log = "C:\workdir\Snapon\Exchange\GALUpdate"+(Time-Stamp)+".log"
$elog = "C:\workdir\Snapon\Exchange\GALUpdateErrors"+(Time-Stamp)+".log"


# Write header for Log file.
Write-Log "----------------------------------------" $log
Write-Log "Starting at $([System.DateTime]::NOW)" $log
Write-Log "----------------------------------------" $log



# Cycle throug Input File.
import-csv $FileInput | foreach{
  $FirstName = $_.givenname
  $LastName = $_.sn
  $ExternalEmail = $_.mail
  $Name = "y-$FirstName $LastName"
  $EmailAlias = "$FirstName.$LastName"
  $Email = "$FirstName.$LastName@MitchellRepair.com"
  $Container = "CN=SnapOn,CN=Users"
	$root = [adsi]""
	$rootdn = $root.distinguishedName

	# Check to see if Name is in use
	$a = Check-Name
		if ($a -eq $true)
		{
		Write-Log "$Name  already exists" $elog
		}
		else
		{
    # Check to see if email address is in use
		$b = Check-Email
			if ($b -eq $true)
			{
			Write-Log "$ExternalEmail email address already exists" $elog
			}
			else 
			{
 			#******************
			#* Create Contact *
			#******************
			$OU =[ADSI]"LDAP://$Container,$rootdn"
			$Contact = $OU.Create("contact", "cn=$Name")
			$Contact.SetInfo()
			
			#**************************
			#* Get Contact            *
			#**************************
			$objContact = [ADSI]"LDAP://cn=$Name,$Container,$rootdn"
			
			
			#***************************
			#* General Properties Page *
			#***************************
			$objContact.Put("givenName", $FirstName)
			$objContact.Put("sn", $LastName)
			$objContact.Put("displayName", $Name)
			$objContact.Put("mail", $ExternalEmail)
		

			#************************************
			#* Exchange General Properties Page *
			#************************************
			$objContact.Put("mailNickname", $EmailAlias)
			$objContact.Put("targetAddress", "smtp:$ExternalEmail")
			$objContact.Put("proxyAddresses", "SMTP:$ExternalEmail")
			$objContact.SetInfo()
			
			#*********************
			#* Completed Message *
			#*********************
			Write-Log "$Name has been created" $log
			}
		}
}
Write-Log "----------------------------------------" $log
Write-Log "Finished at $([System.DateTime]::NOW)" $log
Write-Log "----------------------------------------" $log