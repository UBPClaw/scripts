# ==================================================================================================================
# \\malibu\NTServers\Scripts\NetBackup\Policies\ReActivatingPolicies.ps1
# Date 12/16/2008
# Bryan K. DeBrun
# This script will re-active the policies that were de-activated. This is normally used after de-activate policies in
# the script \\malibu\NTServers\Scripts\NetBackup\Policies\DActivatingPolicies.ps1.
# ==================================================================================================================



# Get the date. We will use it to name our files.

$poldate = Get-Date -F M-dd-yyyy


 
 # Re-Activate the non-active policies

$getActvPol = gc \\gremlin\d$\BKD_LOGS\Policies\ActivePols_$poldate.txt

foreach ($entry in $getActvPol)
	{
		psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpplinfo" $entry -modify -active

    }