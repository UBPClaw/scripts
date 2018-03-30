$dadateOut = (get-date (get-date).AddDays(-1) -f M-d-yyyy)
$Scrape1 = @(gc \\gremlin\d$\BKD_LOGS\NBULOGS\$dadateOut.txt | 
	Where-Object {$_ -match "Backup"} |
	foreach-object {$_-replace "  root","" } |
	foreach-object {$_-replace "         Backup","BYE" } |
	foreach-object {$_-replace "PM                              ","PM,NOENDYET,NOSTATYET" } |
	foreach-object {$_-replace "AM                              ","AM,NOENDYET,NOSTATYET" } |
	foreach-object {$_-replace " Catalog Backup                               CATALOG   ","Catalog Backup                           " } |
	foreach-object {$_-replace "SYSTEMCatalog Backup                          ","SYSTEMCatalog Backup                    " } |
	foreach-object {$_-replace "Catalog Backup                           Done             ","Catalog Backup                           Done gremlin     " } |
	foreach-object {$_ -replace " {1,}",","}|
	foreach-object {$_ -replace "BYE,",""}|
	foreach-object {$_ -replace ",AM,"," AM,"}|
	foreach-object {$_ -replace ",PM,"," PM,"}|
	#foreach-object {$_ -replace ",{1,}",""}|
	#foreach-object {$_-replace $gPolicy,"" } |
	#foreach-object {$_-replace "                           ","" }
	#foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[0]})
	#$gPolicyName
	Out-File \\gremlin\d$\BKD_LOGS\NBULOGSCRAPE\$dadateOut.txt)