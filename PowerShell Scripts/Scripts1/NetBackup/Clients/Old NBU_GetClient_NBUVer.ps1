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


remove-item D:\BKD_LOGS\Clients\Clients.txt
$getclient = bpclient -All|
where-object {$_-match "Client Name:"} |
foreach-object {$_-replace "Client Name: ",""}

foreach ($client in $getclient)

	{
	
	$client | Ping-name | 
			where-object {$_-notmatch "--DOWN--"} | out-file D:\BKD_LOGS\Clients\Clients.txt -append
	}
		
		$UpClients = gc D:\BKD_LOGS\Clients\Clients.txt
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
