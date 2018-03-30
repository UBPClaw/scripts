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


 

#Remove-Item D:\BKD_LOGS\NBULOGS\Duplications\ManualDuplication\ManDup.txt                                  
#Remove-Item D:\BKD_LOGS\NBULOGS\NBULogsToSQL.txt


# Get yesterday's date by subtracting from the current date. Use that date to create one of our output files.
# The OS doesn't allow the / character. We will replace it with the _ character. 

$BupDt = (get-date (get-date).AddDays(-1) -f M/d/yyyy)
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}


 
Do
{

remove-item \\gremlin\d$\BKD_LOGS\Duplication\ManulDuplication\ManDup.txt

# Run the NBU command and assign it a variable of $Logs.
 
 $Logs = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpdbjobs" -ignore_parent_jobs -most_columns 
 
 
# Loop through the output of $logs and scrape away the columns we need. The output is comma delimited.
# We handle null values by assigning it ""
# The split method allows us to grab data at a specific comma.

 foreach ($line in $logs)
	{
					
		$JobState = $line.split(",")[2]
			if ($JobState -eq "")
			
				{
						$JobState = "NA"
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
					$BupComplt  = "0/00/0000 00:00:00"				
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
			
				
		
		$BupID = $line.split(",")[51]
			if ($BupID  -eq "")
			
				{
						$BupID  = "NA"
				}
				
						
				# After scraping away what we need, recompile it into a comman delimited line of text and then output it
				
		 		$JobState + "," + $Policy + "," + $Schedule +  
				 "," + $BupStart + "," + $BupEnd + "," + $BupID  | Out-File \\gremlin\d$\BKD_LOGS\Duplication\ManulDuplication\ManDup.txt -append
				 
				 
	}
 
  
 # Get content from the file created above. Create some filters to get only what was backed up the previous date. Split on particular commas to
 # filter one what we need or don't need. Basically, we are getting rid of entries like duplication jobs and keepint only backup jobs. We are also
 # Filtering on the copy count of the job. If we don't we can get duplicates. Some policies create multiple copies.
  gc \\gremlin\d$\BKD_LOGS\Duplication\ManulDuplication\ManDup.txt | Where-Object{$_.split(",")[1] -match "NT_ProductCentral_Active_Data_Web" -and $_.split(",")[2] -match "Weekly"}| Out-File \\gremlin\d$\BKD_LOGS\Duplication\ManulDuplication\ManDupTarg.txt # -and {$_.split(",")[8] -match $BupDt -and $_.split(",")[11] -ne "0"-and $_.split(",")[14] -lt "2" } | Out-File D:\BKD_LOGS\NBULOGS\NBULogsToSQL.txt
 "Job Still Active" | Out-File \\gremlin\d$\BKD_LOGS\Duplication\ManulDuplication\JobStilActive.txt
 
 
 
 
	
	}
 		until ($JobState -eq 3)
 
 
 "This will work!" | Out-File  \\gremlin\d$\BKD_LOGS\Duplication\ManulDuplication\Work.txt
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 