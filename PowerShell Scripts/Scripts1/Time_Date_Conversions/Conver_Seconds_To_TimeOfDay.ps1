$ts = New-TimeSpan -Seconds 0
'{0:00}:{1:00}:{2:00}' -f $ts.Hours,$ts.Minutes,$ts.Seconds


$lines = type c:\temp\nbu\policyinfo.txt |
where-object{$_-mat""}
$lines[0]
