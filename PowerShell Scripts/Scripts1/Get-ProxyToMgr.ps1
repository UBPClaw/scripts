  # Be sure to change the $uid to the user in the request
  $Begperiod = (get-date (get-date).AddDays(-7) -f M_d_yyyy)
  $EndPeriod = (get-date (get-date).AddDays(-1) -f M_d_yyyy)
  $now = get-date
  $uid = "eb1595"
  $Mgrid = "gv1356"
  $filename = "Inetreports_"+$Begperiod+"_to_"+$EndPeriod+"_for_"+$uid+".csv"
  $Files = get-childitem \\yukon\f$\isalogs | where-object {($now - $_.LastWriteTime).Days -lt 7}
  Add-Content "c-ip,cs-username,c-agent,date,time,s-computername,cs-referred,r-host,r-ip,r-port,time-taken,cs-bytes,sc-bytes,cs-protocol,s-operation,cs-uri,s-object-source,sc-status" -Path c:\temp\proxytemp.csv
  $Files | Select-String $uid | foreach {$_.line.replace("`t",",")} | add-content -path c:\temp\proxytemp.csv
  Import-Csv c:\temp\proxytemp.csv | select c-ip,cs-username,date,time,r-host,cs-uri | Export-Csv \\dakota\user\$Mgrid\InetUsage\$filename -notype
  Remove-Item c:\temp\proxytemp.csv
 
  
  
