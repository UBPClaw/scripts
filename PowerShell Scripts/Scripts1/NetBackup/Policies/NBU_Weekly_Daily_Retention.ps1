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
Remove-Item d:\BKD_LOGS\policies\DailyRet1.txt
Remove-Item d:\BKD_LOGS\policies\WeeklyRet.txt
Remove-Item d:\BKD_LOGS\policies\MonthlyRet.txt

#################################### 
#          Daily SCHEDULE
####################################

$DailyPolicy = bppllist

# Set the schedule variable
$DailySchedule = "Daily"


foreach ($Dailypol in $Dailypolicy)
	{

		$DailyPolicyRetention = bpplsched $Dailypol -label $DailySchedule -U |
			Where-Object {$_-match "Retention Level:"}
		$DailyPolicyRetention = $DailyPolicyRetention.substring(19) 
					
			if ($DailyPolicyRetention -eq $NUL)
			{
				$DailyPolicyRetention = "NA"
			}
				
		$DailyFinalRetention = $Dailypol + "," + $DailySchedule + "," + $DailyPolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace " \(",","} |
			ForEach-Object {$_-replace "\)",","} |
			ForEach-Object {$_-replace " \)",","} |
			ForEach-Object {$_-replace ", ",","} |
			foreach-object{$_.TrimEnd(",")} |
			out-file d:\BKD_LOGS\policies\DailyRet1.txt -append
	
}
$DailyFinalRetention2 = gc d:\BKD_LOGS\policies\DailyRet1.txt				
foreach ($DailyRetentionLine in $DailyFinalRetention2)
	{
			
		$DailyRetentionPolicy = $DailyRetentionLine.split(",")[0]
			if ($DailyRetentionPolicy -eq $NUL)
			
				{
						$DailyRetentionPolicy = "NA"
				}
		$DailyRetentionSchedule = $DailyRetentionLine.split(",")[1]
			if ($DailyRetentionSchedule -eq $NUL)
			
				{
						$DailyRetentionSchedule = "NA"
				}
		$DailyRetentionCopy1 = $DailyRetentionLine.split(",")[3]
			if ($DailyRetentionCopy1 -eq $NUL)
			
				{
						$DailyRetentionCopy1 = "NA"
				}
		$DailyRetentionCopy2 = $DailyRetentionLine.split(",")[5]
			if ($DailyRetentionCopy2 -eq $NUL)
			
				{
						$DailyRetentionCopy2 = "NA"
				}
			
				
		$DailyRetentionPolicy + "," + $DailyRetentionSchedule + "," + $DailyRetentionCopy1 + "," + $DailyRetentionCopy2 |
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
				
		$WeeklyFinalRetention = $Weeklypol + "," + $WeeklySchedule + "," + $WeeklyPolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace " \(",","} |
			ForEach-Object {$_-replace "\)",","} |
			ForEach-Object {$_-replace " \)",","} |
			ForEach-Object {$_-replace ", ",","} |
			foreach-object{$_.TrimEnd(",")} |
			out-file d:\BKD_LOGS\policies\WeeklyRet.txt -append
	
}
$WeeklyFinalRetention = gc d:\BKD_LOGS\policies\WeeklyRet.txt				
foreach ($WeeklyRetentionLine in $WeeklyFinalRetention)
	{
			
		$WeeklyRetentionPolicy = $WeeklyRetentionLine.split(",")[0]
			if ($WeeklyRetentionPolicy -eq $NUL)
			
				{
						$WeeklyRetentionPolicy = "NA"
				}
		$WeeklyRetentionSchedule = $WeeklyRetentionLine.split(",")[1]
			if ($WeeklyRetentionSchedule -eq $NUL)
			
				{
						$WeeklyRetentionSchedule = "NA"
				}
		$WeeklyRetentionCopy1 = $WeeklyRetentionLine.split(",")[3]
			if ($WeeklyRetentionCopy1 -eq $NUL)
			
				{
						$WeeklyRetentionCopy1 = "NA"
				}
		$WeeklyRetentionCopy2 = $WeeklyRetentionLine.split(",")[5]
			if ($WeeklyRetentionCopy2 -eq $NUL)
			
				{
						$WeeklyRetentionCopy2 = "NA"
				}
			
				
		$WeeklyRetentionPolicy + "," + $WeeklyRetentionSchedule + "," + $WeeklyRetentionCopy1 + "," + $WeeklyRetentionCopy2 |
			foreach-object{$_.TrimEnd(",")} |
			Out-File d:\BKD_LOGS\policies\DailyRet.txt -append
	
	
	}
	
#################################### 
#          Monthly SCHEDULE
####################################

$MonthlyPolicy = bppllist

# Set the schedule variable
$MonthlySchedule = "Monthly"


