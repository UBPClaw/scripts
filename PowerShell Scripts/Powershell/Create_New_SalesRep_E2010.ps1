#************************************************* 
#* Created 04-02-07 by BTS                       *
#* Create_New_SalesRep.ps1                       *
#* Updated 06-30-2015 for use with Exchange 2010 *
#* Requires running in Exchange Management Shell *
#*************************************************

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
$ou = "corp.mitchellrepair.com/All/Contacts/Repair Sales Reps"

#*******************************
#* Create Mail Enabled Contact *
#*******************************
New-MailContact -Name $Name -Firstname $FirstName -LastName $LastName -displayname $Name -alias $EmailAlias -ExternalEmailAddress $ExtEMail -PrimarySmtpAddress $Email -OrganizationalUnit $ou

#***************************
#* Set Contact Information *
#***************************
Set-Contact $Name -Company $Company -Office $Region -Phone $Phone -StreetAddress $Street -City $City -StateOrProvince $State -PostalCode $Zip -Title $Title -Department $Department

#**********************************
#* Add user to  Repair Sales Reps *
#**********************************
Add-DistributionGroupMember $EmailGroup -Member $Email

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
