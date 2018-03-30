# This is the function to convert UNIX time to local time. We will call this function later in the script.

Function get-Unixdate ($UnixDate) 
{
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}


Remove-Item  D:\BKD_LOGS\MonthEnd\MonthEndRpt.csv

Remove-Item  D:\BKD_LOGS\MonthEnd\BupPathsRpt.csv

Remove-Item  D:\BKD_LOGS\MonthEnd\BUpClientRpt.csv

Remove-Item  D:\BKD_LOGS\MonthEnd\MonthEMediaRpt.csv


# We are going to convert this into a CSV file. This will allow us to recognize each column as an object. The CSV file will need a header.
# The next line will create the header.
$header = "Policy,Client,BUPID,ClientType,SchedLbl,SchedType,Retention,BupDate,BupTime,TimeTaken,ExpireDate,ExpireTime,BupDateEnd,BupTimeEnd,KBS,CopyCount"| Out-File \\gremlin\d$\BKD_LOGS\MonthEnd\MonthE.csv -append


# Create some DATE/TIME variables. $DlyBupDt returns the day of the week i.e. Tuesday, $BupDt returns the month day and year and subtract one day
# i.e 4/1/2009 -1 = 3/31/2009, $Today simply returns the current date i.e. 4/1/2009

$DlyBupDt = (get-date (get-date).AddDays(-1) -f dddd)
$BupDt = (get-date (get-date).AddDays(-7) -f M/d/yyyy)
$Today = get-date -f M/d/yyyy
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}

$GJobInfo = bpimagelist  -sl Monthly -d $BupDt -e $Today 23:59:59 |
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
								
									
					$BupDate = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[12]
								
# As mentioned in the comments, NETBACKUP returns the DATE TIME STAMP in unix format. We are calling the function created at the beginning
# of this script. The two conversion below contain the jobs start date and time. The datetimestamp returnned by netbackup includes the date
# and time together. We will use the ToShortDateString() and the ToLongTimeString to seperate them. This will give us better searching\reporting
# capabilities.
							#BupDate UNIX Conversion
							$DateConv = (get-Unixdate $BupDate).ToShortDateString()
								
							$BupTime = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[12]
								
							#BupTIME UNIX Conversion
							$TimeConv = (get-Unixdate $BupDate).ToLongTimeString()
						
					
					$ElpsdTime = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[13]
					
					$ExpirDate = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[14]
					
# Once again using the UNIX conversion function. This time we are getting the expiration Date.

							#ExpireDate UNIX Conversion
							$ExpDateConv = (get-Unixdate $ExpirDate).ToShortDateString()
						
					        $ExpirTime = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[14]

# Once again using the UNIX conversion function. This time we are getting the expiration Time.
					
							#ExpireTime UNIX Conversion
							$ExpTimeConv = (get-Unixdate $ExpirDate).ToLongTimeString()
							
# Not only are we calling the UNIX conversion function, we are using the .AddSeconds method to get the completion date of the job.
# The method takes the Backup date and adds the $ElpsTime, which is in seconds. This will give us the Date in which the backup finshed.
						
							#Completion date UNIX Conversion
							$Bupdatecomplete = (get-Unixdate $BupDate).AddSeconds($ElpsdTime).ToShortDateString()

# Not only are we calling the UNIX conversion function, we are using the .AddSeconds method to get the completion time of the job.
# The method takes the Backup date and adds the $ElpsTime, which is in seconds. This will give us the time in which the backup finshed.
#Completion Time UNIX Conversion. So, we will now have a completion date and completion time which will be two seperate fields.
							
							$BupTimeComplete = (get-Unixdate $BupDate).AddSeconds($ElpsdTime).ToLongTimeString()
						
					$KBS = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[17]
						
					$Copy = $deal.split(",",[StringSplitOptions]::RemoveEmptyEntries)[19]
					
# Handle the polcies that did not run.
								
								if ($deal -eq "JDNR")
								{
									$PolicyNm = $SchedPolicy
									$Client = "-"
									$BUPID = "-"
									$ClientType = "-"
									$SchedLbl = "-"
									$SchedType = "-"
									$Retention = "-"
									$DateConv = "-"
									$TimeConv = "-"
									$ElpsdTime = "-"
									$ExpDateConv = "-"
									$ExpTimeConv = "-"
									$BupDateComplete = "-"
									$BupTimeComplete = "-"
									$KBS = "-"
									$Copy = "-"
									}
														
# Output the results to a CSV file.								
					$PolicyNm + "," + $Client + "," + $BUPID + "," + $ClientType + "," + $SchedLbl + "," + $SchedType + "," + $Retention + "," + $DateConv + "," + $TimeConv + "," + $ElpsdTime + "," + $ExpDateConv + "," + $ExpTimeConv + "," + $BupDateComplete + "," + $BupTimeComplete + "," + $KBS + "," + $copy | Out-File \\gremlin\d$\BKD_LOGS\MonthEnd\MonthE.csv -append 
					
				}
				
	
	
# Import and create a file that will seperate on each comma. This will make each column an object which will give us a great deal of options for
# reporting. We import the existing file and export it to a new file.

	Import-Csv D:\BKD_LOGS\MonthEnd\MonthE.csv | export-csv D:\BKD_LOGS\MonthEnd\MonthEndRpt.csv -notype
	
	Remove-Item D:\BKD_LOGS\MonthEnd\MonthE.csv
	
	
# ************************************ Locate the Media used for Month End and determine it's location ********************************

$Header2 = "Policy,MediaID,Expiration,Location"
$Header2 | out-file \\gremlin\d$\BKD_LOGS\MonthEnd\MonthEMedia.csv -append

