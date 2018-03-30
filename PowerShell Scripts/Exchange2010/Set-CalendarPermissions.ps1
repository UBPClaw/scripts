<#

 NAME: Set-CalendarPermissions.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@powershell.no

 COMMENT: Script to set calendar-permission for mailboxes in Exchange Server 2010.
          For a list of valid AccessRights, see http://technet.microsoft.com/en-us/library/ff522363.aspx
          More information: http://blog.powershell.no/2010/09/20/managing-calendar-permissions-in-exchange-server-2010

 You have a royalty-free right to use, modify, reproduce, and
 distribute this script file in any way you find useful, provided that
 you agree that the creator, owner above has no warranty, obligations,
 or liability for such use.

 VERSION HISTORY:
 1.0 19.09.2010 - Initial release

#>

#requires -version 2

#Load Exchange Server 2010 Management Shell if not loaded. You may delete/comment out this step if you are running the script from the Exchange Management Shell
if (-not (Get-PSSnapin | Where-Object {$_.Name -like "Microsoft.Exchange.Management.PowerShell.E2010"})){
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
}

#Custom variables
$mailboxes = Get-Mailbox -Database "M1_MBX_Pri"
$AccessRights = "Reviewer"

#Loop through all mailboxes
foreach ($mailbox in $mailboxes) {

#Retrieve name of the user`s calendar
$calendar = (($mailbox.SamAccountName)+ ":\" + (Get-MailboxFolderStatistics -Identity $mailbox.SamAccountName -FolderScope Calendar | Select-Object -First 1).Name)

#Check if calendar-permission for user "Default" is set to the default permission of "AvailabilityOnly"
    if (((Get-MailboxFolderPermission $calendar  | Where-Object {$_.User -like "Default"}).AccessRights) -like "AvailabilityOnly" ) {

    Write-Host "Updating calendar permission for $mailbox..." -ForegroundColor Yellow

    #Set calendar-permission for user "Default" to value defined in variable $AccessRights
    Set-MailboxFolderPermission -User "Default" -AccessRights $AccessRights -Identity $calendar
    }
}