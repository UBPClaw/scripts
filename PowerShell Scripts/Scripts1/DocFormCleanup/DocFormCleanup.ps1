# ==============================================================================
#
# Microsoft PowerShell File
#
# NAME: DocFormCleanup.ps1
#
# Location: \\malibu\it\NTServers\Scripts\DocFormCleanup
#
# DATE: 12/2/2009
#
# Author: Bryan DeBrun
#
# COMMENT: This script moves the previous month's .pdf and .ps files to a year
#          and month folder. For example, on Jan1 2010, the script will create 
#          a 2009 folder (If doesn't exist) and then a Dec2009 folder inside the
#          2009 folder. All of the .pdf and .ps files for Dec2009 will then be 
#          moved to the Dec2009 folder. There will be two sections in this script
#          Part 1 of 2 will be for the following location 
#          \\malibu\it\CISReports\DocForm\MITINV
#          Part 2 of 2 will be for the following location
#          \\malibu\it\CISReports\DocForm\Graybar
#
#           A scheduled task on Canyon will run this script.
# ===============================================================================


# ==========================================================
#        Part One of Two for processing MITINV logs at
#        \\malibu\it\CISReports\DocForm\MITINV 
# ==========================================================



# Get the current year. If the month is January, then subtract a year.
# I.E. if it is January 2010, then we are looking for files from 2009.
# If we are not at the beginning of a new year then the year can be 
# set using the standard get-date without subtracting a year.

$Gmonth = Get-Date -Format MMMM

if ($Gmonth  -eq "January")
		{
			$Gyear = (get-date (get-date).AddYears(-1) -f yyyy)	
		}
			else
				{
					$Gyear = Get-Date -Format yyyy
				}

	
					
# Get date and format it as monthname and year i.e. Nov2009
# This is where each file for the designated month will be
# copied to.
$MonYear = (get-date (get-date).AddMonths(-1) -f MMMyyy)

# A year and month folder will be created at this location
$source = "\\malibu\it\CISReports\DocForm\MITINV"

# Create the current year folder in the source directory. 
New-Item $source\$Gyear -type directory

# Create the Month\year folder in the source\year directory
New-Item $source\$Gyear\$MonYear -type directory


# Get the month number. This will retrieve the actual number. If
# last month was November, the month will be 11. We will use this
# to scan through the folders to retrieve the last month to archive.
# The %M gives us a single digit removing the zero's in front of a
# single digit month of course, this depends on how the date is 
# formatted on the server in which the files reside
$MonNum = (get-date (get-date).AddMonths(-1) -f %M)


# Get files from source Last Month year and month for all .pdf files
$MovePDF = Get-ChildItem  $source -Filter *.pdf |
	Where-Object {$_.LastWriteTime.date.month -eq $MonNum}
		foreach ($DocPdf in $MovePDF)
			{
				Move-Item $source\$DocPdf $source\$Gyear\$MonYear
			}


#################################################

#  MOVE all .PS files

#################################################

# Get files from source Last Month year and month for all .ps files
$MovePS = Get-ChildItem   $source -Filter *.ps|
	Where-Object {$_.LastWriteTime.date.month -eq $MonNum}
		foreach ($DocPS in $MovePS)
			{
				Move-Item $source\$DocPs $source\$Gyear\$MonYear
			}


# END PART 1 OF 2


# ==========================================================
#        Part One of Two for processing GRAYBAR logs at
#        \\malibu\it\CISReports\DocForm\Graybar 
# ==========================================================



$source = "\\malibu\it\CISReports\DocForm\Graybar"
New-Item $source\$Gyear -type directory
New-Item $source\$Gyear\$MonYear -type directory
$MovePDF = Get-ChildItem  $source -Filter *.pdf |
	Where-Object {$_.LastWriteTime.date.month -eq $MonNum}
		foreach ($DocPdf in $MovePDF)
			{
				Move-Item $source\$DocPdf $source\$Gyear\$MonYear
			}
#################################################

#  MOVE all .PS files

#################################################

# Get files from source Last Month year and month for all .ps files
$MovePS = Get-ChildItem   $source -Filter *.ps|
	Where-Object {$_.LastWriteTime.date.month -eq $MonNum}
		foreach ($DocPS in $MovePS)
			{
				Move-Item $source\$DocPs $source\$Gyear\$MonYear
			}