$GMMedia = gc d:\BKD_LOGS\MonthEnd\MonthEndRpt.csv |
	where {$_-match "NT_CIS_After_MonthEnd" -or $_-match "NT_CIS_Before_MonthEnd" -or $_-match "FILER_Finance_MonthEnd"} 
	#$GMMedia
	
	foreach ($item in $GMMedia)
	{
	$Policy = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
	$BUPID = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
	#$Policy
	#$BUPID
	
	foreach ($BUP in $BUPID)
	{
	$GBupInfo = bpimagelist -backupid $BUP |
		Where-Object {$_-match "FRAG"} |
		ForEach-Object {$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]} | Sort-Object -unique 
		
		foreach ($ID in $GBupInfo)
			{
				$GTapeInfo = bpmedialist -m $ID -L |
					Where-Object {$_-match "expiration"} |
						ForEach-Object {$_-replace "expiration = ",""} |
						Foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
						foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
						
						
						$MedPool = bpmedialist -m $ID -L |
						Where-Object {$_-match "vmpool"}
			
							if ($MedPool  -eq "vmpool = 10")
			                  	
								{
									$MedPool  = "Onsite"
								}
					
							elseif ($MedPool  -eq "vmpool = 9")
					
								{
									$MedPool  = "Offsite"
								}
								
								elseif ($MedPool  -eq "vmpool = 5")
					
								{
									$MedPool  = "Off Long"
								}
				
				$Policy + "," + $ID + "," + $GTapeInfo + "," + $MedPool | out-file D:\BKD_LOGS\MonthEnd\MonthEMedia.csv -append
						
				
				}
		
	
	
	}
	
	}
	
	Import-Csv D:\BKD_LOGS\MonthEnd\MonthEMedia.csv | export-csv D:\BKD_LOGS\MonthEnd\MonthEMediaRpt.csv -notype
	Remove-Item D:\BKD_LOGS\MonthEnd\MonthEMedia.csv
# **************************************  Get the Backup Paths for the MonthEnd Backup Policies ******************************************

$header3 = "Policy,BupPath"
$header3 | Out-File D:\BKD_LOGS\MonthEnd\BupPaths.csv -append

$gP = bppllist |
	Where-Object {$_-match "NT_CIS_After_MonthEnd" -or $_-match "NT_CIS_Before_MonthEnd" -or $_-match "FILER_Finance_MonthEnd"}


foreach ($gPolicy in $gP)
{
$gPPath = bppllist $gPolicy -L |
	              Where-Object {$_ -match "INCLUDE" -and
				                $_ -notmatch "NEW_STREAM"} |
				  foreach-object {$_-replace "Include:           ","$gPolicy," } | 
				  Out-File D:\BKD_LOGS\MonthEnd\BupPaths.csv -append
				  
}

Import-Csv D:\BKD_LOGS\MonthEnd\BupPaths.csv | export-csv D:\BKD_LOGS\MonthEnd\BupPathsRpt.csv -notype
Remove-Item D:\BKD_LOGS\MonthEnd\BupPaths.csv
# ************************************* Get the Clients for the MonthEnd Backup Policies ************************************************

$Header4 = "Policy,Client"
$Header4 | Out-File D:\BKD_LOGS\MonthEnd\BUpClient.csv -append

$gClient = bppllist |
Where-Object {$_-match "NT_CIS_After_MonthEnd" -or $_-match "NT_CIS_Before_MonthEnd" -or $_-match "FILER_Finance_MonthEnd"}



foreach ($Client in $gClient)
{
$gPClient = bppllist $Client -L |
	              Where-Object {$_ -match "Client/HW/OS/Pri:"} |
				  foreach-object {$_-replace "Client/HW/OS/Pri:  ","$Client," } |
				  foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
				  Out-File D:\BKD_LOGS\MonthEnd\BUpClient.csv -append
				  
	}			 
	
	Import-Csv D:\BKD_LOGS\MonthEnd\BUpClient.csv | export-csv D:\BKD_LOGS\MonthEnd\BUpClientRpt.csv -notype
	Remove-Item D:\BKD_LOGS\MonthEnd\BUpClient.csv
				  
				  
# ************************************* E-Mail Report ***********************************************************************************



$1 = Import-Csv D:\BKD_LOGS\MonthEnd\BUpClientRpt.csv | Select Policy,Client | out-string
$2 = Import-Csv D:\BKD_LOGS\MonthEnd\MonthEMediaRpt.csv | Select Policy,MediaID,Expiration,Location | Sort-Object Policy,Location | out-string
$3 = Import-Csv D:\BKD_LOGS\MonthEnd\BupPathsRpt.csv | Select Policy,BupPath | out-string

$Expl = "For onsite backups, it is normal to see more than once pice of media associated with the onsite backup. `n 
The onsite backups are mixed with other backups. However, unless the data is to large to fit on one piece `n 
of media, you should see only one pice of media per offlong backup. `n`n" 

$Exp2 = "If you see that one of the Month End policies is missing an on site copy, an off long copy, `n 
or even both, notify BACKUPADMIN. We will most likely have to manually create the missing copy `n 
This will nee to happen prior to the next day end period. `n" 
	 
		
	
			 
				
				
	$body = $1+$2+$3+"`n"+ $Expl + "`n" + $Exp2 
	$sender = "backupadmin@mitchell1.com"
	$recipient = "bryan.debrun@mitchell1.com"
	#$recipient = "backupadmin@mitchell1.com"
	$server = "smtp.corp.mitchellrepair.com"
	$subject = "Month End Backup Report" 
	$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
	$client = new-object System.Net.Mail.SmtpClient $server
	$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
	$client.Send($msg)
				  
