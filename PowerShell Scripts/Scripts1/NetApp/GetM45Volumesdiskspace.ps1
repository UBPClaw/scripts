
Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

#Import the module to access the NetApps
#import-module C:\workdir\Powershell\Modules\PoshOnTap.psd1

#Connect to the NetApp filer
connect-naserver -filer m45 -credential (Get-Credential)

#Output File
$log = "\\malibu\it\\EntStorage\M45_Sizing_"+(Time-Stamp)+".csv"

#Add column headers to the output file
Add-Content "$log" "Volume,Volume Size,Volume Size Used,Volume Size Available,Lun Total Size,Difference,Dedupe Saved,Dedupe %,Aggregate"

#Get All the Volumes and the size of the volume Store in temp file
$tmp = get-navol | sort Volume

$tmp | foreach{
	
	$vol=$_.volume
	Write-Host "Prcoessing $vol"
	$VolSize=($_.SizeTotal / 1gb).tostring("F02")
	$VolUsed=($_.SizeUsed / 1gb).tostring("F02")
	$VolAvail=($_.SizeAvailable / 1gb).tostring("F02")
	$VolAggr=$_.ContainingAggregate
	$DedupeSize=($_.sis.SizeSaved / 1gb).tostring("F02")
	$DedupePercent=$_.sis.PercentageSaved
	$LunTotal = get-nalun | where-object { $_.Path -match "^/vol/$vol/*"} | sort lun | select Size |  measure -Property Size -Sum
	$LS = ($LunTotal.Sum / 1gb).tostring("F02")
	
	$dif = ($VolSize - $LS).tostring("F02")
	Add-Content "$log" "$vol,$VolSize,$VolUsed,$VolAvail,$LS,$dif,$DedupeSize,$DedupePercent,$VolAggr"}
