# ==============================================================================================
#
# Microsoft PowerShell File
#
# NAME: MoveHostingIISLogs.ps1
#
# Location: \\malibu\it\NTservers\Scripts\IISLOGS\Jobstatus\MoveHostingIISLogs.ps1
#
# DATE: 12/11/2009
#
# Author: Bryan DeBrun
#
# COMMENT: Move IIS logs from Hosting Web servers (Pweb08,9,10) 
#          to \\vfs02\Transfers\IISLOGS
#          This script will be scheduled from each of the web servers to
#          run daily at 12:30 AM
# ==============================================================================================


$ghost = gc env:computername
$Source = "E:\Logfiles"
$Target = "\\vfs02\Transfers\IISLOGS\$ghost"
$YestDay = (get-date (get-date).AddDays(-1) -f yyMMdd)

$Gfolder = get-childitem -name $Source

foreach ($folder in $Gfolder)

{

    New-Item $Target\$folder -type directory
    
 	      $logs = Get-ChildItem $Source\$folder |
		      where {$_.name -match "u_ex"+$YestDay } 
		      $logs
		          foreach ($File in $Logs)
		          	{
			             if ($File -eq $NUL)
            
			                 {
                                  $Source + "\" + $folder + "   " + "  " + $File + "  " + $Target + "  " + $logs + " " + $YestDay | out-file \\vfs02\Transfers\IISLOGS\nofile.txt -append
			                 }
	else
			{
				Move-Item $Source\$folder\$File $Target\$folder
				#$Moving1 + " " + $File + " " + $Moving2 
                #write-host "There are files"
			}
				}
		

}
