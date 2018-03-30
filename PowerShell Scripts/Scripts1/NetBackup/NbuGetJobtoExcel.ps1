$client = "dpr01"
$policy = "DPR_DD1"
$Sched = "Daily"
$bdate = ""
$Edate = ""
Remove-Item "C:\Workdir\Nbackup\JobStatus\BPIMAGELIST\outjob.txt"
$Gjob = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -U -policy $policy -d $bdate -e $Edate -client $client -sl $Sched |
#$Gjob = psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bpimagelist" -U -policy $policy -d 10/01/2008 -e 10/28/2008 -client $client -sl Monthly |

#foreach-object {$_ -replace "Backed Up         Expires       Files       KB  C  Sched Type   Policy",""}|
foreach-object {$_ -replace "Backed Up         Expires       Files       KB  C  Sched Type   Policy","Date,Time,Expires,Files,KB,C,SType,Client,Policy"}|
foreach-object {$_ -replace "----------------  ---------- -------- --------  -  ------------ ------------",""} |
Where {$_ -ne ""} |
foreach-object {$_ -replace "Cumulative I","Cumulative_I $client"} |
foreach-object {$_ -replace "Full Backup","Full $client"} |
foreach-object {$_ -replace " {1,}",","}
   $Gjob |                        
out-file C:\Workdir\Nbackup\JobStatus\BPIMAGELIST\outjob.txt -append


$Gimport = Import-Csv C:\Workdir\Nbackup\JobStatus\BPIMAGELIST\outjob.txt | sort Date #| export-csv C:\Workdir\Nbackup\JobStatus\BPIMAGELIST\outjob.csv -NoTypeInformation
#Import-Csv C:\Workdir\Nbackup\JobStatus\BPIMAGELIST\outjob.txt | get-member

$Gimport
$Gimport | get-member


#$strComputer = "."

$Excel = New-Object -Com Excel.Application
$Excel.visible = $True
$Excel = $Excel.Workbooks.Add()

$Sheet = $Excel.WorkSheets.Item(1)
$Sheet.Cells.Item(1,1) = "DATE"
$Sheet.Cells.Item(1,2) = "TIME"
$Sheet.Cells.Item(1,3) = "EXPIRES"
$Sheet.Cells.Item(1,4) = "FILES"
$Sheet.Cells.Item(1,5) = "KB"
$Sheet.Cells.Item(1,6) = "C"
$Sheet.Cells.Item(1,7) = "STYPE"
$Sheet.Cells.Item(1,8) = "CLIENT"
$Sheet.Cells.Item(1,9) = "POLICY"


$WorkBook = $Sheet.UsedRange
$WorkBook.Interior.ColorIndex = 8
$WorkBook.Font.ColorIndex = 11
$WorkBook.Font.Bold = $True

$intRow = 2

foreach ($objItem in $Gimport) {
    $Sheet.Cells.Item($intRow,1) = $objItem.Date
    $Sheet.Cells.Item($intRow,2) = $objItem.Time
    $Sheet.Cells.Item($intRow,3) = $objItem.Expires
    $Sheet.Cells.Item($intRow,4) = $objItem.Files
    $Sheet.Cells.Item($intRow,5) = $objItem.KB
    $Sheet.Cells.Item($intRow,6) = $objItem.C
	$Sheet.Cells.Item($intRow,7) = $objItem.SType
	$Sheet.Cells.Item($intRow,8) = $objItem.Client
	$Sheet.Cells.Item($intRow,9) = $objItem.Policy
	
	
$intRow = $intRow + 1

}
$WorkBook.EntireColumn.AutoFit()
Clear

