# ==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: IISlogs_MoveNonOD5.ps1 
#
# Location: NTServers\Scripts\IISLOGS\IISlogs_MoveNonOD5.ps1
#
# DATE: 12/16/2009
#
# Author: Bryan DeBrun
#
# COMMENT: Move IIS logs from Hosting Web servers Win2k Non OD5/SK5 servers 
#          to \\vfs02\Transfers\IISLOGS This script will be scheduled from 
#          Pweb08 to run daily at 12:30 AM
#	       
# Prerequisites: Powershell must be install, set the execution policy to remote signed
#                A scheduled task must be created on M1hosting Server.
#                The target location for the log files must exist.
#                The source of the log files must exist.
# ==============================================================================================


# Get yesterday's date year month and day 091222
$YestDay = (get-date (get-date).AddDays(-1) -f yyMMdd)

# Set the location of the logfiles. Verify the location is the
# same for each server
#$loglocation = "G$\logfiles"

# Set the destination of the log files. Should be on the netapp share
$logDestination = "\\vfs02\Transfers\IISLOGS"

# For each server with logfiles, add the server name to
# this text file. The script process for each
# server in this list
$GetServers = gc E:\Servers.txt

# Set the name of the logfile. Verify the actuall name
# this could change. Windows 2008 logfiles have the
# prefix of u_x
$Logfile = "ex$YestDay.log"

# Loop through each server in the text file
# create a server and site directory on the
# target if it doesn't exist. 
# move yesterdays log file to the target

	foreach ($server in $GetServers)
	
	{
        if ($server = "esv")
			
			{
				$loglocation = "E$\iislog"
                $FullServerPath = "\\$server\$loglocation"
		$SiteID = Get-ChildItem $FullServerPath 
		foreach ($site in $SiteID)
		
		{
		
			new-item $logDestination\$server\$Site -type directory
			Move-Item $FullServerPath\$site\$Logfile $logDestination\$server\$Site
		
		
		}
			}
			
			else
			
			{
				
				$loglocation = "G$\logfiles"
                
                $FullServerPath = "\\$server\$loglocation"
		$SiteID = Get-ChildItem $FullServerPath 
		foreach ($site in $SiteID)
		
		{
		
			new-item $logDestination\$server\$Site -type directory
			Move-Item $FullServerPath\$site\$Logfile $logDestination\$server\$Site
		
		
		}
			}
            
	    
	
	}