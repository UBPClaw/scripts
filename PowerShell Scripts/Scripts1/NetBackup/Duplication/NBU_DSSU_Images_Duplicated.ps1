# ==========================================================================================================
# 
# Microsoft PowerShell File 
# 
# NAME: NBU_DSSU_Images_Duplicated.ps1
# 
# DATE: 1-23-2009
#
# Author: Bryan DeBrun
#
# Location \\malibu\it\NTServers\Scripts\NetBackup\Duplication
#
# COMMENT: This script; 
# 1. Gets a distinct\unique list of images stored in a Storage unit (DSSU).
# 2. Scrapes away the unwanted text in the file name of an image and output the actual backup id to a text file.
# 3. Outputs the BackupId and a copy number for each backup id to a text file.
# 4. Outputs a summary of each backupid to a text file.
# 5. In addition to text files, sends the output to the console.
# ==========================================================================================================

# Get the path of the storage unit. In the future, we will search on all storage units.

#$gpath = "\\m1ddlocal\backup\poway\DakotaUser\WEEKLY"
#$gpath = "\\m1ddlocal\backup\poway\OS\WEEKLY"
#$gpath = "\\m1ddlocal\backup\poway\DakotaArchives\WEEKLY"
#$gpath = "\\nova\l$\DSSU"
#$gpath = "\\nova\k$\DSSU"
#$gpath = "\\m1ddlocal\backup\poway\dakota"
#$gpath = "\\m1ddlocal\backup\poway\cis\WEEKLY"
#$gpath = "\\m1ddlocal\backup\poway\MEPS\WEEKLY"
$gpath = "h:"

# Create the output file names. We want to give the file name the actual path of the storage unit without the back slashes.

$rpath = $gpath | foreach-object {$_-replace "\\\\","" } | foreach-object {$_-replace "\\","_" }
$dupgood = $gpath | foreach-object {$_-replace "\\\\","" } | foreach-object {$_-replace "\\","_" }
# We want to work with fresh text files.
# Remove existing text files.

Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\$rpath.txt
Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\Duplicated\Duped_$dupgood.txt
Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\CopyCount\CpyCount_$dupgood.txt
Remove-Item \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\IMGstat_$dupgood.txt 
Remove-Item \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\Compiled\CompiMGstat_$dupgood.txt

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
			$final = $1 + "_" + $2 | Out-File	\\gremlin\d$\BKD_LOGS\Duplication\Duplicated\Duped_$dupgood.txt -append
			}
 
# Get the details of the backup id.
# Retreive the backup ids from the text file created above.
# For each backup id in the text file, use the NBU command bpimagelist to return the details of the backup id.
# Each backup id contains alot of details about the image. In the for each statement below, we will return only how many
# copies of the backup exist. 
# Finally, output the back id and the copy count to a text file.

$GetImage = gc \\gremlin\d$\BKD_LOGS\Duplication\Duplicated\Duped_$dupgood.txt

foreach ($image in $GetImage)
{
$CopyCount = pbpimagelist -backupid $image |
	Where-Object {$_-match "IMAGE"} |  
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[20]} 
	$image + " " + $CopyCount | Out-File	\\gremlin\d$\BKD_LOGS\Duplication\CopyCount\CpyCount_$dupgood.txt -append
	
	}


	$GetBupImage = gc \\gremlin\d$\BKD_LOGS\Duplication\Duplicated\Duped_$dupgood.txt
	"BUP DATE          Expires       Files    KB      C  Sched Type          Policy                        Backup ID"| Out-File \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\IMGstat_$dupgood.txt -append
	"-----------------------------------------------------------------------------------------------------------------------------" | Out-File \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\IMGstat_$dupgood.txt -append
	foreach ($bupImage in $GetBupImage)
	{
	
	$iout = bpimagelist -backupid $bupImage -U | 
		Where-Object {$_-notmatch "Backed Up"} |
		Where-Object {$_-notmatch "-"} 
		
		#$fout = $iout + " " + $bupimage  
		
		"{0,-103} {1,-25}" -f $iout,$bupimage  | Out-File \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\IMGstat_$dupgood.txt -append
	
	}
	gc \\gremlin\d$\\BKD_LOGS\BUPImages\ImageStatus\IMGstat_$dupgood.txt | Out-File \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\Compiled\CompiMGstat_$dupgood.txt -Append
	"`n" | Out-File \\gremlin\d$\\BKD_LOGS\BUPImages\ImageStatus\Compiled\CompiMGstat_$dupgood.txt -Append
	"Copy Count Per Image" | Out-File \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\Compiled\CompiMGstat_$dupgood.txt -Append
	"---------------------"  | Out-File \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\Compiled\CompiMGstat_$dupgood.txt -Append
	gc \\gremlin\d$\BKD_LOGS\Duplication\CopyCount\CpyCount_$dupgood.txt | Out-File \\gremlin\d$\BKD_LOGS\BUPImages\ImageStatus\Compiled\CompiMGstat_$dupgood.txt -Append
	
	gc \\gremlin\d$\BKD_LOGS\Duplication\CopyCount\CpyCount_$dupgood.txt 
	"`n"
	gc \\gremlin\d$\\BKD_LOGS\BUPImages\ImageStatus\IMGstat_$dupgood.txt | format-wide