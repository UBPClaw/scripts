
Remove-Item d:\BKD_LOGS\VolumePools\Vpools\*.txt

$NBUvolPath = "D:\program files\veritas\volmgr\bin"
cd $NBUvolPath

$GpoolNum = vmpool -list_all |
	Where-Object {$_-match "pool number:"} |
	ForEach-Object {$_-replace "pool number:  ",""}
	
	foreach ($pnumber in $GpoolNum)
		{
			vmquery -p $pnumber | 
			where-object {$_-match "media ID:"} |
			ForEach-Object {$_-replace "media ID:              ",""} |
			Out-File d:\BKD_LOGS\VolumePools\Vpools\VpoolMedia.txt -append
		}


# *************************************************************************************************************************
# Create the Media Report CSV file.


$header =  "MedID,MedType,Barcode,Mdescript,Vpool,RobType,RobNum,RobSlot,RobCtrlHost,Vgroup,VltName,VltSntDate,VltRtrnDate,VltSlot,Created ,Assigned,LstMount,FrstMount,Expiration,NumMounts,Status" 
$header | Out-File d:\BKD_LOGS\VolumePools\Reports\MediaRPT.csv
$VpoolFile = gc d:\BKD_LOGS\VolumePools\Vpools\VpoolMedia.txt
 
foreach ($tapeID in $VpoolFile)

{

$MedID = vmquery -m $tapeID |
	Where-Object {$_-match "media ID:"} |
	foreach-object {$_-replace "media ID:              ",""}	
	if ($MedID -eq $NULL)
		{
			$MedID = "N/A"
			
			}
			
			else
			{
			}
			$MedID
			
$MedType = vmquery -m $tapeID |
	Where-Object {$_-match "media type:"} |
	foreach-object {$_-replace "media type:            ",""}	
	if ($MedType -eq $NULL)
		{
			$MedType = "N/A"
			
			}
			
			else
			{
			}
			$MedType			
			
$Barcode = vmquery -m $tapeID |
	Where-Object {$_-match "barcode:"} |
	foreach-object {$_-replace "barcode:               ",""}	
	if ($Barcode -eq $NULL)
		{
			$Barcode = "N/A"
			
			}
			
			else
			{
			}
			$Barcode
         
$Mdescript = vmquery -m $tapeID |
	Where-Object {$_-match "media description:"} |
	foreach-object {$_-replace "media description:     ",""}	
	if ($Mdescript -eq $NULL)
		{
			$Mdescript = "N/A"
			
			}
			
			else
			{
			}
			$Mdescript  
			
$Vpool = vmquery -m $tapeID |
	Where-Object {$_-match "volume pool:"} |
	foreach-object {$_-replace "volume pool:           ",""}	
	if ($Vpool -eq $NULL)
		{
			$Vpool = "N/A"
			
			}
			
			else
			{
			}
			$Vpool
        
$RobType = vmquery -m $tapeID |
	Where-Object {$_-match "robot type:"} |
	foreach-object {$_-replace "robot type:            ",""}	
	if ($RobType -eq $NULL)
		{
			$RobType = "N/A"
			
			}
			
			else
			{
			}
			$RobType         

$RobNum = vmquery -m $tapeID |
	Where-Object {$_-match "robot number:"} |
	foreach-object {$_-replace "robot number:          ",""}	
	if ($RobNum  -eq $NULL)
		{
			$RobNum  = "N/A"
			
			}
			
			else
			{
			}
			$RobNum 
			
			
$RobSlot = vmquery -m $tapeID |
	Where-Object {$_-match "robot slot:"} |
	foreach-object {$_-replace "robot slot:            ",""}	
	if ($RobSlot  -eq $NULL)
		{
			$RobSlot  = "N/A"
			
			}
			
			else
			{
			}
			$RobSlot          

$RobCtrlHost = vmquery -m $tapeID |
	Where-Object {$_-match "robot control host:"} |
	foreach-object {$_-replace "robot control host:    ",""}	
	if ($RobCtrlHost   -eq $NULL)
		{
			$RobCtrlHost   = "N/A"
			
			}
			
			else
			{
			}
			$RobCtrlHost 
$Vgroup = vmquery -m $tapeID |
	Where-Object {$_-match "volume group:"} |
	foreach-object {$_-replace "volume group:          ",""}	
	if ($Vgroup   -eq $NULL)
		{
			$Vgroup   = "N/A"
			
			}
			
			else
			{
			}
			$Vgroup 
			
$VltName = vmquery -m $tapeID |
	Where-Object {$_-match "vault name:"} |
	foreach-object {$_-replace "vault name:            ",""}	
	if ($VltName   -eq $NULL)
		{
			$VltName   = "N/A"
			
			}
			
			elseif ($VltName   -eq "---")
				{
					$VltName   = "N/A"
				}
			$VltName
			

$VltSD = vmquery -m $tapeID |
	Where-Object {$_-match "vault sent date:"} |
	foreach-object {$_-replace "vault sent date:       ",""}
	$VltSntDate = $VltSD.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($VltSntDate    -eq $NULL)
		{
			$VltSntDate    = "N/A"
			
			}
			
			elseif ($VltSntDate    -eq "---")
				{
					$VltSntDate    = "N/A"
				}
			$VltSntDate 

$VltRtDt = vmquery -m $tapeID |
	Where-Object {$_-match "vault return date:"} |
	foreach-object {$_-replace "vault return date:     ",""}
	$VltRtrnDate = $VltRtDt.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($VltRtrnDate    -eq $NULL)
		{
			$VltRtrnDate    = "N/A"
			
			}
			
			elseif ($VltRtrnDate    -eq "---")
				{
					$VltRtrnDate    = "N/A"
				}
			$VltRtrnDate 
			

$VltSlot = vmquery -m $tapeID |
	Where-Object {$_-match "vault slot:"} |
	foreach-object {$_-replace "vault slot:            ",""}	
	if ($VltSlot    -eq $NULL)
		{
			$VltSlot    = "N/A"
			
			}
			
			elseif ($VltSlot    -eq "---")
				{
					$VltSlot    = "N/A"
				}
			$VltSlot

   
$Crted = vmquery -m $tapeID |
	Where-Object {$_-match "created:"} |
	foreach-object {$_-replace "created:               ",""}
	$Created = $Crted.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($Created    -eq $NULL)
		{
			$Created   = "N/A"
			
			}
			
			elseif ($Created    -eq "---")
				{
					$Created    = "N/A"
				}
			$Created 
			

$Assd = vmquery -m $tapeID |
	Where-Object {$_-match "assigned:"} |
	foreach-object {$_-replace "assigned:              ",""}
	$Assigned = $Assd.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($Assigned    -eq $NULL)
		{
			$Assigned   = "N/A"
			
			}
			
			elseif ($Assigned    -eq "---")
				{
					$Assigned    = "N/A"
				}
			$Assigned
			

$LstMt = vmquery -m $tapeID |
	Where-Object {$_-match "last mounted:"} |
	foreach-object {$_-replace "last mounted:          ",""}
	$LstMount = $LstMt.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($LstMount    -eq $NULL)
		{
			$LstMount   = "N/A"
			
			}
			
			elseif ($LstMount    -eq "---")
				{
					$LstMount    = "N/A"
				}
			$LstMount
			

$FrstMt = vmquery -m $tapeID |
	Where-Object {$_-match "first mount:"} |
	foreach-object {$_-replace "first mount:           ",""}
	$FrstMount = $FrstMt.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($FrstMount    -eq $NULL)
		{
			$FrstMount   = "N/A"
			
			}
			
			elseif ($FrstMount    -eq "---")
				{
					$FrstMount    = "N/A"
				}
			$FrstMount
			

$Expire= bpmedialist -m $tapeID -L |
	Where-Object {$_-match "expiration"} |
	foreach-object {$_-replace "expiration = ",""}
	$Expiration1 = $Expire.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]
	$Expiration = $Expiration1.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]
	if ($Expiration    -eq $NULL)
		{
			$Expiration   = "N/A"
			
			}
			
			elseif ($Expiration    -eq "---")
				{
					$Expiration    = "N/A"
				}
			$Expiration
			
			
