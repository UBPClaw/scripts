#Function To ping computer to see if it is alive
Function Ping-Name {
	  PROCESS { $wmi = get-wmiobject -query "SELECT * FROM Win32_PingStatus WHERE Address = '$_'"
	   if ($wmi.StatusCode -eq 0) {
	   	  $_ 
 	   } else {
 	     "{0,-20} {1,-5}" -f $_,"--DOWN--"
 	   }
   }
}



remove-item D:\BKD_LOGS\Clients\clients.txt
remove-item D:\BKD_LOGS\Clients\clients2.txt
remove-item D:\BKD_LOGS\Clients\clients3.txt
remove-item D:\BKD_LOGS\Clients\ClientsVer.txt

$getclient = bppllist |
		
		Where-Object {$_-notmatch "Vault"}

	foreach ($Policy in $getclient)
	
		{
			$p2 = bppllist $Policy | 
	    		Where-Object {$_-match "CLIENT"} |
				ForEach-Object {$_-replace "CLIENT","$Policy"}
								
					foreach ($line in $p2)
						{
							$Pol = $line.split(" ")[0]
				            $Clnt = $line.split(" ")[1]
				
							$Clnt | Out-File D:\BKD_LOGS\Clients\clients.txt -append
						}

		}

$UniqueClient = $(foreach ($line in get-content D:\BKD_LOGS\Clients\clients.txt) {$line.tolower().split(" ")}) | sort | get-unique | out-file D:\BKD_LOGS\Clients\clients2.txt -append

$getclient = gc D:\BKD_LOGS\Clients\clients2.txt
foreach ($client in $getclient)

	{
	
	$client | Ping-name | 
			where-object {$_-notmatch "--DOWN--"} | out-file D:\BKD_LOGS\Clients\Clients3.txt -append
	}
		
		$UpClients = gc D:\BKD_LOGS\Clients\Clients3.txt
		foreach ($AliveClient in $UpClients)	

		{

			$AliveClient
			$getclientinfo = bpgetconfig -M $AliveClient |						 
				where-object {$_-match "VERSIONINFO"} |
				foreach-object {$_-replace "VERSIONINFO = ",""} |
				foreach-object {$_-replace "`" `"",","} |
				foreach-object {$_-replace "`"",","} |
				foreach-object {$_-replace ", ",","}

				
				
				if ($getclientinfo -eq $NUL)
					{
						
					  $getclientinfo = ",NA" + ",NA" + ",NA" + ",NA" + ",NA" + ",NA"
					}
				
						

					$AliveClient + $getclientinfo | out-file D:\BKD_LOGS\Clients\ClientsVer.txt -append
					}
