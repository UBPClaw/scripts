# Backup with Robocopy and powershell by Mario Cortes
# Script For BCCP NetApp Filer data copy to San Jose

# ###################################################################
# # Define Functions
# ###################################################################
Function Time-Stamp {(get-date).toString('yyyyMMdd')}
Function Failed {send-mailmessage -to $SendTo -from $SendFrom -subject $subjectError -body $bodyError -Attachments $log -smtpserver $SMTPServer}
Function Success {send-mailmessage -to $SendTo -from $SendFrom -subject $subjectGood -body $bodyGood -Attachments $log -smtpserver $SMTPServer}
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
                        
# ###################################################################
# # Define Variables
# ###################################################################
#$SendTo = "administrator@mitchell1.com"
$SendTo = "administrator@mitchell1.com"
$SendFrom = "bccpfiler2sjos@mitchell1.com"
$SMTPServer = "smtp.corp.mitchellrepair.com"
$subjectError = "FAIL! Robocopy or Snapmirror Failed!!!"
$bodyError = "FAIL!!!  Canyon Robocopy or Snapmirror Failed!!! Review Log File."
$subjectGood = "BCCP to San Jose has completed"
$bodyGood = "Scheduled Task on Canyon has completed. So long and thanks for all the fish."
$log = "C:\Scripts\Logs\bccp_robocopy_"+(Time-Stamp)+".log"
$arSourceFolders = ("\\dakota\dept\finance", "\\dakota\dept\costing", "\\dakota\dept\srfin", "\\dakota\dept\eis", "\\dakota\dept\distribution", "\\dakota\dept\cisdnld8.3", "\\dakota\dept\cisdnld", "\\dakota\dept\cisuploads", "\\dakota\apps\cis");
$arDestinationFolders = ("\\malibu\c$\vol\malibu_bccp\dakota\data\dept\finance", "\\malibu\c$\vol\malibu_bccp\dakota\data\dept\costing", "\\malibu\c$\vol\malibu_bccp\dakota\data\dept\srfin", "\\malibu\c$\vol\malibu_bccp\dakota\data\dept\eis", "\\malibu\c$\vol\malibu_bccp\dakota\data\dept\distribution", "\\malibu\c$\vol\malibu_bccp\dakota\data\dept\cisdnld8.3", "\\malibu\c$\vol\malibu_bccp\dakota\data\dept\cisdnld", "\\malibu\c$\vol\malibu_bccp\dakota\data\dept\cisuploads", "\\malibu\c$\vol\malibu_bccp\dakota\Apps\cis");
$notifyCodes = @(16, 8)

# ###################################################################
# # Create Log
# ###################################################################
get-date -format g | Out-file $log -encoding ASCII

# ###################################################################
# # Verify Directory Structure Match and Start Robocopy
# ###################################################################
add-content -path $log -value "Checking directory structure and starting Robocopy"
if($arSourceFolders.Length -ne $arDestinationFolders.Length)
{
     add-content -path $log -value "The numbers of folders don't match";
    Failed
}
else{
    for($i=0; $i -lt $arSourceFolders.Length; $i++)
    {
        robocopy $arSourceFolders[$i] $arDestinationFolders[$i] /MIR /COPY:DATSO /R:2 /W:1 * /NP /NFL /NDL /LOG+:$log
        ## Exit code stored variable LastExitCode 
				$exitCode = $LastExitCode
				add-content -path $log -value "Robocopy Exist Code is $exitCode";
				if($notifyCodes -contains $exitCode)
				 {
					add-content -path $log -value "The Robocopy failed for $arSourceFolders[$i] with exitcode $exitCode";
					Failed
				 }
    }
}

add-content -path $log -value "Robocopy has completed."

#Check for Needed Module
get-mymodule -name "DataONTAP"

# Login to the NetApp Controller
$g35 = connect-nacontroller -name g35

# Update Snapmirror
add-content -path $log -value "Starting SnapMirror"
Invoke-NaSnapmirrorUpdate -Source nam35-nag35:malibu_bccp -Destination G35:M1_bccp -Controller $g35

# WAIT until Update is Complete: (Check status connect to g35 and run "get-nasnapmirror G35:M1_bccp -Controller $g35")
add-content -path $log -value "Checking if SnapMirror is done"
while ((get-nasnapmirror G35:M1_bccp -Controller $g35).status -ne "idle")
{
	Write-Host "Sleeping"
	Sleep 30
}

add-content -path $log -value "SnapMirror Complete:"
get-nasnapmirror G35:M1_bccp -Controller $g35 | select LastTransferDurationTs,@{n='LastTransferSize (Gb)';e={($_.LastTransferSize / 1gb).tostring("F02")}} | fl | out-file $log -append -encoding ASCII
get-date -format g | Out-file $log -append -encoding ASCII

#Email Job compltetion
Success

Write-host -foregroundcolor 'green' "Done :)";
