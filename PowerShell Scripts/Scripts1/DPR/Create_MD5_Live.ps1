
# The actual password file used by Apache
# The webdav.conf file on each RHEL server
# Should point to this file
# Change the location to the desired location.

#remove-item \\vfs02\DPR\psswd.user
#new-item \\vfs02\DPR\psswd.user

$Plocation =  "\\vfs03\DPR\psswd.user"
#$Plocation =  "\\vfs02\DPR\psswd.user"
#$Plocation =  "\\vfs02\DPR\psswdII.user"

#$Plocation =  "e:\scripts\psswdII.user"

# The file created by Eric D.
# Eric will place this file at \\vfs02\dpr
# Every night at 7:45 PM
#$paccounts = gc \\vfs02\DPR\user.passwd 
#$paccounts = gc E:\Scripts\user.passwd 


#$paccounts = compare-object (get-content \\vfs02\DPR\user.passwd ) (get-content \\vfs02\DPR\user.passwd.copy ) | select inputobject
#$paccounts | out-file \\vfs02\DPR\AccountsUpdated.txt 
#$uaccounts = get-content \\vfs02\DPR\AccountsUpdated.txt | where {$_ -ne ""} | select -skip 2
$paccounts = compare-object (get-content \\vfs03\DPR\user.passwd ) (get-content \\vfs03\DPR\user.passwd.copy ) | select inputobject
$paccounts | out-file \\vfs03\DPR\AccountsUpdated.txt 
$uaccounts = get-content \\vfs03\DPR\AccountsUpdated.txt | where {$_ -ne ""} | select -skip 2



send-mailmessage -to "Admin <administrator@mitchell1.com>" -from "DPR UPDATE <psql04@m1hosting.local>" -subject "Nightly DPR Update" -body "The following accounts were added: $uaccounts." -smtpserver smtp.corp.mitchellrepair.com

# Process each line in Eric's file
# The out put will be a new MD5 hashed password for each account.

foreach ($accountu in $uaccounts)
	{
		$account = $accountu.split(":")[0]
		$pass = $accountu.split(":")[1]
		
 		# Run the windows version of the Apache password utility
		# feed in the variable of the location of the final password file
		# Feed in the variable of the Account to create a password for
		# Feed ub the variable of the password to create for the account.
		#.\htpasswd.exe -mb $Plocation $account $pass 
		htpasswd.exe -mb $Plocation $account $pass
		
    }
    
# Rotate files for next night.
#remove-item \\vfs02\DPR\user.passwd.copy.1
#rename-item \\vfs02\DPR\user.passwd.copy \\vfs02\DPR\user.passwd.copy.1
#copy-item \\vfs02\DPR\user.passwd \\vfs02\DPR\user.passwd.copy
remove-item \\vfs03\DPR\user.passwd.copy.1
rename-item \\vfs03\DPR\user.passwd.copy \\vfs03\DPR\user.passwd.copy.1
copy-item \\vfs03\DPR\user.passwd \\vfs03\DPR\user.passwd.copy
    
    
    