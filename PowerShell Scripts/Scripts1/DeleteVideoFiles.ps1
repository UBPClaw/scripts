#***********************************************
#* DeleteVideoFiles.ps1                        *
#* Created 04-30-08                            *
#* Created by Bryan DeBrun                     *
#* Purpose Remove video files older then 4 days*
#* Server  Scion                               *
#***********************************************


# This script looks at the date time stamp. So, don't get confused when you see -gt 3. The script is removing an
# file older than 4 days.
# Removes the files located at E:\Video_Data\MPEG4 NVR\Recording on the Scion server
# In addition, we are also backing up this location on Scion. Each backup will be kept onsite for 30 days.


Get-ChildItem "\\scion\e$\Video_Data\MPEG4 NVR\Recording" -rec | where{(([datetime]::Today-$_.CreationTime.Date).Days -gt 4) } | foreach ($_) {Remove-Item $_.fullname -recurse}



