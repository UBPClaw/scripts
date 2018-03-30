# ==================================================================================================================
# \\malibu\it\NTServers\Scripts\NetBackup\Tapedriveutilization.ps1
# Date 11/10/2008
# Bryan K. DeBrun
# The NBU command vmoprcmd -d displays the current activity of each tape drive
# We Schedule the capture of this data every 5 minutes
# We can then import it into excel or access.
# The report will tell us when the drives are idle. We will then get a good idea of if and when we can throw mor NBU jobs
# at a tape drive.
# ==================================================================================================================

# Get the date. The output file will be named with this date. All entries for a day will be appended to one date.

$dadate = get-date -f M-d-yyyy

# Get the date and time. The s format outputs the date as so; 2008-12-10T16:07:36

#$dadateOut = (get-date (get-date) -format s )
$dadateOut = (get-date -format M/d/yyyy::HH:mm:ss)


# Replace the :: in the $dadateOut variable with a comma. Doing this will split the date and time.

$dadateOutrpl = $dadateOut -replace "::",","
	
# Using psexec to call a NBU command on Gremlin the NBU master server

psexec \\gremlin	"D:\program files\veritas\volmgr\bin\vmoprcmd" -d  | 

# Scrape away the unwanted text and modify to include the date and time.

	Where-Object {$_-match "IBM.ULTRIUM"} |
	ForEach-Object {$_ -replace "   Yes"," "}|
	ForEach-Object {$_ -replace "-","NA"} |
	ForEach-Object {$_ -replace "  0","$dadateOutrpl "} |
	ForEach-Object {$_ -replace "  1","$dadateOutrpl "} |
	ForEach-Object {$_ -replace "  2","$dadateOutrpl "} |
	ForEach-Object {$_ -replace "  3","$dadateOutrpl "} |
	ForEach-Object {$_ -replace "  4","$dadateOutrpl "} |
	ForEach-Object {$_ -replace "  5","$dadateOutrpl "} | 
	ForEach-Object {$_ -replace "IBM.ULTRIUMNATD2.000","DRIVE0"} | 
	ForEach-Object {$_ -replace "IBM.ULTRIUMNATD2.001","DRIVE1"} | 
	ForEach-Object {$_ -replace "IBM.ULTRIUMNATD2.002","DRIVE2"} | 
	ForEach-Object {$_ -replace "IBM.ULTRIUMNATD2.003","DRIVE3"} | 
	ForEach-Object {$_ -replace "IBM.ULTRIUMNATD2.004","DRIVE4"} | 
	ForEach-Object {$_ -replace "IBM.ULTRIUMNATD2.005","DRIVE5"} | 
	foreach-object {$_ -replace " {1,}",","}|
	foreach-object {$_ -replace ".corp.mi,",""}|
	foreach-object {$_ -replace ".corp.mitch,",""}|
	
	
	# Send output to gremlin
	
	Out-File "\\gremlin\d$\BKD_LOGS\DriveUsage\$dadate.txt" -append