foreach ($Monthlypol in $Monthlypolicy)
	{

		$MonthlyPolicyRetention = bpplsched $Monthlypol -label $MonthlySchedule -U |
			Where-Object {$_-match "Retention Level:"}
		$MonthlyPolicyRetention = $MonthlyPolicyRetention.substring(19) 
					
			if ($MonthlyPolicyRetention -eq $NUL)
			{
				$MonthlyPolicyRetention = "NA"
			}
				
		$MonthlyFinalRetention = $Monthlypol + "," + $MonthlySchedule + "," + $MonthlyPolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace " \(",","} |
			ForEach-Object {$_-replace "\)",","} |
			ForEach-Object {$_-replace " \)",","} |
			ForEach-Object {$_-replace ", ",","} |
			foreach-object{$_.TrimEnd(",")} |
			out-file d:\BKD_LOGS\policies\MonthlyRet.txt -append
	
}

$MonthlyFinalRetention2 = gc d:\BKD_LOGS\policies\MonthlyRet.txt				
foreach ($MonthlyRetentionLine in $MonthlyFinalRetention2)
	{
			
		$MonthlyRetentionPolicy = $MonthlyRetentionLine.split(",")[0]
			if ($MonthlyRetentionPolicy -eq $NUL)
			
				{
						$MonthlyRetentionPolicy = "NA"
				}
		$MonthlyRetentionSchedule = $MonthlyRetentionLine.split(",")[1]
			if ($MonthlyRetentionSchedule -eq $NUL)
			
				{
						$MonthlyRetentionSchedule = "NA"
				}
		$MonthlyRetentionCopy1 = $MonthlyRetentionLine.split(",")[3]
			if ($MonthlyRetentionCopy1 -eq $NUL)
			
				{
						$MonthlyRetentionCopy1 = "NA"
				}
		$MonthlyRetentionCopy2 = $MonthlyRetentionLine.split(",")[5]
			if ($MonthlyRetentionCopy2 -eq $NUL)
			
				{
						$MonthlyRetentionCopy2 = "NA"
				}
			
				
		$MonthlyRetentionPolicy + "," + $MonthlyRetentionSchedule + "," + $MonthlyRetentionCopy1 + "," + $MonthlyRetentionCopy2 |
			foreach-object{$_.TrimEnd(",")} |
			Out-File d:\BKD_LOGS\policies\DailyRet.txt -append
	
	
	}
	
#################################### 
#          Manual SCHEDULE
####################################

$ManualPolicy = bppllist

# Set the schedule variable
$ManualSchedule = "Manual"


foreach ($Manualpol in $Manualpolicy)
	{

		$ManualPolicyRetention = bpplsched $Manualpol -label $ManualSchedule -U |
			Where-Object {$_-match "Retention Level:"}
		$ManualPolicyRetention = $ManualPolicyRetention.substring(19) 
					
			if ($ManualPolicyRetention -eq $NUL)
			{
				$ManualPolicyRetention = "NA"
			}
				
		$ManualFinalRetention = $Manualpol + "," + $ManualSchedule + "," + $ManualPolicyRetention   |
			Where-Object {$_-notmatch ",NA"} | 
			ForEach-Object {$_-replace " \(",","} |
			ForEach-Object {$_-replace "\)",","} |
			ForEach-Object {$_-replace " \)",","} |
			ForEach-Object {$_-replace ", ",","} |
			foreach-object{$_.TrimEnd(",")} |
			out-file d:\BKD_LOGS\policies\ManualRet.txt -append
	
}
$ManualFinalRetention2 = gc d:\BKD_LOGS\policies\ManualRet.txt				
foreach ($ManualRetentionLine in $ManualFinalRetention2)
	{
			
		$ManualRetentionPolicy = $ManualRetentionLine.split(",")[0]
			if ($ManualRetentionPolicy -eq $NUL)
			
				{
						$ManualRetentionPolicy = "NA"
				}
		$ManualRetentionSchedule = $ManualRetentionLine.split(",")[1]
			if ($ManualRetentionSchedule -eq $NUL)
			
				{
						$ManualRetentionSchedule = "NA"
				}
		$ManualRetentionCopy1 = $ManualRetentionLine.split(",")[3]
			if ($ManualRetentionCopy1 -eq $NUL)
			
				{
						$ManualRetentionCopy1 = "NA"
				}
		$ManualRetentionCopy2 = $ManualRetentionLine.split(",")[5]
			if ($ManualRetentionCopy2 -eq $NUL)
			
				{
						$ManualRetentionCopy2 = "NA"
				}
			
				
		$ManualRetentionPolicy + "," + $ManualRetentionSchedule + "," + $ManualRetentionCopy1 + "," + $ManualRetentionCopy2 |
			foreach-object{$_.TrimEnd(",")} |
			Out-File d:\BKD_LOGS\policies\DailyRet.txt -append
	
	
	}