#Remove-Item e:\temp\spsites.txt
#Remove-Item e:\temp\spsitesII.txt
#$BUPdate =get-date -Format M-d-yyyy-h-m-s


$WebApp = "intranetii.corp.mitchellrepair.com"
$Site = "insidesales"

# Don't change the URL variable. It is built off the Webapp and site variables
$URL = http://$WebApp/sites/$Site 

$owneremail = "srv-sharepoint@mitchell1.com"
$ownerlogin = "repair\srv-sharepoint"
$ownername = "SRV-SHAREPOINT"
$secondaryemail = "administrator@mitchell1.com"
$secondarylogin = "repair\mricadmin"
$secondaryname = "MRICADMIN"

# Template if using a custom template, the template (.stp) must be copied locally to the web server.
# You will then need to add the template using the stsadm -o addtemplate command
# You can view site templates by typing stsadm -o enumtemplates

# If you are adding a basic template, you can add one of the following
# STS#0: Team Site STS#1: Blank Site STS#2: Document Workspace MPS#0: Basic Meeting Workspace
# MPS#1: Blank Meeting Workspace MPS#2: Decision Meeting Workspace MPS#3: Social Meeting Workspace
# MPS#4: Multipage Meeting Workspace BLOG#0: Blog WIKI#0: Wiki Site

# custom syntaxt = -sitetemplate _GLOBAL_#3
# Basic syntaxt =  -sitetemplate STS#1
$SiteTemplate = "STS#1"

$title = "Inside Sales"
$Description = "Inside Sales"
$databaseserver = "impreza"
$databasename = "WSS_Content_"$Site


stsadm -o createsiteinnewdb -url $URL -ownermail $owneremail -ownerlogin $ownerlogin -ownername $ownername -secondaryemail $secondaryemail -secondarylogin $secondarylogin -secondaryname $secondaryname -sitetemplate $SiteTemplate -title $title -description $Description -databaseserver $databaseserver -databasename $databasename

stsadm -or creategroup -url $URL -name $Site" Members" -description $Site" Members" -ownerlogin $ownerlogin -type Member
stsadm -or creategroup -url $URL -name $Site" Visitors" -description $Site" Visitors" -ownerlogin $ownerlogin -type Visitor
stsadm -or creategroup -url $URL -name $Site" Owners" -description $Site" Owners" -ownerlogin $ownerlogin -type Owner

