#==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: NBU_StorageUnit_path.ps1
#
# Location: \\malibu\it\NTServers\Scripts\NetBackup\StorageUnits\NBU_StorageUnit_path.ps1
#
# DATE: 11/11/2009
#
# Author: Bryan DeBrun
#
# COMMENT:  This script uses the NetBackup command to extract the name and the path of the
#           Storage Unit. The output will be imported into a SQL database for reporting.       
#          
#           The SSIS package on the server SQLPROJ will Truncate the tbl_StuPaths
#           and import the text file created by this script.
#           The only thing you have to do is run this script and then execute the SSIS package
#           NBU_STUpath.dtsx at C:\Documents and Settings\Administrator\My Documents
# ==============================================================================================

Remove-Item d:\BKD_LOGS\StorageUnits\STUPath.txt

$StU = bpstulist  

foreach ($STunit in $StU )

	{
	
	$StuName = $STunit.split(" ")[0] |
	    foreach {$_-replace "Gremlin-Nova","TAPE"} |
		foreach {$_-replace "Nova-LTO2","TAPE"} |
		foreach {$_-replace "Gremlin-SDLT","TAPE"} |
		foreach {$_-replace "Gremlin-LTO2","TAPE"}
	$StuPath = $STunit.split(" ")[8] |
		foreach { $_-replace '"',""} |
		foreach { $_-replace '\*NULL\*',"TAPE"} 
		
	
	$StuName + "," + $StuPath | Out-File d:\BKD_LOGS\StorageUnits\STUPath.txt -append
	
	}

