$WeeklyPol = "FILER_Dakota_User_DD1"
$StartDate = "1/1/2009"
$EndDate = "1/20/2009"
$schedule = "Weekly"
$BackupID = "ranger_1232877604"


psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BackupID -U
#psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -policy $WeeklyPol -d $StartDate -e $EndDate -sl $schedule -U
#psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -policy $WeeklyPol -sl $schedule -U


 psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BackupID -L |
   			Where-Object {$_-match "Copy number:"} |
			ForEach-Object {$_-replace "Copy number:       ",""} |Sort-Object -Unique
			
			psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BackupID -U
			
#$Media = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -backupid $BackupID -L |
#Where-Object {$_-match "ID:"} |
#ForEach-Object {$_-replace " ID:               ",""}

