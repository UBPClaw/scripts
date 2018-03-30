
$Plocation =  "c:\temp\MD5\passwd.user"
$paccounts = gc c:\temp\MD5\user.passwd 



foreach ($accountp in $paccounts)
	{
		$account = $accountp.split(":")[0]
		$pass = $accountp.split(":")[1]
		
 		htpasswd.exe -mb $Plocation $account $pass
		
		
    }
