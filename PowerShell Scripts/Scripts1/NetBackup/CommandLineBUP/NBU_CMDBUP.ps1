
#Get the day of the week.
cls
$tdsdate = Get-Date -Format dddd
$tdsdate

# Get the Schedule to be used by Net Backup. Mon-Sat = Daily and Sunday = Weekly
If ( $tdsdate -eq "Monday" -or $tdsdate -eq "Tuesday" -or $tdsdate -eq "Wednesday" -or $tdsdate -eq "Thursday" -or $tdsdate -eq "Friday" -or $tdsdate -eq "Saturday")
	{
		$Schedule = "Daily"
		}
	else
		{			
			$Schedule = "Weekly"
			}
			
# ********************************* NEED TO ADD A VARIABLE FOR MONTHLY BACKUPS. MONTHLY BACKUPS HAPPEN ON THE FIRST DAY OF THE MONTH *********



# Get the last write time of the logfiles for both Nova and Gremlin located at \\hhr\e$\Scripts\DPR\LOGS. The log file with today's 
# date with be backed up. This is how we decide which server to back up; Nova or Gremlin


$nov = Get-ChildItem \\hhr\e$\Scripts\dpr\LOGS |
where {$_.name -match "Create_SnapShot_DPRBACKUP.log" }
$novadate = $nov.lastwritetime
$nova = $novadate.DayOfWeek
$nova


$grem = Get-ChildItem \\hhr\e$\Scripts\dpr\LOGS |
where {$_.name -match "Create_SnapShot_DPRGremlin_T.log" }
$gremlindate = $grem.lastwritetime 
$gremlin = $gremlindate.DayOfWeek
$gremlin


		if ($nova -ne $tdsdate -and $gremlin -ne $tdsdate)
			{
			$body=""
			$sender = "backupadmin@mitchell1.com"
			#$recipient = "bryan.debrun@mitchell1.com"
			$recipient = "backupadmin@mitchell1.com,OPSOnCall@mitchell1.com"
			$server = "smtp.corp.mitchellrepair.com"
			$subject = "DPR BACKUP FAILURE - A Snapshot log was not created for today"
			$msg = new-object System.Net.Mail.MailMessage $sender, $recipient, $subject, $body
		    $client = new-object System.Net.Mail.SmtpClient $server
			$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
			$client.Send($msg)
				}
				
				elseif ($nova -eq $tdsdate -and $gremlin -ne $tdsdate)
			{
				#"We are backing up the S: drive on Nova"

				 	bpbackup -i -p DPR_S -s $Schedule -h nova -S gremlin
				}
				
					elseif ($nova -ne $tdsdate -and $gremlin -eq $tdsdate)
						{
							#"Email Administrator We are backing up H: on Gremlin"

								bpbackup -i -p DPR_T -s $Schedule -h gremlin -S gremlin
							}