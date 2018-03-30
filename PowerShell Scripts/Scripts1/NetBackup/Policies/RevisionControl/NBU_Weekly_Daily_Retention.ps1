# ==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: NBU_GrabLogsFromConsole.ps1
#
# Location: \\malibu\it\NTServers\Scripts\NetBackup\Policies\NBU_Weekly_Daily_Retention.ps1
#
# DATE: 1/18/2010
#
# Author: Bryan DeBrun
#
# COMMENT: This script digs the retention level for each backup copy in each policy.
# The schedules could be daily, weekly or monthly. It is possible that each schedule
# could contain multiple copies with different retention levels. 
# The output will be a comma delimited text file which will be imported into a SQL table
# for reporting purposes.
# ==============================================================================================

# Set current date and time
$RenameDate = get-date -f Mdyyy

# Clean up
Rename-Item d:\BKD_LOGS\policies\DailyRet.txt DailyRet_$RenameDate.txt
Remove-Item d:\BKD_LOGS\policies\DailyRet.txt


#################################### 
#          Daily SCHEDULE
####################################

# Set the schedule variable
$Schedule = "Daily"

# Get a list of all policies
$Policy = bppllist

# Loop through each policy to get the retention level for any copy in the
# daily schedule

foreach ($pol in $policy)
	{

		$PolicyRetention = bpplsched $pol -label $Schedule -U |
			Where-Object {$_-match "Retention Level:"}
		$PolicyRetention = $PolicyRetention.substring(19) 
						
			if ($PolicyRetention -eq $NUL)
				{
					$PolicyRetention = "NA"
						
				}
								
		$FinalRetention = $pol + "," + $Schedule + "," + $PolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace "\(",","} |
			ForEach-Object {$_-replace "\)",","} |
			foreach-object{$_-replace"\)",","}|
			foreach-object{$_-replace" ,",","}|
			foreach-object{$_.TrimEnd(",")} |
			Out-File d:\BKD_LOGS\policies\DailyRet.txt -append
		
	}
			
			

#################################### 
#          WEEKLY SCHEDULE
####################################

$WeeklyPolicy = bppllist

# Set the schedule variable
$WeeklySchedule = "Weekly"


foreach ($Weeklypol in $Weeklypolicy)
	{

		$WeeklyPolicyRetention = bpplsched $Weeklypol -label $WeeklySchedule -U |
			Where-Object {$_-match "Retention Level:"}
		$WeeklyPolicyRetention = $WeeklyPolicyRetention.substring(19) 
					
			if ($WeeklyPolicyRetention -eq $NUL)
			{
				$WeeklyPolicyRetention = "NA"
			}
				
		$WeeklyFinalRetention1 = $Weeklypol + "," + $WeeklySchedule + "," + $WeeklyPolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace "\(",","} |
			ForEach-Object {$_-replace "\)",","} |
			#foreach-object{$_-replace"\)",","}|
			foreach-object{$_-replace" ,",","}
			foreach-object{$_.TrimEnd(",")} |
			Out-File d:\BKD_LOGS\policies\DailyRet.txt -append
	
	}
	
	
	
#################################### 
#          Monthly SCHEDULE
####################################

$MonthlyPolicy = bppllist

# Set the schedule variable
$MonthlySchedule = "Monthly"


foreach ($Monthlypol in $MonthlyPolicy)
	{

		$MonthlyPolicyRetention = bpplsched $Monthlypol -label $MonthlySchedule -U |
			Where-Object {$_-match "Retention Level:"}
		$MonthlyPolicyRetention = $MonthlyPolicyRetention.substring(19) 
					
			if ($MonthlyPolicyRetention -eq $NUL)
			{
				$MonthlyPolicyRetention = "NA"
			}
				
		$MonthlyFinalRetention1 = $Monthlypol + "," + $MonthlySchedule + "," + $MonthlyPolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace "\(",","} |
			ForEach-Object {$_-replace "\)",","} |
			#foreach-object{$_-replace"\)",","}|
			foreach-object{$_-replace" ,",","}
			foreach-object{$_.TrimEnd(",")} |
			Out-File d:\BKD_LOGS\policies\DailyRet.txt -append
	}
	
#################################### 
#          Manual SCHEDULE
####################################

$ManualPolicy = bppllist

# Set the schedule variable
$ManualSchedule = "Manual"


foreach ($Manualpol in $ManualPolicy)
	{

		$ManualPolicyRetention = bpplsched $Manualpol -label $ManualSchedule -U |
			Where-Object {$_-match "Retention Level:"}
		$ManualPolicyRetention = $ManualPolicyRetention.substring(19) 
					
			if ($ManualPolicyRetention -eq $NUL)
			{
				$ManualPolicyRetention = "NA"
			}
				
		$ManualFinalRetention1 = $Manualpol + "," + $ManualSchedule + "," + $ManualPolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace "\(",","} |
			ForEach-Object {$_-replace "\)",","} |
			foreach-object{$_.TrimEnd(",")} |
			Out-File d:\BKD_LOGS\policies\DailyRet.txt -append
			
	}	

	