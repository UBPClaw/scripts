# ==============================================================================================
#Function Name 'Write-Log" - Write to Logfile and Screen
# ==============================================================================================
Function Write-Log {
   Param([string]$msg,[string]$file)
   Write-Host "$msg"
   $msg | Out-File -FilePath $file -encoding ASCII -Append
}

# ==============================================================================================
#Function Name 'Time-Stamp" - Create Time Stamp for Filename
# ==============================================================================================
Function Time-Stamp {
 (get-date).toString('yyyyMMdd')
}

$today = Time-Stamp

# ==============================================================================================
# Create Log File
# ==============================================================================================
$log = "C:\Temp\Logs\M1_AD_W2K3_"+(Time-Stamp)+".csv"


# ==============================================================================================
# Get only active W2K3 computers in the last 90 days
# ==============================================================================================
$W2K3 = Get-ADComputer -Filter {OperatingSystem -like "*2003*"} `
    -Properties Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, LastLogonTimestamp, nTSecurityDescriptor, `
        DistinguishedName, IPv4Address |
    Where-Object {$_.whenChanged -gt $((Get-Date).AddDays(-90))} |
    Select-Object Name, DNSHostName, OperatingSystem, `
        OperatingSystemServicePack, OperatingSystemVersion, PasswordLastSet, `
        whenCreated, whenChanged, `
        @{name='LastLogonTimestampDT';`
            Expression={[datetime]::FromFileTimeUTC($_.LastLogonTimestamp)}}, `
        @{name='Owner';`
            Expression={$_.nTSecurityDescriptor.Owner}}, `
        DistinguishedName, IPv4Address

# ==============================================================================================
# Test if W2K3 computers answer ping and write log
# ==============================================================================================
Write-Log  "Computer,Ping,PasswordLastSet,whenChanged,LastLogonTimestampDT,IPv4Address" $log
$W2K3 | foreach {
	$name = $_.name
	$PasswordLastSet = $_.PasswordLastSet
	$whenChanged = $_.whenChanged
	$LastLogonTimestampDT = $_.LastLogonTimestampDT
	$IPv4Address = $_.IPv4Address
	if((Test-Connection -Cn $name -BufferSize 16 -Count 1 -ea 0 -quiet))
		{
			Write-Log  "$name,Success,$PasswordLastSet,$whenChanged,$LastLogonTimestampDT,$IPv4Address" $log
		}
	else
		{
			Write-Log  "$name,Fail,$PasswordLastSet,$whenChanged,$LastLogonTimestampDT,$IPv4Address" $log
		}
	}


# ==============================================================================================
# Email log
# ==============================================================================================
send-mailmessage -from "Automated Email	<noreply@mitchell1.com>" -to "Brian Stickel	<brian.stickel@mitchell1.com>" -subject "Mitchell1 Active Directory W2K3 Computers For $today" -body "File is attached" -Attachments "$log" -smtpServer smtp.corp.mitchellrepair.com

# ==============================================================================================
# Delete logs older than 7 Days
# ==============================================================================================
$a = Get-ChildItem C:\Temp\Logs
foreach($x in $a)
    {
        $y = ((Get-Date) - $x.CreationTime).Days
        if ($y -gt 7 -and $x.PsISContainer -ne $True)
            {$x.Delete()}
    }
