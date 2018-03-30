# Script to Update Mitchell1.com Internal DNS when Hosting is running out of Poway
# If sites are missing they need to be added to $InputFile 

# Environment Setup 
$DNSServer = "charger"
$ZoneName = "mitchell1.com"
$InputFile = "\\malibu\it\Scripts\Powershell\Mitchell1_Hosting_DNS_Updates\poway_dnsrecords.csv" 
 
# Read the input file which is formatted as name,address with a header row 
$records = Import-CSV $InputFile 
 
# Now we loop through the file to delete and re-create records 
ForEach ($record in $records) { 
 
    # Capture the record contents as variables 
    $recordName = $record.name 
    $recordAddress = $record.address
		# Reset NodeDNS to Null
		$NodeDNS = $null
		# Check for existing DNS Record
		$NodeDNS = Get-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -Node $recordName -RRType A -ErrorAction SilentlyContinue
		if($NodeDNS -eq $null){
    Write-Host "No DNS record found for $recordName"
		} else {
    	# Remove the DNS record
    	Remove-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -InputObject $NodeDNS -Force
    	# Add the DNS record
    	Add-DnsServerResourceRecordA -ZoneName $ZoneName -ComputerName $DNSServer -Name $recordName -IPv4Address $recordAddress -TimeToLive 00:05:00
    	# Verify the record updated
			Get-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -Node $recordName -RRType A -ErrorAction SilentlyContinue
		}
}

# Clear the DNS Servers Cache
Clear-DnsServerCache –ComputerName "yukon" -Force
Clear-DnsServerCache –ComputerName "charger" -Force
Clear-DnsServerCache –ComputerName "hummer" -Force
Clear-DnsServerCache –ComputerName "h2" -Force
Clear-DnsServerCache –ComputerName "sjos-m1dc-01-pv" -Force


# To flush dns on Proxy servers
# RDP to envoy and run "ipconfig /flushdns"
# ssh to powc-iwss-01-pv and run "nscd -i hosts"

# Clear Hosting DNS Servers Cache
# RDP to powh-dc-01-pv start powershell and run
# Clear-DnsServerCache –ComputerName "powh-dc-01-pv" -Force
# Clear-DnsServerCache –ComputerName "sjoh-dc-01-pv" -Force