$RepFolders = gc C:\Workdir\Repcards\RepCFolderrs.TXT


foreach ($Folder in $RepFolders)
	
	{
		new-item \\eclipse\ftproot\Repdn\$Folder -type directory
		
	}



