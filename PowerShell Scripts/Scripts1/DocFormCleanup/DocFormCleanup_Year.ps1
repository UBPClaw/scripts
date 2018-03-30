

$Gyear = (get-date (get-date).AddYears(-3) -f yyyy)

$source = "\\malibu\it\CISReports\DocForm\MITINV"

New-Item $source\$Gyear -type directory

$MovePdf = Get-ChildItem  $source -Filter *.pdf |
Where-Object {$_.LastWriteTime.date.year -eq $Gyear} 
	foreach ($DocPdf in $MovePdf)
		{
			Move-Item $source\$DocPdf $source\$Gyear
		}
	
$MovePs = Get-ChildItem  $source -Filter *.ps |
Where-Object {$_.LastWriteTime.date.year -eq $Gyear} 
	foreach ($DocPdf in $MovePs)
		{
			Move-Item $source\$DocPdf $source\$Gyear
		}