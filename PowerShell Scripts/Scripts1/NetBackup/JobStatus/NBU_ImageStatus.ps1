# ==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: NBU_ImageStatus.ps1
#
# Location: \\malibu\it\NTservers\Scripts\NetBackup\Jobstatus
#
# DATE: 4/1/2009  APRIL FOOLS!!!!! :)
#
# Author: Bryan DeBrun
#
# COMMENT: Wow! Where do I begin. This script is capable of doing many helpful things within NetBackup.
# The main purpose is to get a report of all backups for the previous day. With this report, we can see if a backup
# Actually launched, get the total amount of data backed up, get the amount of time a job took to backup up and the list
# goes on. This script uses a couple NETBACKUP commands to dip into the NetBackup database. In the past there were some
# hurdles in making this happen. For one, the time reported by the NETBACKUP command outputs a UNIX time format. I resolved
# this issue using some Date\time conversion code in powershell. 
# ==============================================================================================


# This is the function to convert UNIX time to local time. We will call this function later in the script.

Function get-Unixdate ($UnixDate) 
{
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

$a = New-Object System.Globalization.CultureInfo("da-DK")

Remove-Item D:\BKD_LOGS\JobStatus\WIP\bpimagelist.csv
Remove-Item D:\BKD_LOGS\JobStatus\WIP\report.csv

# We are going to convert this into a CSV file. This will allow us to recognize each column as an object. The CSV file will need a header.
# The next line will create the header.



# Create some DATE/TIME variables. $DlyBupDt returns the day of the week i.e. Tuesday, $BupDt returns the month day and year and subtract one day
# i.e 4/1/2009 -1 = 3/31/2009, $Today simply returns the current date i.e. 4/1/2009

$NullDate = (get-date (get-date).AddDays(-1) -f G)
$DlyBupDt = (get-date (get-date).AddDays(-1) -f dddd)
$BupDt = (get-date (get-date).AddDays(-1) -f M/d/yyyy)
$Today = get-date -f M/d/yyyy
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}


$header = "Policy,Client,BUPID,ClientType,SchedLbl,SchedType,Retention,BupDate,ExpireDate,BupDateEnd,KBS,CopyCount" | Out-File D:\BKD_LOGS\JobStatus\WIP\bpimagelist.csv -append

# Retreive all policies scheduled to run yesterday
# The PolicySchedRPT.csv file must be up to date to get an accurate account of scheduled policies for a particular day.
# You can run the following script to update the file; \\malibu\it\ntservers\scripts\Netbackup\PolicyClientDSUSchedules\NBU_Policy_Schedules.ps1

$GPolScheds = gc \\gremlin\d$\BKD_LOGS\Policies\PolicySchedRpt.csv |
	Where-Object {$_-match $DlyBupDt -and $_-notmatch "000:00:00"} |
	ForEach-Object {$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]}
$GPolScheds


