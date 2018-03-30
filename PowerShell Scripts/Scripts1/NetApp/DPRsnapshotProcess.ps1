
##################################################################
# 
#  This script removes the clone after the copy is complete.
#
##################################################################

##################################################################
# 
#  Check for DataONTAP Module and load if required.
#
##################################################################

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

##################################################################
# 
#                Connect to NetApp Controller M45
#
##################################################################

$m45 = connect-nacontroller -name m45

###################################################################
# 
# remove, offline, and destroy the snapshot volume from dakota 
#
####################################################################

set-navol ranger_dpr_clone -Offline -controller $m45
remove-navol ranger_dpr_clone -controller $m45 -Confirm:$false 
remove-NaSnapshot vfs03_dpr_fc clone_ranger_dpr_clone.1 -controller $m45 -Confirm:$false


# *****************************************************************
#                  Creat DPR Snapshot
# *****************************************************************

##################################################################
# 
#  Copy Monthly Data from the DPR share at vfs03\dpr
#  The vfs03_dpr_fc volume is located in the m1hosting domain
#  We need a way to copy the data to the QAPCE server on the
#  Repair Domain. We will create a clone of the vfs03_dpr_fc
#  volume and mount it on the vfiler ranger
#
##################################################################


###################################################################
# 
# Make a connection to the controller m45 and ranger
#
###################################################################


$ranger = connect-nacontroller -name m45 -Vfiler ranger

###################################################################
# 
# Create the point in time snap shot vfs03_dpr_fc 
#
###################################################################


New-NaVolClone ranger_dpr_clone vfs03_dpr_fc -SpaceReserve none -Controller $m45

###################################################################
# 
# Mount volume on vfiler Malibu
#
###################################################################
#Set-NaVfilerStorage malibu -AddStorage ranger_dpr_clone -Controller $m45

Set-NaVfilerStorage ranger -AddStorage ranger_dpr_clone -Controller $m45



 # Now you need to set up a share on malibu. Connect to malibu through computer managment to create share.
 # c:\vol\ranger_dpr_clone\share\DPR\Uploads   Share name DPRUploads
 # Give the share permissions Administrator Full, G_Data_Dev full
 
 add-NaCifsShare DPRUploads /vol/ranger_dpr_clone/share/DPR/Uploads -controller $ranger
 
 
 # Assign permissions to the file structure Uploads. This will take a while use CACLS
 # Assigg AuthUsers read
 # Toan can now access the file share from anywhere on the repair domain.
 
 # Map a drive to \\ranger\dpruploads and Run the following cacls command to set the permissions for data dev (I run from the server canyon)
 #  cacls Z: /T /E /G "repair\G_Data_Dev":c
 # cacls Z: /T /E /G "repair\G_Field Technicians":F
 
 # The xcacls command will allow you to modify permissions remotely.
 # However, when running this for DPRuplods, it would get to an empty folder and then die.
 # xcacls \\ranger\DPRUploads\*.* /T /E /G "repair\G_Field Technicians":F
 #xcacls \\ranger\DPRUploads\*.* /T /E /G "repair\G_Data_Dev":rw
 
# The test folder on dakota\apps is set to allow access for G_Data_Dev and G_Dev
# The get-acl cmdlet uses existing permission to assing new permissions.
# At the time this was the best way to assing permissions to the snaphot

$acl = get-acl "\\dakota\apps\test"

Set-Acl "\\ranger\DPRUploads" $Acl

 
 
 
    $body = "THE MONTHLY DPR SNAPSHOT PROCESS HAS COMPLETED" 
	$sender = "administrator@mitchell1.com"
	#$recipient = "bryan.debrun@mitchell1.com";"administrator@mitchell1.com"
    $recipient = "toan.lieu@mitchell1.com";"administrator@mitchell1.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "TTHE MONTHLY DPR SNAPSHOT PROCESS HAS COMPLETED" 
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)
    
    




