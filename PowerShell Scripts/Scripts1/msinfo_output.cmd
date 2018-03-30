:: Format date as mm-dd-yyyy and assign to 
:: variable 'Today'
set Today=%Date:~4,2%-%Date:~7,2%-%Date:~10,4%

:: Check for existence of backup folder and
:: create if necessary
IF NOT EXIST \\malibu\it\ntservers\systeminfo md \\malibu\it\ntservers\systeminfo

:: Generate output as .nfo file (file name based on 
:: computer name and date)
start msinfo32.exe /nfo "\\malibu\it\ntservers\systeminfo\%computername%_%Today%.nfo"
