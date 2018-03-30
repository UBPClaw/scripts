gc \\malibu\it\NTServers\Docs\NetBackup\TotalsForDataBUP\MonthlyBup_Totals.txt |
Where-Object {$_-notmatch "-" -and $_-notmatch "KBS"}|
Where-Object {$_-ne " "}|
#-and $_-ne ""} |                                                                                                                      "} |
foreach-object {$_-replace " ",""}|
Out-File \\malibu\it\NTServers\Docs\NetBackup\TotalsForDataBUP\Nov2009_Bup_Totals.txt  -append