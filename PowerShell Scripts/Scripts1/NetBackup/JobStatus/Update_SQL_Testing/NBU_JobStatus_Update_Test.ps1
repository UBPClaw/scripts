# ==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: NBU_GrabLogsFromConsole.ps1
#
# Location: \\malibu\it\NTservers\Scripts\NetBackup\Jobstatus\NBU_GrabLogsFromConsole.ps1
#
# DATE: 4/17/2009
#
# Author: Bryan DeBrun
#
# COMMENT: This script runs the netbackup command bpdbjobs which reports on all job activity that hits the 
#          NBU console. We will scrape out what we need from the log and create our own report. This report
#          will be imported into a SQL 2005 database via an SSIS package.
# ==============================================================================================
 
 
 # This is the function to convert UNIX time to local time. We will call this function later in the script.

Function get-Unixdate ($UnixDate) 
{
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

# Remove the temporary text files used to create our report


 
Remove-Item D:\BKD_LOGS\NBULOGS\TEST\NBULogsToSQL.txt
Remove-Item D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs.txt                                  
Remove-Item D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs1.txt


# Get yesterday's date by subtracting from the current date. Use that date to create one of our output files.
# The OS doesn't allow the / character. We will replace it with the _ character. 

$BupDt = (get-date (get-date).AddDays(-1) -f M/d/yyyy)
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}
$BupDtDay = (get-date (get-date).AddDays(-1) -f dddd)

# Get the current date and time in this format 11/1/2009 11:30:03 PM"

$GNow1 = Get-Date -Format G
$GNow = $GNow1 | ForEach-Object {$_-replace "\/", "_"} | ForEach-Object {$_-replace ":","_"}


 

# Run the NBU command and assign it a variable of $Logs.
 
 $Logs = bpdbjobs -ignore_parent_jobs -most_columns 
 
 
