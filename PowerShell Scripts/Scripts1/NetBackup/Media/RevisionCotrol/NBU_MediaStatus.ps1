cls
$today = get-date -f M/d/yyyy
$yesterday = (get-date (get-date).AddDays(-1) -f M/d/yyyy)


#(get-date (get-date).AddDays(-7) -f M_d_yyyy)

$Tday = Import-Csv  \\gremlin\d$\BKD_LOGS\VolumePools\Reports\MediaRPTII.csv |
	 where-Object {$_.Assigned -eq $today} | select Barcode,Assigned,Expiration,Vpool,RobSlot | format-table
  
$Yday = Import-Csv  \\gremlin\d$\BKD_LOGS\VolumePools\Reports\MediaRPTII.csv |
	 where-Object {$_.Assigned -eq $yesterday} | select Barcode,Assigned,Expiration,Vpool,RobSlot | format-table
	 
 $Offsite =  Import-Csv  \\gremlin\d$\BKD_LOGS\VolumePools\Reports\MediaRPTII.csv |
	 where-Object {$_.Vpool -eq "Offsite (9)" -and $_.RobSlot -ne "N/A"} | select Barcode,Assigned,Expiration,Vpool,RobSlot | Sort-Object Assigned | format-table
 
 # Note; the -4 is for the 4 objects in the select statement Barcode. Not sure whey not using this throws off my total media used
 # Calculation. So, if you add an object, you must increment the 4 by 1 which would make it 5.
 
 $Tday 
 "There are " + ($Tday.count -4) + " pieces of media that were assigned on " + $today +"`n"
 
 $Yday
 "There are " + ($Yday.count -4) + " pieces of media that were assigned on " + $yesterday + "`n"
 
 $offsite 
  "There are " + ($offsite.count -4) + " pieces of media waiting to go off-site " + $today + "`n"

 $ScratchPool =  Import-Csv  \\gremlin\d$\BKD_LOGS\VolumePools\Reports\MediaRPTII.csv |
	 where-Object {$_.Vpool -eq "Scratch_Pool (4)" -and $_.RobSlot -ne "N/A"} | select Barcode,Assigned,Expiration,Vpool,RobSlot | format-table
	 
  
 
 $FUSlots = Import-Csv  \\gremlin\d$\BKD_LOGS\VolumePools\Reports\MediaRPTII.csv |
	 where-Object {$_.RobSlot -ne "N/A"} | select Barcode,Assigned,Expiration,Vpool,RobSlot | format-table
	 
	 $slotsUsed = $FUSlots.count - 4
	 $slotsAvail = 300 - $slotsUsed
	 $AvScratch = $ScratchPool.count -4
 
 "Slots Licensed                      = 300 " + "`n" +
 "Slots Used                          = " + $slotsUsed + "`n" +
 "Slots Available                     = " + $slotsAvail + "`n" +
 "Available Media in the Scratch Pool = " + $AvScratch