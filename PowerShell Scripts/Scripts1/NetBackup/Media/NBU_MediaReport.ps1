$MediaIDList = bpmedialist -l 

foreach ($Media in $MediaIDList  )
		{
			$mediaID = $Media.split(" ")[0]
			
		
			$mediaID

$MediaStatus = bpmedialist -m $mediaID -l

foreach ($line in $MediaStatus )
		{
			$vpool =  $line.split(" ")[13]
			$status = $line.split(" ")[14]
			
				if ($status -eq "1")
			
				{
						$status = "FROZEN"
				}
		
			$mediaID + "," + $status + "," $vpool | out-file d:\temp\mediastatus.txt -append
}

}
	










				
			

					