# Loop through the output of $logs and scrape away the columns we need. The output is comma delimited.
# We handle null values by assigning it ""
# The split method allows us to grab data at a specific comma.

 foreach ($line in $logs)
	{
		$Jobid = $line.split(",")[0]
		
			if ($jobid -eq "")
			
				{
						$Jobid = "NA"
				}
			
		$Jobtype = $line.split(",")[1]
		
			if ($Jobtype -eq "")
			
				{
						$Jobtype = "NA"
				}
		
		$JobState = $line.split(",")[2]
			if ($JobState -eq "")
			
				{
						$JobState = "NA"
				}
				
		$JobStatus = $line.split(",")[3]
			if ($JobStatus -eq "") 
			
				{
						$JobStatus = "50" # I created the code 50. It simply means the job is still running.
				}
		
		$Policy = $line.split(",")[4]
			if ($Policy  -eq "")
			
				{
						$Policy  = "NA"
				}
		
		$Schedule = $line.split(",")[5]
			if ($Schedule  -eq "")
			
				{
						$Schedule  = "NA"
				}
				
		$Client = $line.split(",")[6]
			if ($Client  -eq "")
			
				{
						$Client  = "NA"
				}
		
		$MedServer = $line.split(",")[7]
			if ($MedServer  -eq "")
			
				{
						$MedServer  = "NA"
				}
				
		$BupBegn = $line.split(",")[8]
			if ($BupBegn  -eq "")
			
				{
						$BupBegn  = "0/00/0000 00:00:00"
				}
					# BupStartDate UNIX Conversion. Use the function created at the beginning of this script.
					# The 'G' character formats the date\time like 4\16\2009 16:34:53 PM
							$BupStart = (get-Unixdate $BupBegn).Tostring('G')
				
		
		$BupComplt = $line.split(",")[10]
			if ($BupComplt -eq "")
			
				{
					$BupComplt  = $GNow1 #.Tostring.('G')				
				}
																	
						else
														
							{
								# BupEndDate UNIX Conversion. Use the function created at the beginning of this script.
								# The 'G' character formats the date\time like 4\16\2009 16:34:53 PM
								$BupEnd = (get-Unixdate $BupComplt).Tostring('G')								
							}
														
								if ( $BupEnd -eq "12/31/1969 4:00:00 PM")
							
								{
									$BupEnd  = ""
								}
								
								
									if ( $BupEnd -eq "")
							
									{
										$BupEnd  = $GNow1 #.Tostring.('G')
									}
								
								
									
									
											
			
		$StrgUnt = $line.split(",")[11]
			if ($StrgUnt  -eq "")
			
				{
						$StrgUnt  = "NA"
				}
					elseif ($StrgUnt  -eq " ")
					
						{
							$StrgUnt  = "NA"
						}
		
		$KBS = $line.split(",")[14]
			if ($KBS  -eq "")
			
				{
						$KBS  = "0"
				}
		
		$Files = $line.split(",")[15]
			if ($Files  -eq "")
			
				{
						$Files  = "0"
				}
		
		$BupID = $line.split(",")[51]
			if ($BupID  -eq "")
			
				{
						$BupID  = "NA"
				}
				
		$BupCopy = $line.split(",")[35]
			if ($BupCopy -eq "")
			
				{
						$BupCopy  = "0"
				}
				
				# After scraping away what we need, recompile it into a comman delimited line of text and then output it
				
		 		$Jobid + "," + $Jobtype + "," + $JobState + "," + $JobStatus + "," + $Policy + "," + $Schedule + "," + $Client + "," + $MedServer + 
				 "," + $BupStart + "," + $BupEnd + "," + $StrgUnt + "," + $KBS + "," + $Files + "," + $BupID + "," + $BupCopy | Out-File D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs1.txt -append
				 
				 
	}
 
 
 gc D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs1.txt |

               foreach {$_-replace "Gremlin-Nova","TAPE"} |
			   foreach {$_-replace "Nova-LTO2","TAPE"} |
			   foreach {$_-replace "Gremlin-LTO2","TAPE"} | Out-File D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs.txt -append
  
 # Get content from the file created above. Create some filters to get only what was backed up the previous date. Split on particular commas to
 # filter one what we need or don't need. Basically, we are getting rid of entries like duplication jobs and keepint only backup jobs. We are also
 # Filtering on the copy count of the job. If we don't we can get duplicates. Some policies create multiple copies.
 
 gc D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs.txt | Where-Object {$_.split(",")[1] -ne "2" -and $_.split(",")[11] -ne "0"-and $_.split(",")[14] -lt "2" } | Out-File D:\BKD_LOGS\NBULOGS\TEST\NBULogsToSQL.txt -append
 
 #gc D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs.txt | Where-Object {$_.split(",")[8] -match $BupDt -and $_.split(",")[11] -ne "0"-and $_.split(",")[14] -lt "2" } | Out-File D:\BKD_LOGS\NBULOGS\TEST\NBULogsToSQL_$FileDate.txt -append
 
 # Rename the temporary file created with the previous date. This allows us to go back to the file in the event that we need to bring the data back
 # in or want to account for duplication jobs or any other type of job that is not outputed. This file contains all data as extracted previously
 # with the NBU command bpdbjobs
 
 #Rename-Item D:\BKD_LOGS\NBULOGS\TEST\NbuTempLogs.txt NBULOGS_$GNow.txt
 
 #$GNow = Get-Date -Format G
 
  Rename-Item \\gremlin\d$\BKD_LOGS\NBULOGS\TEST\NbuTempLogs.txt NBULOGS_$GNow.txt
 

 
 #$Gnow
 

 
 # TESTING Some sample filters if we need to test. Of course we should test them using another file and not this one.
 
 # gc c:\test\NbuTempLogs.txt | Where-Object {$_.split(",")[9] -match "NA"} | Out-File c:\test\YESMan.txt
 
 #gc \\gremlin\d$\BKD_LOGS\NBULOGS\NbuTempLogs.txt | Where-Object {$_.split(",")[8] -match $BupDt -and $_.split(",")[5] -match "Weekly" -and $_.split(",")[11] -notmatch "0"-and $_.split(",")[14] -lt "2" } | Out-File \\gremlin\d$\BKD_LOGS\NBULOGS\NBULogs.txt
 
 
 
 
 
 
 
 
 
 
 
 
 