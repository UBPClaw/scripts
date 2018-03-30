Import-Csv  \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocationRpt.csv |
	where-Object {$_.Location -eq "Offsite"} | select BUPDate,Policy,MediaID,Location,Expiration | Sort-Object BUPDate | format-table -AutoSize
	 
	 #where-Object {$_.BUPDate -eq "3/26/2009"} | select BUPDate,Policy,MediaID,Location,Expiration | Sort-Object BUPDate | format-table -AutoSize
	 
	 
	 #Import-Csv  \\gremlin\d$\BKD_LOGS\Duplication\VerifyOn_Offsite\TapeLocationRpt.csv |
	 #select BUPDate,Policy,MediaID,Location,Expiration | Sort-Object BUPDate | format-table -autosize
	
	 #where-Object {$_.Location -eq "Offsite" -and $_.BUPDate -eq "3/26/2009"} | select BUPDate,Policy,MediaID,Location,Expiration | Sort-Object BUPDate | format-table -autosize