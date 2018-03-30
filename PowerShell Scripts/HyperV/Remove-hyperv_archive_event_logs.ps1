# Script to remove Hyper-v Cluster Event Archive Logs older than 2 days

$servers = @()
$Now = Get-Date
$LastWrite = $Now.AddDays(-1)

# Build List of Hyper-V production Servers
$results = PowerShell {get-adcomputer -LDAPFilter "(name=*-hprv-*-pp)"}
  ForEach ($result in $results) {
 $servers += $result.name
  }

# Remove any logs not written to in the last 2 days 
ForEach ($server in $servers) {
get-childitem \\$server\c$\Windows\System32\winevt\Logs -include Archive-Microsoft-Windows-FailoverClustering*.evtx -recurse | Where-Object {$_.LastWriteTime -le $LastWrite} | remove-item -recurse -force
}


#\\malibu\it\Scripts\HyperV\Remove-hyperv_archive_event_logs.ps1