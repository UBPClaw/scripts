$MediaIDList = bpmedialist -l 

foreach ($Media in $MediaIDList  )
		{
			$mediaID = $Media.split(" ")[0]
						
			foreach ($POM in $mediaID)
			
				{
			#$GetFrozen = nbemmcmd -listmedia -mediaid $mediaID |
			 #Where-Object {$_-match "FROZEN"} 
			 #$GetFrozen + $POM 
		
		
		$FrozenMed = nbemmcmd -listmedia -mediaid $mediaID |
			 Where-Object {$_-match "FROZEN"} |
			 foreach-object {$mediaID}
			 $FrozenMed
		
			
	}
	}
			
			


