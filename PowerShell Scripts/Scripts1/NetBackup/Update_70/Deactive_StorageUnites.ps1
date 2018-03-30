#This command will Deactivate the Disk Staging Unit for the date specified in the bpschedulerep $storageunit -excl

bpstulist -L |                                                
	Where-Object {$_-match "Label:"} |                    
	ForEach-Object {$_-replace "Label:                ",""} |Sort-Object | Out-File \\malibu\it\Backup\Update_70\StorageUnits.txt
	                                                      
	#gc \\gremlin\d$\bkd_logs\StorageUnits\StorageUnits.txt         
          
$StorageunitDeactivate = gc \\malibu\it\Backup\Update_70\StorageUnits.txt

foreach ($storageunit in $StorageunitDeactivate)
	
       {
       	bpschedulerep $storageunit -excl 08/24/2010
       }   
          
          
          