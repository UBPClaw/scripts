#***********************************************
#* Created 04-02-07 by BTS                     *
#* Create_New_SalesRep.ps1                     *
#***********************************************

#*************************
#* Retrieve contact info *
#*************************
param ([string]$FirstName = $(read-host "Enter First Name"),
			 [string]$LastName = $(read-host "Enter Last Name"),
			 [string]$ExtEMail = $(read-host "Enter Email Address"),
			 [string]$Region = $(read-host "Enter Region"),
			 [string]$Street = $(read-host "Enter Street Address"),
			 [string]$City = $(read-host "Enter City"),
			 [string]$State = $(read-host "Enter State/Province"),
			 [string]$Zip = $(read-host "Enter Zip/Postal Code"),
			 [string]$Phone = $(read-host "Enter Phone Number")
			 )


#*****************************************************
#* Shouldn't have to modify anything below this line *
#*****************************************************
$Name = "$FirstName $LastName"
$Email = "$FirstName.$LastName@Mitchell1.com"
$EmailAlias = "$FirstName.$LastName"
$EmailGroup = "Repair Sales Reps"
$Title = "Repair Sales Rep"
$Department = "Sales"
$Company = "Mitchell1"
$Container = "ou=Repair Sales Reps,ou=Contacts,ou=All"
$root = [adsi]""
$rootdn = $root.distinguishedName

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
$objContact.Put("physicalDeliveryOfficeName", $Region)
$objContact.Put("telephoneNumber", $Phone)
$objContact.Put("mail", $ExtEMail)

#***************************
#* Address Properties Page *
#***************************
$objContact.Put("streetAddress", $Street)
$objContact.Put("l", $City)
$objContact.Put("st", $State)
$objContact.Put("postalCode", $Zip)

#********************************
#* Organization Properties Page *
#********************************
$objContact.Put("title", $Title)
$objContact.Put("department", $Department)
$objContact.Put("company", $Company)

#************************************
#* Exchange General Properties Page *
#************************************
$objContact.Put("mailNickname", $EmailAlias)
$objContact.Put("targetAddress", "smtp:$ExtEMail")
$objContact.Put("proxyAddresses", "SMTP:$Email")
$objContact.SetInfo()

#*********************************
#*Sleep 10 seconds and reconnect *
#*********************************
#Start-Sleep -s 10
$objContact = [ADSI]"LDAP://cn=$Name,$Container,$rootdn"

#*****************************
#* Member Of properties page *
#*****************************
$group=[adsi]("LDAP://cn=$EmailGroup,$Container,$rootdn")
$group.Add("LDAP://"+$objContact.DistinguishedName)
#$group.SetInfo()
#$group.psbase.CommitChanges()

#*********************
#* Completed Message *
#*********************
Write-Host New contact $Name has been created with the following attributes:
Write-Host First Name: $FirstName
Write-Host Last Name:  $LastName
Write-Host Email: $ExtEMail
Write-Host Region: $Region
Write-Host Address: $Street
Write-Host $City, $State $Zip
Write-Host Phone: $Phone
