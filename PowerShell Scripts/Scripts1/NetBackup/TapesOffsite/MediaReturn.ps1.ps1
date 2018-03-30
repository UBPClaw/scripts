# ==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: ScratchPoolMedia.ps1
#
# DATE: 11/27/2007
#
# Author: Bryan DeBrun
#
# COMMENT: Tell OPS which tapes to request from iron mountain
# ==============================================================================================



# If the offsitemedia.txt file exists, remove it

remove-Item D:\temp\offsitemedia.txt

# remotely launch the offsitemedia.bat on Gremlin. This will run the netbackup command to query offsite_LT02 volume group
# create the results in the scratch.txt file on gremlin

D:\'Program Files'\VERITAS\Volmgr\bin\vmquery -v offsite_LT02 -W | out-file D:\temp\offsitemedia.txt -append

# Looks at a file created by a netbackup command with a list of tapes that need to go off site.


$offsite = get-content D:\temp\offsitemedia.txt | where-object {$_ -match "  4  Offsite"} | foreach { $_.split(" ", [StringSplitOptions]::RemoveEmptyEntries)[0]}
$offsite