# For each policy scheduled to run yesterday, get the backup details by runnning the NETBACKUP command bpimagelist.
# The -d represents the start date which is yesterday's date, the -e represents the end date which is yesterday at 23:59:59
# Scrape away IMAGE and replace all spaces with commas.
# If for some reason a policy did not launch, we will assign a value of "Job Did Not Run" (JDNR)
# 
foreach ($SchedPolicy in $GPolScheds)

	{

		
		$GJobInfo = bpimagelist -policy $SchedPolicy -d $BupDt -e $BupDt 23:59:59  |
			Where-Object {$_-match "IMAGE"} |
			foreach-object {$_-replace "IMAGE ",""} | 
			foreach-object {$_-replace " ",","} 
			
			if ($GJobInfo -eq $NUL)
				{
					$GJobInfo = "JDNR"
					$GJobInfo
					}
					
									
# After getting all the policy details sperated with commas, we will begin to split job details using the commas. There is way to much useless 
# information returnned by the NETBACKUP command bpimagelist. Therefore, we will select only what we want. This is why we are looping through
# pulling out what we want which will be seperated by a comma. We will then output the results to the CSV file started by the header line above.

			foreach ($deal in $GJobInfo)
							{
							
							
					$Client = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
					
								
									
					$BUPID =  $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[4] 
					
									
					$PolicyNm = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[5]
					
									
					$ClientType = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[6]
					
									
					$SchedLbl = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[9]
						
									
					$SchedType = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[10]
								
									
					$Retention = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[11]
								
									
					
								
# As mentioned in the comments, NETBACKUP returns the DATE TIME STAMP in unix format. We are calling the function created at the beginning
# of this script. The two conversion below contain the jobs start date and time. The datetimestamp returnned by netbackup includes the date
# and time together. We will use the ToShortDateString() and the ToLongTimeString to seperate them. This will give us better searching\reporting
# capabilities. The ("G") is a tostring format for the date and time in this format 4/12/2009 6:00:18 PM
							
							$BupDate = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[12]
							
							#BupDate UNIX Conversion
							$DateConv = (get-Unixdate $BupDate).Tostring('G')
								
					
# We need the $ElpsdTime to calculate the end date\time of the backup. We will not add this field to the report though.
					
					$ElpsdTime = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[13]
					
					
					
# Once again using the UNIX conversion function. This time we are getting the expiration Date.
# The ("G") is a tostring format for the date and time in this format 4/12/2009 6:00:18 PM

                            $ExpirDate = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[14]

							#ExpireDate UNIX Conversion
							$ExpDateConv = (get-Unixdate $ExpirDate).Tostring('G')
						
					

					
# Not only are we calling the UNIX conversion function, we are using the .AddSeconds method to get the completion date of the job.
# The method takes the Backup date and adds the $ElpsTime, which is in seconds. This will give us the Date in which the backup finshed.
# The ("G") is a tostring format for the date and time in this format 4/12/2009 6:00:18 PM
						
							#Completion date UNIX Conversion
							$Bupdatecomplete = (get-Unixdate $BupDate).AddSeconds($ElpsdTime).Tostring('G')

# Not only are we calling the UNIX conversion function, we are using the .AddSeconds method to get the completion time of the job.
# The method takes the Backup date and adds the $ElpsTime, which is in seconds. This will give us the time in which the backup finshed.
#Completion Time UNIX Conversion. So, we will now have a completion date and completion time which will be two seperate fields.
							
													
					$KBS = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[17]
						
					$Copy = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[19]
					
# Handle the polcies that did not run.
								
								if ($deal -eq "JDNR")
								{
									$PolicyNm = "$SchedPolicy"
									$Client = ""
									$BUPID = ""
									$ClientType = ""
									$SchedLbl = ""
									$SchedType = ""
									$Retention = ""
									$DateConv = ""
									$ExpDateConv = ""
									$BupDateComplete = ""
									$KBS = ""
									$Copy = ""
									}
														
# Output the results to a CSV file.								
					$PolicyNm + "," + $Client + "," + $BUPID + "," + $ClientType + "," + $SchedLbl + "," + $SchedType + "," + $Retention + "," + $DateConv + "," + $ExpDateConv + "," + $BupDateComplete + "," + $KBS + "," + $copy | Out-File D:\BKD_LOGS\JobStatus\WIP\bpimagelist.csv -append
					
				}
				
	}
	
# Import and create a file that will seperate on each comma. This will make each column an object which will give us a great deal of options for
# reporting. We import the existing file and export it to a new file.

	Import-Csv D:\BKD_LOGS\JobStatus\WIP\bpimagelist.csv  | export-csv D:\BKD_LOGS\JobStatus\BUPTotals\BUPREPORTS_$FileDate.csv -notype 
	
	Rename-Item D:\BKD_LOGS\JobStatus\WIP\bpimagelist.csv BUPREPORTS_$FileDate.csv
	
$Gfile = Get-ChildItem -Name D:\BKD_LOGS\JobStatus\BUPTotals


foreach ($File in $Gfile)
	{
	
	
	
	
		$Gsum = Import-Csv D:\BKD_LOGS\JobStatus\BUPTotals\$File | where {$_.KBS -ne "-"} |
		measure-object kbs -sum |
		
				
			
		Select-Object @{name="Total Size(MB)";Expression={"{0:N0}" -f ($_.sum)}}
		
		
		foreach ($date in $Gsum)
		
			{
				$File + $date |
				 foreach-object {$_-replace "BUPREPORTS_","" } | 
				 foreach-object {$_-replace ".csv@\{Total Size\(MB\)="," " } |
				 foreach-object {$_-replace "\}","" } |
				 foreach-object {$_-replace "_","/" } | Out-File D:\BKD_LOGS\JobStatus\WIP\Report.csv -append
				}
					
			
	
			  }
	
	
	
	$SendTotalsEmail = gc D:\BKD_LOGS\JobStatus\WIP\Report.csv  
	
	
	
	$body =$SendTotalsEmail | % {$_ +"`n"}
	$sender = "backupadmin@mitchell1.com"
	$recipient = "bryan.debrun@mitchell1.com"
	#$recipient = "backupadmin@mitchell1.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "NBU Report Total Data BUP" 
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)