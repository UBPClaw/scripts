
$Gtoday = get-date -f M/d/yyyy
$GTodayF = $Gtoday | ForEach-Object {$_-replace "\/","_"}

Function get-Unixdate ($UnixDate) 
{
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}


#$Media = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpmedialist" -l
$Media = "D:\program files\veritas\netbackup\bin\admincmd\bpmedialist" -l


 
# Loop through the output of $logs and scrape away the columns we need. The output is comma delimited.
# We handle null values by assigning it ""
# The split method allows us to grab data at a specific comma.

 foreach ($MedInfo in $Media)
	{
		$MedID = $MedInfo.split(" ")[0]
		$MedAlloc = $MedInfo.split(" ")[4]
		    # BupEndDate UNIX Conversion. Use the function created at the beginning of this script.
			# The 'G' character formats the date\time like 4\16\2009 16:34:53 PM
								$MedAlocated = (get-Unixdate $MedAlloc).Tostring('G')
		
		$MedExpir = $MedInfo.split(" ")[6]
		    # BupEndDate UNIX Conversion. Use the function created at the beginning of this script.
			# The 'G' character formats the date\time like 4\16\2009 16:34:53 PM
								$MedExpired = (get-Unixdate $MedExpir).Tostring('G')
			
		
		$MedVolPl = $MedInfo.split(" ")[12]
		
	$MedID + "," + $MedAlocated + "," + $MedExpired + "," + $MedVolPl | Out-File \\gremlin\d$\BKD_LOGS\Media\MediaTracker\MedTrack_$GTodayF.txt -append
	
	
	}