
Function move-iislogs ($Source,$Target) {
$Moving1 = $Source 
$Moving2 = $Target
    $LastMonth = (get-date (get-date).AddMonths(-1) -f yyMM)
 	$logs = Get-ChildItem ($Source) |
		where {$_.name -match "ex"+$LastMonth } 
		$logs 
		foreach ($File in $Logs)
			{
			if ($File -eq $NUL)
			{
			}
			else
			{
				Move-Item $Moving1\$File $Moving2
				}
				}
		
}

$LastMonth1 = (get-date (get-date).AddMonths(-1) -f MMMyyy)

$LastMon = New-Item \\s600\f$\IISLOGS\Archive\$LastMonth1 -type directory


$Products = "AutorepairData,CRM,eAutorepair,License,mitchell1pc,Ondemand5,Ondemand5direct,Shopkey5,Shopkeyrewards,Tractor-trailer" | 
	foreach-object {$_.split(",")}
foreach ($product in $Products)
	{
		New-Item \\s600\f$\IISLOGS\Archive\$LastMonth1\$product -type directory
		
		$WebServers = "pweb01,pweb02,pweb03,pweb04,pweb05,pweb06,pweb07,pweb08,pweb09,esv" |
			foreach-object {$_.split(",")}
			
			foreach ($server in $WebServers)
				{
					New-Item \\s600\f$\IISLOGS\Archive\$LastMonth1\$product\$server -type directory
				}
	}



# ---------------  AUTOREPAIRDATA
$Source1 = "\\s600\f$\IISLOGS\AutorepairData\pweb01"
$Target1 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb01"
$Source2 = "\\s600\f$\IISLOGS\AutorepairData\pweb02"
$Target2 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb02"
$Source3 = "\\s600\f$\IISLOGS\AutorepairData\pweb03"
$Target3 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb03"
$Source4 = "\\s600\f$\IISLOGS\AutorepairData\pweb04"
$Target4 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb04"
$Source5 = "\\s600\f$\IISLOGS\AutorepairData\pweb05"
$Target5 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb05"
$Source6 = "\\s600\f$\IISLOGS\AutorepairData\pweb06"
$Target6 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb06"
$Source7 = "\\s600\f$\IISLOGS\AutorepairData\pweb07"
$Target7 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb07"
$Source8 = "\\s600\f$\IISLOGS\AutorepairData\pweb08"
$Target8 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb08"
$Source9 = "\\s600\f$\IISLOGS\AutorepairData\pweb09"
$Target9 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\AutorepairData\pweb09"



move-iislogs $Source1 $Target1
move-iislogs $Source2 $Target2
move-iislogs $Source3 $Target3
move-iislogs $Source4 $Target4
move-iislogs $Source5 $Target5
move-iislogs $Source6 $Target6
move-iislogs $Source7 $Target7
move-iislogs $Source8 $Target8
move-iislogs $Source9 $Target9


# --------------- CRM
$Source10 = "\\s600\f$\IISLOGS\CRM\ESV"
$Target10 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\CRM\ESV"

move-iislogs $Source10 $Target10



# ---------------  eAutoRepair
$Source11 = "\\s600\f$\IISLOGS\eAutoRepair\pweb01"
$Target11 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb01"
$Source12 = "\\s600\f$\IISLOGS\eAutoRepair\pweb02"
$Target12 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb02"
$Source13 = "\\s600\f$\IISLOGS\eAutoRepair\pweb03"
$Target13 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb03"
$Source14 = "\\s600\f$\IISLOGS\eAutoRepair\pweb04"
$Target14 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb04"
$Source15 = "\\s600\f$\IISLOGS\eAutoRepair\pweb05"
$Target15 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb05"
$Source16 = "\\s600\f$\IISLOGS\eAutoRepair\pweb06"
$Target16 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb06"
$Source17 = "\\s600\f$\IISLOGS\eAutoRepair\pweb07"
$Target17 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb07"
$Source18 = "\\s600\f$\IISLOGS\eAutoRepair\pweb08"
$Target18 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb08"
$Source19 = "\\s600\f$\IISLOGS\eAutoRepair\pweb09"
$Target19 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\eAutoRepair\pweb09"



