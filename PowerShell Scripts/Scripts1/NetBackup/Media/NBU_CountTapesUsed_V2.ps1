Function get-Unixdate ($UnixDate) {
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

 


Remove-Item D:\BKD_LOGS\Media\CountTapes\AllImages.txt
Remove-Item D:\BKD_LOGS\Media\CountTapes\Imagelist.txt
Remove-Item D:\BKD_LOGS\Media\CountTapes\TapeLocation.txt

# If the header is a text file and you are appending it, it will add a header each time
# This script is executed. So, create the file once with the header

# Build the Policy Active/Not Active list and export it as a CSV

	
 #$PolList = gc D:\BKD_LOGS\Media\CountTapes\getme.txt
 
  
 #$PolList = bppllist |
 	#where-object {$_-eq "Database_Corporate" } 
 	
 $PolList = bppllist

$DlyBupDt = (get-date (get-date).AddDays(-7) -f M/d/yyyy)
$Today = get-date -f M/d/yyyy
$TodayF = $Today  | ForEach-Object {$_-replace "\/",""}



# The -Policy represents the actual policy. The -d represents the date and -e represents the end date. For the purpose of this script, we
# are getting only the previous day. Therefore, the -d and -e date are the same day. We will use the NetBackup command bpimagelist
# to output all of the images that were created for the required date. Some policies have multiple streams. This will create multiple
# entries for the policy. This is fine. We will scrape the out put for what we want later in this script.

foreach ($Pol2 in $PolList)

	{
		
	  # For selecting a date range, use the line below
	  #$image = bpimagelist -policy $Pol2 -d $DlyBupDt -e $Today 23:59:59|
	  $image = bpimagelist -policy $Pol2 -hoursago 24 |
	   Where-Object {$_-match "IMAGE"}  | Out-File D:\BKD_LOGS\Media\CountTapes\AllImages.txt -append
	
			
						
						
				}
				

# Grab only the image details for the weekly jobs. We do not duplicate daily jobs or send daily jobs off site. This is why we are
# grabbing weekly only.

$GBupID = gc D:\BKD_LOGS\Media\CountTapes\Allimages.txt 


# This loop will get the Backup ID and the Policy name of the image only.
# We will then get the media ID\Barcode of the tape by executing the NetBackup command bpimagelist and the backup id using the
# variable $ID. So, an example of the command would be bpimagelist -backupid dakota_1236751839 This will return the details of
# the image which will include the barcode of the media used for the backup. This is what we want. 
# The image details contain lines in which we do not need. We will scrape away any line that contains "IMAGE" "HISTO" or "\"
# Because the \ is a special character, we have to put a \ in front to cancell out the special character. 

	Foreach ($BupId in $GBupID)
			{
				$ID = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[5]
				$Policy = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[6]
				$PSched = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[10]
				$UnixDate = $BupId.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[13]
				$DateConv = (get-Unixdate $UnixDate).ToShortDateString()
				
				$ID + "  " + "  " + $Policy + "  " + $PSched + "  " + $DateConv 
						
				$Img =  bpimagelist -backupid $ID  |
				where-object {$_-notmatch "IMAGE" -and $_-notmatch "HISTO" -and $_-notmatch "\\"} 
				
				
					if ($Img -eq $null)
			
					{
						$Img = "DSU"
					}
					
					
				foreach ($Line in $Img)
					{
						$Imgg = $Line.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]
						
							if ($Imgg -eq $null)
			
								{
									$Imgg = "DSU"
								}
													
						
						$final = $Policy + "," + $Imgg + "," + $DateConv + "," + $PSched 
						$DateConv					
						$final | Sort-Object -Unique | Out-File D:\BKD_LOGS\Media\CountTapes\Imagelist.txt -append
					}
					
					
			}
		   

# Actually, this is the part that allows us to get the distinct\unique MediaId\Barcode. I belive the -Unique command would not work in the
# above code and that is why I am doing it here. I probably just forgot to remove the code when I found that it did not work. For now, I
# will leave the code in. When I am sure, I will remove it.
# So, here we are getting content which includes the policy name and the MediaID/Bacrode. For the next step of getting the details for
# the mediaid\barcode, we need only the MediaID\Barcode. This is whey we are using the split function below. We are splitting the Policy
# and the MediaID\Barcode into two seperate variables. We will still need the policy name when we are putting this baby back together.


		$Gimages = gc D:\BKD_LOGS\Media\CountTapes\Imagelist.txt | Sort-Object -Unique  |
			Where-Object {$_-notmatch "DSU"}
		
			foreach ($item in $Gimages)
				{
			
					$Bcode = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
					$Bpolicy = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
					$BDate = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
					$PSsched2 = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[3]
				
# This is where we are using the NetBackup command bpmedialist to return the required details of the MediaID\Barcode.
# We want both the expiration date of the MediaID\Barcode and the Volume pool it resides in. The volume pool will tell us
# if the media is on or off site.

					$TapeExpire = bpmedialist -m $Bcode -L |
						Where-Object {$_-match "expiration"} |
						ForEach-Object {$_-replace "expiration = ",""} |
						Foreach-object{$_.split("(",[StringSplitOptions]::RemoveEmptyEntries)[0]}|
						foreach-object{$_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]}
						
# Getting the volume pool. The volume pools are labled with a number. It is much easier to determin what is going on by the
# actual name of the volume pool. This is why I am using an IF statement. Volume pool 9 = offsite Volume Pool 10 = Onsite.
# It is possible for the MediaID\Barcode to exist in a pool besides 9 or 10 but we will handle that in another release.
			
					$MedPool = bpmedialist -m $Bcode -L |
						Where-Object {$_-match "vmpool"}
			
							if ($MedPool  -eq "vmpool = 10")
			                  	
								{
									$MedPool  = "Onsite"
								}
					
							elseif ($MedPool  -eq "vmpool = 9")
					
								{
									$MedPool  = "Offsite"
								}
							
# Output The Backup Date, Policy name, Barcode, Volume Pool, and the Experation Date to a csv file. 			
		
		$BDate + "," + $Bpolicy + "," + $PSsched2 + ","+ $Bcode + "," + $TapeExpire | Out-File D:\BKD_LOGS\Media\CountTapes\policies\$TodayF.txt -append
		 
		          }


	