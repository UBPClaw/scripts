gc \\gremlin\d$\BKD_LOGS\NBULOGSCRAPE\*.txt | where-Object {$_-match "Ranger" -or $_-match "Meps" -and $_-match "Weekly"} | 
Out-File \\malibu\it\backup\RebuildFromScratch\Ranger.txt -append 