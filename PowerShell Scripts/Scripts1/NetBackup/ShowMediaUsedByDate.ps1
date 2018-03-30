# This script will get the current media used count



remove-Item \\gremlin\d$\temp\MediaListCurrent.txt
remove-Item \\gremlin\d$\temp\MediaCurrent.txt

$SpecDate=read-host "Enter Date mm/dd/yyyy"

psexec \\gremlin c:\scripts\GetCurrentMediaList.bat
                            

$mdate = get-content \\gremlin\d$\temp\MediaListCurrent.txt | where-object {$_-match "allocated"}| foreach { $_.split(" ",[StringSplitOptions]::RemoveEmptyEntries)[2]} | out-file \\gremlin\d$\temp\MediaCurrent.txt
$mlist = get-content \\gremlin\d$\temp\mediaCurrent.txt | where-object {$_-match $SpecDate}
$mcount = $mlist.count
$Mfin = $SpecDate +" " + $mcount 
$Mfin


