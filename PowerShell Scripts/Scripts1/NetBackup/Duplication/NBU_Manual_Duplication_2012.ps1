# ==========================================================================================================
# 
# Microsoft PowerShell File 
# 
# NAME: NBU_DSSU_Images_Duplicated.ps1
# 
# DATE: 2-17-2009
#
# Author: Bryan DeBrun
#
# Location \\malibu\it\NTServers\Scripts\NetBackup\Duplication\NBU_Manual_Duplication.ps1
#
# COMMENT: This script;  This is mainly for NDMP policies. NDMP policies are unable to create multiple copies of a backup. So, copy number 1
#                        is the original copy to disk. Copy number 2 is the onsite copy and is created using the staging schedule. We will use
#                        a NBU duplication command to manually duplicate and create a 3rd copy.
# 1. Gets a distinct\unique list of images stored in a Storage unit (DSSU).
# 2. Scrapes away the unwanted text in the file name of an image and output the actual backup id to a text file.
# 3. Outputs the BackupId and a copy number for each backup id to a text file.
# 4. If the copy count is 2, run NBU command to manually create a 3rd copy for offsite. (Copy1 = Disk Copy 2 = Onsite Copy 3 = Offsite)
## ==========================================================================================================




# Get the path of the storage unit. In the future, we will search on all storage units.

$gpath = "\\nova\H$"

# Create the output file names. We want to give the file name the actual path of the storage unit without the back slashes.

$rpath = $gpath | foreach-object {$_-replace "\\\\","" } | foreach-object {$_-replace "\\","_" }
$dupgood = $gpath | foreach-object {$_-replace "\\\\","" } | foreach-object {$_-replace "\\","_" }
$RemoveChar = $dupgood.split("$",[StringSplitOptions]::RemoveEmptyEntries)[0]

# We want to work with fresh text files.
# Remove existing text files.


Remove-Item D:\BKD_LOGS\Duplication\DuplicateThis\NeedDuped_$RemoveChar.txt
Remove-Item D:\BKD_LOGS\Duplication\DuplicateThis\DupCheck_$RemoveChar.txt
Remove-Item D:\BKD_LOGS\Duplication\DuplicateThis\Duped_$RemoveChar.txt


# Get a list of all objects in the Storage Unit path. There are many fragments of the same immage
# Each image has many fragments. We need to return one file per image. We will do this by
# grabbing only those files that contain HDR and note .img
# We will then get rid of all the extra characters in the client for each loop. We want the unique backup id
# An example of a backup id before scaping the unwanted characters; gremlin_1232935542_C1_HDR.1232935542.info
# An example of the desired backup id gremlin_1232935542
# Last step of getting the backup id is sending the unqique backup ids stored in the Storage unit to a text file.

$client = get-childitem -Name $gpath | where-object {$_-match "HDR" -and $_-notmatch ".img"} 
	 

		foreach ($item in $client)
		{
			
			$1 = $item.split("_",[StringSplitOptions]::RemoveEmptyEntries)[0] 
			$2 = $item.split("_",[StringSplitOptions]::RemoveEmptyEntries)[1] 
			#$final = $1 + "_" + $2 | Out-File	D:\BKD_LOGS\Duplication\DuplicateThis\DupCheck_$RemoveChar.txt -append
			 $final = $1 + "_" + $2
			 $final | Out-File D:\BKD_LOGS\Duplication\DuplicateThis\DupCheck_$RemoveChar.txt -append
			}


# For each BackupId in the file below, get the copy number. Using a split to scrape away everything but the copy number located in 20th space
# If the copy number = 3 then create a text file stating the backupid has the required copies
# If the copy number =2 then use the NBU command to create an off site copy, the 3rd copy

$BupID = gc D:\BKD_LOGS\Duplication\DuplicateThis\DupCheck_$RemoveChar.txt


foreach ($Copy in $BupID )
	{
	bpimagelist -l -backupid $Copy
	# Use the line below if you are not running this from Gremlin
	$gcopynum = bpimagelist -l -backupid $Copy | 
		Where-Object {$_-notmatch "FRAG"} | 
		Where-Object {$_-notmatch "HISTO"} | 
		foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[20]}
		if ($gcopynum  -gt 1)
		{		
		    $Copy + " " + $gcopynum | Out-file D:\BKD_LOGS\Duplication\DuplicateThis\Duped_$RemoveChar.txt -append
			}
			else
			{
				$Copy + " " + $gcopynum | Out-file D:\BKD_LOGS\Duplication\DuplicateThis\NeedDuped_$RemoveChar.txt -append
			     
				 
				 
				 # Un comment this when ready to duplicate
				 # bpduplicate -backupid $copy -dstunit Gremlin-Nova -dp Offsite -rl 3
				 
				 # Use the line below if you are not running this from Gremlin
				 # psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpduplicate" -backupid $copy -dstunit Gremlin-Nova -dp Offsite
				}

}





