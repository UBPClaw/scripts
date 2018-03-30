
$BupDt = (get-date (get-date).AddDays(-2) -f M/d/yyyy)
$FileDate = $BupDt | ForEach-Object {$_-replace "\/","_"}
$BupDtDay = (get-date (get-date).AddDays(-2) -f dddd)

$JobIDScrape = gc D:\BKD_LOGS\NBULOGS\"NBULogsToSQL_"$FileDate.txt |
foreach { $_.split(",")[0]}

foreach ($JobID in $JobIDScrape)

	{
			bperror -hoursago 168 -jobid $JobID -l |

				#Where-Object {$_-match "Copy 1" -and $_-match "IBM"}
				Where-Object {$_-match "IBM"} |
				foreach { $_.split(",")[3]}|
				ForEach-Object {$_ -replace " to media id ","$JobID,"} |
				ForEach-Object {$_ -replace " \(index 0\)",""} |
				ForEach-Object {$_ -replace " \(index 1\)",""} |
				ForEach-Object {$_ -replace " \(index 2\)",""} |
				ForEach-Object {$_ -replace " \(index 3\)",""} |
				ForEach-Object {$_ -replace " \(index 4\)",""} |
				ForEach-Object {$_ -replace " \(index 5\)",""} |
								ForEach-Object {$_ -replace " on drive IBM.ULTRIUM-TD2.",",TAPE DRV "} |
								
				Out-File "D:\BKD_LOGS\NBULOGS\DriveDetailsTest.txt" -append
				$JobID
	
	}
	
	 gc D:\BKD_LOGS\NBULOGS\DriveDetailsTest.txt |sort | Get-Unique |Out-File D:\BKD_LOGS\NBULOGS\"DriveDetailsTest_"$FileDate.txt
  