$NumMounts= vmquery -m $tapeID |
	Where-Object {$_-match "number of mounts:"} |
	foreach-object {$_-replace "number of mounts:      ",""}
	
	if ($NumMounts    -eq $NULL)
		{
			$NumMounts   = "N/A"
			
			}
			
			elseif ($NumMounts    -eq "---")
				{
					$NumMounts    = "N/A"
				}
			$NumMounts
			

  
$Status = vmquery -m $tapeID |
	Where-Object {$_-match "status:"} |
	foreach-object {$_-replace "status:                ",""}
	
	if ($Status    -eq $NULL)
		{
			$Status   = "N/A"
			
			}
			
			elseif ($Status    -eq "---")
				{
					$Status    = "N/A"
				}
			$Status       
			
		$MedID+ "," +$MedType+ "," +$Barcode+ "," +$Mdescript+ "," +$Vpool+ "," +$RobType+ "," +$RobNum+ "," +$RobSlot+ "," +$RobCtrlHost+ "," +$Vgroup+ "," +$VltName+ "," +$VltSntDate+ "," +$VltRtrnDate+ "," +$VltSlot+ "," +$Created + "," +$Assigned+ "," +$LstMount+ "," +$FrstMount+ "," +$Expiration+ "," +$NumMounts+ "," +$Status | Out-File d:\BKD_LOGS\VolumePools\Reports\MediaRPT.csv -Append


}
Import-Csv d:\BKD_LOGS\VolumePools\Reports\MediaRPT.csv | Export-Csv d:\BKD_LOGS\VolumePools\Reports\MediaRPTII.csv -notype
Remove-Item d:\BKD_LOGS\VolumePools\Reports\MediaRPT.csv

