# ==================================================================================================================
# \\malibu\NTServers\Scripts\NetBackup\Policies\DActivatingPolicies.ps1
# Date 12/16/2008
# Bryan K. DeBrun
# This script identifies Active and non-active NetBackup Policies and then deactivates the active policies
# This script is mainly used prior to updating or making changes to the NetBackup application. It would not be a good
# thing if policies started launching backup jobs during an update/change to the NetBackup application. By deactivating
# policies, no jobs can run. (DSSU Duplication jobs can. We will use a script to disable those as well.)
# We are using psexec and NBU command to list and deactivate policies.
# ==================================================================================================================



# Get the date. We will use it to name our files.

$poldate = Get-Date -F M-dd-yyyy

# Remove existing files. Will only remove for the current date. Just in case we need to run the
# script multiple times.

Remove-Item \\gremlin\d$\BKD_LOGS\Policies\ActivePols_$poldate.txt
Remove-Item \\gremlin\d$\BKD_LOGS\Policies\NotActivePols_$poldate.txt

# Locate Active policies and output the results to a text file on Gremlin
 
 $PolList = bppllist
 
 foreach ($policy in $PolList)
 {
 $ActivePol = bppllist $policy -L |
 	where-object {$_-match "Active:            yes"} 
 $Actvpol = $policy + " " + $ActivePol 
 $Actvpol | 
 	where-object {$_-match "Active:            yes"} | 
	foreach-object {$_-replace " Active:            yes",""} | Out-File \\gremlin\d$\BKD_LOGS\Policies\ActivePols_$poldate.txt -append
		}


# Locate non-active policies and output the results to a text file on Gremlin
	
	foreach ($policy in $PolList)
 {
 $NoActivePol = bppllist $policy -L |
 	where-object {$_-match "Active:            no"} 
 $NoActvpol = $policy + " " + $NoActivePol 
 $NoActvpol | 
 	where-object {$_-match "Active:            no"} | 
	foreach-object {$_-replace " Active:            no",""} | Out-File \\gremlin\d$\BKD_LOGS\Policies\NotActivePols_$poldate.txt -append
 
 }
 
 
 # DeActivate the active policies

$getActvPol = gc \\gremlin\d$\BKD_LOGS\Policies\ActivePols_$poldate.txt

foreach ($entry in $getActvPol)
	{
		bpplinfo $entry -modify -inactive

    }