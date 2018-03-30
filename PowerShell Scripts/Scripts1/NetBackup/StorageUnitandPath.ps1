# ==================================================================================================================
# \\malibu\it\NTServers\Scripts\NetBackup\StorageUnitandPath.ps1
# Date 11/3/2008
# Bryan K. DeBrun
# This script will use the NBU command bpstulist to retreive the storage units used in NBU and their path as well
# ==================================================================================================================


# Remove the current file containing the storage units. If for some reason we want to keep a running record to document changes,
# we can write unique ouput files based on the date. For now we will remove and recreate a new file.

Remove-Item \\gremlin\d$\BKD_LOGS\BackupPaths\NBUstorageU.txt

# Grabbing and scraping the data from the NBU catalog on Gremlin. We are using the NBU command bpstulist with a -U to retrieve
# details on all of the NBU storage units. The -U switch outputs the data in a more usable format.
# We are returning all storage units that do not match the tap drives. We do not need the information for the tape drives.
# We will retrieve the DSSU name only and output it to the variable $gDSSU.

$gDSSU = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpstulist" -U |
	Where-Object {$_-match "Label:"} |
	Where-Object {$_-notmatch "Gremlin-LTO2"} | 
	Where-Object {$_-notmatch "Gremlin-SDLT"} |
	Where-Object {$_-notmatch "Nova-LTO2"} |
	ForEach-Object {$_-replace "Label:                ",""} 
	$gDSSU.count
	
	
# We are still scrapping text but this time we will grab the path only and output it to the $gPath variable.

$gPath = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpstulist" -U |
	Where-Object {$_-match "Path:"}|
	ForEach-Object {$_-replace "Path:                 ",""}| 
	ForEach-Object {$_-replace "`"",""}
    $gPath.count

# Putting it all together. Until I figure a better way, I am retrieving the data captured in the two variables above and outputing
# to one file. There will be a column for the DSSU name and a Column for the DSSU path. The counter $gDSSU.count is the key. We will
# use a loop to return each value in the variables.

$i = 0

	$DSSU = $(while ($i -le $gDSSU.count){$gDSSU[$i]+","+$gPath[$i];$i++}) 
	#"DSSU Name,DSSU Path" | Out-File \\gremlin\d$\BKD_LOGS\BackupPaths\NBUstorageU.txt
	
# Sort and ouput the values from the loop above.

$DSSU | sort | Out-File \\gremlin\d$\BKD_LOGS\BackupPaths\NBUstorageU.txt -append

# We will not view the final output in the console. Use the cls command to clear everything written to the console and
# present the final output. We are using the imprt-csv command to make the output a little for viewer friendly.

cls
#Import-Csv \\gremlin\d$\BKD_LOGS\BackupPaths\NBUstorageU.txt | Format-Table -AutoSize

# After running the script, the console will go away. Pause the output until a key is depressed.

$goaway =Read-Host "Press any key to exit"