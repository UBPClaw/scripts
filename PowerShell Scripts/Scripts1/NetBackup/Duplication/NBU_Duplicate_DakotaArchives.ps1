Function get-Unixdate ($UnixDate) 
{
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

# Remove the temporary text files used to create our report

Remove-Item D:\BKD_LOGS\NBULOGS\NbuTempLogs.txt                                  
Remove-Item D:\BKD_LOGS\NBULOGS\NBULogsToSQL.txt


# Get yesterday's date by subtracting from the current date. Use that date to create one of our output files.
# The OS doesn't allow the / character. We will replace it with the _ character. 

$BupDt = (get-date (get-date).AddDays(-1) -f M/d/yyyy)
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}
 

# Run the NBU command and assign it a variable of $Logs.
 
 $Logs = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpdbjobs" -ignore_parent_jobs -most_columns
 
 $logs | Where-Object {$_.split(",")[4] -match "FILER_Dakota_Archives_DD1" -and $_.split(",")[5] -match "Weekly" }
 
 if ($logs = $NUL)
 ,
 		{
			notepad.exe
			
			}
			
			else
			
				{
				
					write-host "COOL"
					
				}