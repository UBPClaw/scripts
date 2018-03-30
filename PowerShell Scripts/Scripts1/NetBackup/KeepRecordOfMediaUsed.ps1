# ==================================================================================================================
# \\malibu\it\NTServers\Scripts\NetBackup\KeepRecordOfMediaUsed.ps1
# Date 10/24/2008
# Bryan K. DeBrun
# This script keeps a running total of how many tapes we use each day.
# ==================================================================================================================

# Clean up and start again. Until I get the time to make this work without creating text files as a place holder for data,
# we will just have to clean up old files.

remove-Item \\gremlin\d$\temp\MediaList.txt  # This is the orignal out put of the NBU command bpmedialist
remove-Item \\gremlin\d$\temp\media.txt      # This text file contains the date only.

# We will use the NBU command bpmedialist to retrieve all the media in the NBU catalog. The -L gives us the output in a way we can
# actually use it. We will output to a text file. 

psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpmedialist" -L  > \\gremlin\d$\temp\MediaList.txt

# Set the date and then subtract a day. We will be searching the text file for the previous day.

$Findate = (get-date (get-date).AddDays(-1) -f MM/dd/yyyy)

# Scrape the text file and return only the allocated date of the media. Output to Media.txt
# Use the split function to remove everything except the date mm/dd/yyyy.

$mdate = get-content \\gremlin\d$\temp\MediaList.txt | 
	where-object {$_-match "allocated"}| 
	foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[2]} | 
	out-file \\gremlin\d$\temp\Media.txt

	
# Parse the media.txt file just created above, display the previous day and count how many entries exist for
# the previous day. Then display the prvious day and the number. For example, If yester day was 11/2/2008, count
# how many times this date is present in the media.txt file. This represents how many tapes were used on that
# date.

$mlist = get-content \\gremlin\d$\temp\media.txt | where-object {$_-match $findate}
$mcount = $mlist.count
$Mfin = $Findate +" " + $mcount | out-file \\gremlin\d$\temp\MediaCount.txt -append


