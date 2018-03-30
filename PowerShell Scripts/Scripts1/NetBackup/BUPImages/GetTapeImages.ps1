	# EXPLANATION OF OUTPUT COLUMNS
	
# IMAGE - Identifies the start of an image entry (Not reporting on this)
# Client - Client for the backup that produced this image
# Version - Image-version level (Not reporting on this)
# Backup-ID - Unique identifier for the backup that produced this image
# Policy - Policy name
# Policy type - 0 denotes Standard, etc. Run bpimmedia -L or refer to
#				bpbackup(1M) to interpret the policy-type value as a policy-type
#				name.
# Schedule - Schedule name
# Type - Schedule type (full, etc.)
# RL - Retention level (0-24)
# Files - Number of files
# Expiration date or time - The expiration date of the first copy to expire.
#							It appears in the Expires field of the fragment, 
#							which is described later (system time). 0 denotes
#							an image in progress or failed.
# C - Compression; 1 (yes) or 0 (no) (Not reporting on this)
# E - Encryption; 1 (yes) or 0 (no) (Not reporting on this)


	# EXPLANATION OF RETENTION LEVEL (RL)
	
# 0  = 1 Week
# 1  = 2 Weeks
# 2  = 3 Weeks
# 3  = 1 Month
# 4  = 2 Months
# 5  = 3 Months
# 9  = INFINITY
# 10 = 10 Years


# This is the function to convert UNIX time to local time. We will call this function later in the script.

Function get-Unixdate ($UnixDate) 
{
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

do
{
cls

$medid = Read-Host "Enter 6 digit Media ID"

$MedInf = bpimmedia -mediaid $medid |
Where-Object {$_-match "IMAGE"} |
ForEach-Object {$_-replace "IMAGE",""}

$medidH = "MEDID"
$clnt = "Client"
$pol = "Policy"
$sked = "Schedule"
$RL = "RL"
$Sexp = "Expiration"

Write-Host "`n `n------------------------------------------------------------------------------------"
"{0,-7} {1,-15} {2,-25} {3,-6} {4,-3} {5,5}" -f $medidH,$clnt,$pol,$sked,$RL,$Sexp
Write-Host "------------------------------------------------------------------------------------"

foreach ($column in $MedInf)

	{
		$clnt = $column.split(" ")[1]
		$bupid = $column.split(" ")[3]
		$pol = $column.split(" ")[4]
		$poltype = $column.split(" ")[5]
		$sked = $column.split(" ")[6]
		$skedtyp = $column.split(" ")[7]
		$RL = $column.split(" ")[8]
		$files = $column.split(" ")[9]
		$exp = $column.split(" ")[10]
			$Sexp = (get-Unixdate $exp).Tostring('G')
			
			"{0,-7} {1,-15} {2,-25} {3,-8} {4,-3} {5,5}" -f $medid,$clnt,$pol,$sked,$RL,$Sexp						
	}

Write-Host "------------------------------------------------------------------------------------"
Write-Host "`n EXPLANATION OF RETENTION LEVEL (RL)`n"
	
Write-Host "0  = 1 Week"
Write-Host "1  = 2 Weeks"
Write-Host "2  = 3 Weeks"
Write-Host "3  = 1 Month"
Write-Host "4  = 2 Months"
Write-Host "5  = 3 Months"
Write-Host "9  = INFINITY"
Write-Host "10 = 10 Years `n"

$MorMedia = Read-Host "Enter another ID  Y or N"
}

until ($MorMedia -eq "N")
cls