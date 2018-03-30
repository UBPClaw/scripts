# ==================================================================================================================
# \\malibu\it\NTServers\Scripts\NetBackup\ShowMediaUsedAll.ps1
# Date 10/24/2008
# Bryan K. DeBrun
# This simply opens the text file created in the script KeepRecordOfMediaUsed.ps1. The output will list all days
# Since KeepRecordOfMediaUsed.ps1 started.
# ==================================================================================================================

# Open the text file at the location listed below.

get-content \\gremlin\d$\temp\MediaCount.txt 

$goaway =Read-Host "Press any key to exit"