move-iislogs $Source11 $Target11
move-iislogs $Source12 $Target12
move-iislogs $Source13 $Target13
move-iislogs $Source14 $Target14
move-iislogs $Source15 $Target15
move-iislogs $Source16 $Target16
move-iislogs $Source17 $Target17
move-iislogs $Source18 $Target18
move-iislogs $Source19 $Target19




# ---------------  License

$Source20 = "\\s600\f$\IISLOGS\License\pweb01"
$Target20 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb01"
$Source21 = "\\s600\f$\IISLOGS\License\pweb02"
$Target21 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb02"
$Source22 = "\\s600\f$\IISLOGS\License\pweb03"        
$Target22 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb03"
$Source23 = "\\s600\f$\IISLOGS\License\pweb04"       
$Target23 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb04"
$Source24 = "\\s600\f$\IISLOGS\License\pweb05"
$Target24 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb05"
$Source25 = "\\s600\f$\IISLOGS\License\pweb06"
$Target25 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb06"
$Source26 = "\\s600\f$\IISLOGS\License\pweb07"
$Target26 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb07"
$Source27 = "\\s600\f$\IISLOGS\License\pweb08"
$Target27 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb08"
$Source28 = "\\s600\f$\IISLOGS\License\pweb09"
$Target28 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\License\pweb09"



move-iislogs $Source20 $Target20
move-iislogs $Source21 $Target21
move-iislogs $Source22 $Target22
move-iislogs $Source23 $Target23
move-iislogs $Source24 $Target24
move-iislogs $Source25 $Target25
move-iislogs $Source26 $Target26
move-iislogs $Source27 $Target27
move-iislogs $Source28 $Target28


# ---------------  Mitchell1PC PC

$Source29 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb01"
$Target29 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb01"
$Source30 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb02"
$Target30 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb02"
$Source31 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb03"        
$Target31 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb03"
$Source32 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb04"       
$Target32 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb04"
$Source33 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb05"
$Target33 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb05"
$Source34 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb06"
$Target34 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb06"
$Source35 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb07"
$Target35 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb07"
$Source36 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb08"
$Target36 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb08"
$Source37 = "\\s600\f$\IISLOGS\Mitchell1PC\pweb09"
$Target37 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Mitchell1PC\pweb09"



move-iislogs $Source29 $Target29
move-iislogs $Source30 $Target30
move-iislogs $Source31 $Target31
move-iislogs $Source32 $Target32
move-iislogs $Source33 $Target33
move-iislogs $Source34 $Target34
move-iislogs $Source35 $Target35
move-iislogs $Source36 $Target36
move-iislogs $Source37 $Target37



# ---------------  Ondemand5

$Source38 = "\\s600\f$\IISLOGS\Ondemand5\pweb01"
$Target38 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb01"
$Source39 = "\\s600\f$\IISLOGS\Ondemand5\pweb02"
$Target39 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb02"
$Source40 = "\\s600\f$\IISLOGS\Ondemand5\pweb03"        
$Target40 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb03"
$Source41 = "\\s600\f$\IISLOGS\Ondemand5\pweb04"       
$Target41 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb04"
$Source42 = "\\s600\f$\IISLOGS\Ondemand5\pweb05"
$Target42 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb05"
$Source43 = "\\s600\f$\IISLOGS\Ondemand5\pweb06"
$Target43 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb06"
$Source44 = "\\s600\f$\IISLOGS\Ondemand5\pweb07"
$Target44 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb07"
$Source45 = "\\s600\f$\IISLOGS\Ondemand5\pweb08"
$Target45 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb08"
$Source46 = "\\s600\f$\IISLOGS\Ondemand5\pweb09"
$Target46 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5\pweb09"



move-iislogs $Source38 $Target38
move-iislogs $Source39 $Target39
move-iislogs $Source40 $Target40
move-iislogs $Source41 $Target41
move-iislogs $Source42 $Target42
move-iislogs $Source43 $Target43
move-iislogs $Source44 $Target44
move-iislogs $Source45 $Target45
move-iislogs $Source46 $Target46



# ---------------  Ondemand5directdirect

