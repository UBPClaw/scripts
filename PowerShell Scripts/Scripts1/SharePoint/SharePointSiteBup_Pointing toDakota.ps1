Remove-Item e:\temp\spsites.txt
Remove-Item e:\temp\spsitesII.txt

Remove-Item e:\temp\spsites_sodintranet.txt
Remove-Item e:\temp\spsites_sodintranetII.txt

$BUPdate =get-date -Format M-d-yyyy-h-m-s


stsadm -o enumsites -url http://intranet | Out-File e:\temp\spsites.txt -Append

stsadm -o enumsites -url http://sodintranet | Out-File e:\temp\spsites_sodintranet.txt -Append

$getsites = gc e:\temp\spsites.txt |
Where-Object{ $_-match "sites" } |
foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1]}
$getsites | Where-Object { $_-match "sites" } | 
foreach { $_.split("\/",[StringSplitOptions]::RemoveEmptyEntries)[3]} |
ForEach-Object {$_-replace "`"",""}|
out-file e:\temp\spsitesII.txt

$BupSites = gc e:\temp\spsitesII.txt
	foreach ($sharepointsite in $BupSites)
		{
			stsadm -o backup -url http://intranet/sites/$sharepointsite -filename \\dakota\Backups\SharePointSites\$sharepointsite"_"$BUPdate.bak
		}


stsadm -o backup -url http://intranet -filename \\dakota\Backups\SharePointSites\Intranet"_"$BUPdate.bak








$getsites2 = gc e:\temp\spsites_sodintranet.txt |
Where-Object{ $_-match "sodintranet" } |
Where-Object{ $_-notmatch "http://sodintranet`"" } |
Where-Object{ $_-notmatch "sites" } |

foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[1]}
$getsites2 | Where-Object { $_-match "sodintranet" } | 
foreach { $_.split("\/",[StringSplitOptions]::RemoveEmptyEntries)[2]} |
out-file e:\temp\spsites_sodintranetII.txt

$BupSitesII = gc e:\temp\spsites_sodintranetII.txt
	foreach ($sharepointsiteII in $BupSitesII)
		{
			stsadm -o backup -url http://sodintranet/$sharepointsiteII/home -filename \\dakota\Backups\SharePointSites\$sharepointsiteII"_"$BUPdate.bak
		}


stsadm -o backup -url http://sodintranet -filename \\dakota\Backups\SharePointSites\Intranet"_"$BUPdate.bak
stsadm -o backup -url http://sodintranet/sites/ducmgmt -filename \\dakota\Backups\SharePointSites\ducmgmt"_"$BUPdate.bak