if ( (Get-Module -Name virtualmachinemanager -ErrorAction SilentlyContinue) -eq $null ) 
{ 
    import-module virtualmachinemanager
} 


Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

$log = "\\malibu\it\VirtualEnvironments\HyperV\VMs2012_"+(Time-Stamp)+".csv"
$log2 = "\\malibu\it\VirtualEnvironments\HyperV\Hosts2012_"+(Time-Stamp)+".csv"
$vmmserver = "powc-scvm-02-pv"

function Get-VMdata{
<#
.SYNOPSIS
Get the configuration data of the VMs in Hyper-V via SCVMM 2012
 
.DESCRIPTION
Use this function to get all VMs configuration in case of disaster or just statistics
 
.PARAMETER  xyz 
 
.NOTES
Author: Niklas Akerlund / RTS
Date: 2012-02-13
#>
param (
	$VMHostGroup = "All Hosts",
	#[Parameter(ValueFromPipeline=$True)][Alias('ClusterName')]
	$VMHostCluster = $null,
	$VMHost = $null,
	[string]$CSVFile = "VMdata.csv"
    #[string]$HTMLReport = "VMdata.html"
    )
	
	$report = @()
	$VMHosts = Get-SCVMHost -VMMServer $vmmserver
	
#adding sort
	$VMs = $VMHosts | Get-SCVirtualMachine | sort HostName
	
	foreach ($VM in $VMs) {
		$CustomGroup = Get-SCCustomProperty -Name "Group"
		$Group = Get-SCCustomPropertyValue -InputObject $VM -CustomProperty $CustomGroup
		$VHDs = $VM | Get-SCVirtualDiskDrive
		$i = "1"
		foreach ($VHDconf in $VHDs){ 
			if($i -eq "1"){
				$data = New-Object PSObject -property @{
					Group=$Group.Value
					VMName=$VM.Name
					VMDescription=$VM.Description
					VMStatus=$VM.Status
					VMOperatingSystem=$VM.OperatingSystem
					vCPUs=$VM.CPUCount
			        MemoryGB= $VM.Memory/1024
					VHDName = $VHDconf.VirtualHardDisk.Name
					VHDSize = $VHDconf.VirtualHardDisk.MaximumSize/1GB
					VHDCurrentSize = [Math]::Round($VHDconf.VirtualHardDisk.Size/1GB)
					VHDType = $VHDconf.VirtualHardDisk.VHDType
					VHDBusType = $VHDconf.BusType
					VHDBus = $VHDconf.Bus
					VHDLUN = $VHDconf.Lun
					VHDDatastore = $VHDconf.VirtualHardDisk.HostVolume
					HostName = $VM.HostName
				}
				$i= "2"
			}else{
				$data = New-Object PSObject -property @{
					VMName=""
			        vCPUs=""
			        MemoryGB= ""
					VHDName = $VHDconf.VirtualHardDisk.Name
					VHDSize = $VHDconf.VirtualHardDisk.MaximumSize/1GB
					VHDCurrentSize = [Math]::Round($VHDconf.VirtualHardDisk.Size/1GB)
					VHDType = $VHDconf.VirtualHardDisk.VHDType
					VHDBusType = $VHDconf.BusType
					VHDBus = $VHDconf.Bus
					VHDLUN = $VHDconf.Lun
					VHDDatastore = $VHDconf.VirtualHardDisk.HostVolume
				}
			}
			$report +=$data	
		}
	}
	$report | Select-Object Group,VMName,VMDescription,VMStatus,VMOperatingSystem,vCPUs,MemoryGB,VHDName,VHDSize,VHDCurrentSize,VHDType,VHDBusType,VHDBus,VHDLUN,VHDDatastore,HostName | Export-Csv -Path $log -NoTypeInformation -UseCulture
}

Get-VMdata

Get-SCVMHost -vmmserver powc-scvm-02-pv | sort-object Computername | select Computername, VMHostGroup, OperatingSystem, @{n='TotalMemory (GB)';e={($_.TotalMemory / 1gb).tostring("F02")}}, @{n='AvailableMemory (GB)';e={($_.AvailableMemory / 1kb).tostring("F02")}}, PhysicalCPUCount, CoresPerCPU, LogicalCPUCount |  export-csv $log2 -notype

