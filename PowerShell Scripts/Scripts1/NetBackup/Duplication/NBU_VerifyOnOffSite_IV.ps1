Function get-Unixdate ($UnixDate) {
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

 


Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\AllImages.txt
Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\Imagelist.txt
Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv
Remove-Item \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.csv
Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocation.csv
Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocationRpt.csv
#Remove-Item \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocation.csv
$Header = "BUPDate,Policy,MediaID,Location,Expiration"
$Header | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocation.csv -append


# Build the Policy Active/Not Active list and export it as a CSV


 $PolList = bppllist
 
 $Header = "Policy,Status"
 $Header | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv -append
foreach ($policy in $PolList)
 	{
 		$ActivePol = bppllist $policy -L |
 			where-object {$_-match "Active:" } |
			ForEach-Object {$_-replace "Active:            yes","1"} |
			ForEach-Object {$_-replace "Active:            no","0" }
			                           
			
			$policy + "," + $ActivePol | Out-File \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv -append
			}
			
			
			Import-Csv \\gremlin\d$\BKD_LOGS\Policies\PolicyStat.csv | Export-Csv \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.csv -notype





# Get the previous date. If we wanted to report on serveral days, we could change the -1 to another number. For each day of reports, we would
# have to change the number and manually run the script. Maybe in a new release, I will use a range of days. 

$DlyBupDt = (get-date (get-date).AddDays(-7) -f M/d/yyyy)
$Today = get-date -f M/d/yyyy


# Get content from the Policy Active/Not active csv file created above.
# Filter the file and return only active policies (Active = 1 Non Active = 0)
# Filter out the header in the CSV file (Policy,Status)
# Filter out the Vault jobs. For the purpose of this script, we don't care about Vault
# Filter out the CATALOG policy. Well, actually, we should probably look at this one as well. Will bring it back in in the next release.

$Pol1 = gc \\gremlin\d$\BKD_LOGS\Policies\PolicyStatus.csv | 
	Where-Object {$_-notmatch "Policy,Status" -and $_-notmatch ",0" -and $_-notmatch "Vault_" -and $_-notmatch "CATALOG"}



# The -Policy represents the actual policy. The -d represents the date and -e represents the end date. For the purpose of this script, we
# are getting only the previous day. Therefore, the -d and -e date are the same day. We will use the NetBackup command bpimagelist
# to output all of the images that were created for the required date. Some policies have multiple streams. This will create multiple
# entries for the policy. This is fine. We will scrape the out put for what we want later in this script.

foreach ($Pol2 in $Pol1)

	{
	$Policy = $Pol2.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
	$image = bpimagelist -policy $Policy -d $DlyBupDt -e $Today 23:59:59|
	   Where-Object {$_-match "IMAGE"}  | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\AllImages.txt -append
	
			
						
						
				}
				

# Grab only the image details for the weekly jobs. We do not duplicate daily jobs or send daily jobs off site. This is why we are
# grabbing weekly only.

$GBupID = gc \\gremlin\d$\bkd_logs\Duplication\VerifyOn_Offsite\Allimages.txt |
Where-Object {$_-match "manual"} 


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
		
		
				$Img =  bpimagelist -backupid $ID 
				$Img2 = $Img | 
					where-object {$_-notmatch "IMAGE" -and $_-notmatch "HISTO" -and $_-notmatch "\\"} 
						
# Here we are scraping away everything from the details list to get to the MediaID\Barcode only.
# Images can contain many fragments. This means if there will be suplicate MediaID\Barcodes. We will us the sort-object -unique to get
# a unique\distinct mediaID\Barcode.

				foreach ($object in $Img2)
					{
						$Imgg = $object.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[8]
						$UnixDate = $object.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[12]
						$DateConv = (get-Unixdate $UnixDate).ToShortDateString()
						$final = $Policy + "," + $Imgg + "," + $DateConv
						$final | Sort-Object -Unique | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\Imagelist.txt -append
					}
					
           }
		   

# Actually, this is the part that allows us to get the distinct\unique MediaId\Barcode. I belive the -Unique command would not work in the
# above code and that is why I am doing it here. I probably just forgot to remove the code when I found that it did not work. For now, I
# will leave the code in. When I am sure, I will remove it.
# So, here we are getting content which includes the policy name and the MediaID/Bacrode. For the next step of getting the details for
# the mediaid\barcode, we need only the MediaID\Barcode. This is whey we are using the split function below. We are splitting the Policy
# and the MediaID\Barcode into two seperate variables. We will still need the policy name when we are putting this baby back together.


		$Gimages = gc \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\Imagelist.txt | Sort-Object -Unique  
		
			foreach ($item in $Gimages)
				{
			
					$Bcode = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[1]
					$Bpolicy = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]
					$BDate = $item.split(",",[StringSplitOptions]::RemoveEmptyEntries)[2]
				
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
		$BDate + "," + $Bpolicy + "," + $Bcode + "," + $MedPool + "," + $TapeExpire | Out-File \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocation.csv -append
		          }
		
# Import the csv file and then make it a true CSV file by exporting it backu out as new name. As of now, I am not sure when we have to name the
# file then import it and then export it. I would think we could just export it from the beginning. Will follow up on this one.

		Import-Csv \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocation.csv | export-csv \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocationRpt.csv -notype