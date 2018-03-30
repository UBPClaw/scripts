
$1 = Get-ChildItem -Name c:\test

foreach ($File in $1)
	{
	
	
	
	
		$2 = Import-Csv c:\test\$File | where {$_.KBS -ne "-"} |
		measure-object kbs -sum |
		
				
			
		Select-Object @{name="Total Size(MB)";Expression={"{0:N0}" -f ($_.sum)}}
		
		
		foreach ($date in $2)
		
			{
				$File + $date |
				 foreach-object {$_-replace "BUPREPORTS_","" } | 
				 foreach-object {$_-replace ".csv@\{Total Size\(MB\)="," " } |
				 foreach-object {$_-replace "\}","" } |
				 foreach-object {$_-replace "_","/" } |
				}
					
			
	
			  }
			
			
			