# SIG # Begin signature block
# MIIIiAYJKoZIhvcNAQcCoIIIeTCCCHUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDD197rnhJ/RXXqilv+RwbHDG
# A72gggXKMIIFxjCCBK6gAwIBAgITHgAAAFL5CEIZoNcxqgAAAAAAUjANBgkqhkiG
# 9w0BAQUFADBvMRMwEQYKCZImiZPyLGQBGRYDY29tMR4wHAYKCZImiZPyLGQBGRYO
# bWl0Y2hlbGxyZXBhaXIxFDASBgoJkiaJk/IsZAEZFgRjb3JwMSIwIAYDVQQDExlj
# b3JwLVBPV0MtQ0VSVC0wMS1QVi1DQS0xMB4XDTE1MTAxNDE0MDkyOFoXDTE4MTAx
# NDE0MTkyOFowgYIxCzAJBgNVBAgTAkNBMQ4wDAYDVQQHEwVQb3dheTESMBAGA1UE
# ChMJTWl0Y2hlbGwxMQwwCgYDVQQLEwNJL1QxFTATBgNVBAMTDG0xcG93ZXJzaGVs
# bDEqMCgGCSqGSIb3DQEJARYbYWRtaW5pc3RyYXRvckBtaXRjaGVsbDEuY29tMIIB
# IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAupP/cV5hQGZHPW6MzZAi7BRC
# QGZEQcvFSIrcuUZZPA2hr7WoTGMP5pBeN80H5bvgwLSHnkaN3YqkJ+O7fW3G9Ld/
# GJdmEIC2ZtNZHQmOFUcyOUQZ7/TP5nAZV+rg0fwnXNxAfVWiqn7ZB1asQ+PA88/L
# 3Kh2qCbmt/KF4s25tFMkc8ioQcsk5aWufrWJL7MiG85MpoZq5zubH6R9gQRpSNmY
# hM437S6gdfgXkhcmj0p1hgMPqhnVdthn7TZSv5dXk/wLgXdrwNMFXpFVTsW9vqUi
# rC7LaIdCpVZxRC7lkrtiebrui5tm/v2nnKE5kAT0iXXaKv1S4VueaML7YlPGsQID
# AQABo4ICRTCCAkEwDgYDVR0PAQH/BAQDAgTwMBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MB0GA1UdDgQWBBRjDfcUckmjVCF1O6Ul/JZYFF/8CjAfBgNVHSMEGDAWgBShr0z8
# Xr9VFmmQrmzt2rec3BHzTDCB7gYDVR0fBIHmMIHjMIHgoIHdoIHahoHXbGRhcDov
# Ly9DTj1jb3JwLVBPV0MtQ0VSVC0wMS1QVi1DQS0xLENOPXBvd2MtY2VydC0wMS1w
# dixDTj1DRFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMs
# Q049Q29uZmlndXJhdGlvbixEQz1jb3JwLERDPW1pdGNoZWxscmVwYWlyLERDPWNv
# bT9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JM
# RGlzdHJpYnV0aW9uUG9pbnQwgdoGCCsGAQUFBwEBBIHNMIHKMIHHBggrBgEFBQcw
# AoaBumxkYXA6Ly8vQ049Y29ycC1QT1dDLUNFUlQtMDEtUFYtQ0EtMSxDTj1BSUEs
# Q049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmln
# dXJhdGlvbixEQz1jb3JwLERDPW1pdGNoZWxscmVwYWlyLERDPWNvbT9jQUNlcnRp
# ZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTAM
# BgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBBQUAA4IBAQCsJQxqQyKSW+TVSGvWP0Pf
# EHjdVJ6lxSyrdBacDAPM30fUFMlIzEsBSMQnKMbvzPCFyk2dCK8r6EZJngHRpB/d
# VG/ZMtpN0wNOpY8qFkbbZWnfOZmEaIFY9MJcMixu1uqPllMhjluy4CMPGk5I9x06
# 5CbYI7r7r4rV6qVWQqYXvTsU5LiUGcWAGJzSIgd6yioWQc+m8vM8/v5mGzO5xhTR
# 69Co38L+5lVoN3C/lMXcynzwj5LW7uUBsCbsD8g8LpnwkhnIoRJ7CCdMVJZPxFam
# XUT5bV8/XyhR7zM0V6MOKu74uq83+K0BAtpDFUJVFKOqtQAlgVTjSjRtaEURe5xd
# MYICKDCCAiQCAQEwgYYwbzETMBEGCgmSJomT8ixkARkWA2NvbTEeMBwGCgmSJomT
# 8ixkARkWDm1pdGNoZWxscmVwYWlyMRQwEgYKCZImiZPyLGQBGRYEY29ycDEiMCAG
# A1UEAxMZY29ycC1QT1dDLUNFUlQtMDEtUFYtQ0EtMQITHgAAAFL5CEIZoNcxqgAA
# AAAAUjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUMsTNM39vm9+qgSr88PJJRGohRqUwDQYJKoZI
# hvcNAQEBBQAEggEAl042zmMtn++KNgqJL82d/HbKqb9bTY+CyZdaQ/n0MCVa0F/1
# D4J29wRivW+gliYpstWR4zRTaXcy1JY22PEkhmDb2TaeznmuHWUxsgVeSNjMw83n
# IBRj4xVHa7eY83t0/Vj3f7VHO63fod3ByPkI6zq0rfo7B7MyZc0pJ1wj7SMIWhib
# lML2j6PLHkJ6+ubLoZzVMDTGCaf2Qn9cuKS5YsE6Mhu/53fDAFlifPwol7g7u6FW
# eUxS2fYiiF4gCQzuJy4F8SNreF5M6twCtjRN9i61ofTtFPkQi8TYHW6FkF50EeM/
# jzMIBms99wOwKGy7HTdUTK7llugUbQ7qsKpd8Q==
# SIG # End signature block
