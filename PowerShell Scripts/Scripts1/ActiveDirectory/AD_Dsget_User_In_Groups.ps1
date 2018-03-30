$Gusers = dsquery group -name G_EIS_Salesmgmt | dsget group -members -expand |
Foreach-object{$_.split(",",[StringSplitOptions]::RemoveEmptyEntries)[0]} |
ForEach-Object {$_-replace "`"CN=",""}
$Gusers