$Source47 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb01"
$Target47 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb01"
$Source48 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb02"
$Target48 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb02"
$Source49 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb03"        
$Target49 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb03"
$Source50 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb04"       
$Target50 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb04"
$Source51 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb05"
$Target51 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb05"
$Source52 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb06"
$Target52 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb06"
$Source53 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb07"
$Target53 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb07"
$Source54 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb08"
$Target54 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb08"
$Source55 = "\\s600\f$\IISLOGS\Ondemand5direct\pweb09"
$Target55 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Ondemand5direct\pweb09"



move-iislogs $Source47 $Target47
move-iislogs $Source48 $Target48
move-iislogs $Source49 $Target49
move-iislogs $Source50 $Target50
move-iislogs $Source51 $Target51
move-iislogs $Source52 $Target52
move-iislogs $Source53 $Target53
move-iislogs $Source54 $Target54
move-iislogs $Source55 $Target55




# ---------------  Shopkey5

$Source56 = "\\s600\f$\IISLOGS\Shopkey5\pweb01"
$Target56 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb01"
$Source57 = "\\s600\f$\IISLOGS\Shopkey5\pweb02"
$Target57 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb02"
$Source58 = "\\s600\f$\IISLOGS\Shopkey5\pweb03"        
$Target58 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb03"
$Source59 = "\\s600\f$\IISLOGS\Shopkey5\pweb04"       
$Target59 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb04"
$Source60 = "\\s600\f$\IISLOGS\Shopkey5\pweb05"
$Target60 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb05"
$Source61 = "\\s600\f$\IISLOGS\Shopkey5\pweb06"
$Target61 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb06"
$Source62 = "\\s600\f$\IISLOGS\Shopkey5\pweb07"
$Target62 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb07"
$Source63 = "\\s600\f$\IISLOGS\Shopkey5\pweb08"
$Target63 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb08"
$Source64 = "\\s600\f$\IISLOGS\Shopkey5\pweb09"
$Target64 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkey5\pweb09"



move-iislogs $Source56 $Target56
move-iislogs $Source57 $Target57
move-iislogs $Source58 $Target58
move-iislogs $Source59 $Target59
move-iislogs $Source60 $Target60
move-iislogs $Source61 $Target61
move-iislogs $Source62 $Target62
move-iislogs $Source63 $Target63
move-iislogs $Source64 $Target64




# ---------------  Shopkeyrewards

$Source65 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb01"
$Target65 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb01"
$Source66 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb02"
$Target66 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb02"
$Source67 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb03"        
$Target67 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb03"
$Source68 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb04"       
$Target68 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb04"
$Source69 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb05"
$Target69 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb05"
$Source70 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb06"
$Target70 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb06"
$Source71 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb07"
$Target71 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb07"
$Source72 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb08"
$Target72 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb08"
$Source73 = "\\s600\f$\IISLOGS\Shopkeyrewards\pweb09"
$Target73 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Shopkeyrewards\pweb09"



move-iislogs $Source65 $Target65
move-iislogs $Source66 $Target66
move-iislogs $Source67 $Target67
move-iislogs $Source68 $Target68
move-iislogs $Source69 $Target69
move-iislogs $Source70 $Target70
move-iislogs $Source71 $Target71
move-iislogs $Source72 $Target72
move-iislogs $Source73 $Target73


# ---------------  Tractor-trailer

$Source74 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb01"
$Target74 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb01"
$Source75 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb02"
$Target75 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb02"
$Source76 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb03"        
$Target76 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb03"
$Source77 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb04"       
$Target77 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb04"
$Source78 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb05"
$Target78 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb05"
$Source79 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb06"
$Target79 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb06"
$Source80 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb07"
$Target80 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb07"
$Source81 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb08"
$Target81 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb08"
$Source82 = "\\s600\f$\IISLOGS\Tractor-trailer\pweb09"
$Target82 = "\\s600\f$\IISLOGS\Archive\$LastMonth1\Tractor-trailer\pweb09"



move-iislogs $Source74 $Target74
move-iislogs $Source75 $Target75
move-iislogs $Source76 $Target76
move-iislogs $Source77 $Target77
move-iislogs $Source78 $Target78
move-iislogs $Source79 $Target79
move-iislogs $Source80 $Target80
move-iislogs $Source81 $Target81
move-iislogs $Source82 $Target82



