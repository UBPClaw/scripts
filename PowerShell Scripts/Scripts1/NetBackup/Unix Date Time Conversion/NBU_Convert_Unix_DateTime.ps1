# Check the Unix Date/time
#
# Run in conjuction with the NetBackup command bpimagelist to retrieve the image information
# I am using it to find out when an image expires
# In the output of the following command, use the numbers in columns 15 and 17. These columns
# are unix formatted date time stamps. Swap the number out after get-Unixdate with the desired
# Unix date time stamp. Get the Backup Date from the number in column 15 and the Expiration date
# from column 17.
# Run the following command to get the image information.
#     bpimagelist -policy NA_Datkota_Dept_Offsite -d 10/18/2011 
# You might want to output the results to a text file. Locate column 15(Backup Date time) 17(Experation date of image)
# Swap the policy name with the desired policy




Function get-Unixdate ($UnixDate) {
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}
(get-Unixdate 2147483647).ToShortDateString()