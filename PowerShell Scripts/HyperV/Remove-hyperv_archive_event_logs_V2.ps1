# Script to remove Hyper-v Cluster Event Archive Logs older than 12 hours
$log = "E:\Scripts\Logs\cleanhypervarchive.log"
$servers = @()
$Now = Get-Date
$LastWrite = $Now.AddHours(-12)
get-date -format g | Out-file $log
# Build List of Hyper-V production Servers
$results = PowerShell {get-adcomputer -LDAPFilter "(name=*-hprv-*-pp)"}
  ForEach ($result in $results) {
 $servers += $result.name
  }

# Remove any logs not written to in the last 12 hours
ForEach ($server in $servers) {
get-childitem \\$server\c$\Windows\System32\winevt\Logs -include Archive-Microsoft-Windows-FailoverClustering*.evtx -recurse | Where-Object {$_.LastWriteTime -le $LastWrite} | remove-item -recurse -force
}


#\\malibu\it\Scripts\HyperV\Remove-hyperv_archive_event_logs_V1.ps1

# SIG # Begin signature block
# MIIIiAYJKoZIhvcNAQcCoIIIeTCCCHUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZ217WwZIKZTGQtH98nVInjt3
# erugggXKMIIFxjCCBK6gAwIBAgITHgAAAFL5CEIZoNcxqgAAAAAAUjANBgkqhkiG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUx+n5bkFZy0UaPq0/xiSJa/Vaxb4wDQYJKoZI
# hvcNAQEBBQAEggEARd+Aeg+7weHNhI9mri/2gA8gr5Tn3Wkt2T0f8hCqVxaCGpRN
# KYy1/229WR9IYVWY6C40WDWxYjE5lANdcJ8rEGAlMdOjcqPE1h/9oUnDQYWufLX6
# UbtqMFA74fv30r9bRZ1a0oxJZp8WBNtnIY0N1g/CbRG1QqYudjuzRsnGGSojaKgN
# 2YXbk5xiQ5fyk2/n8puPsCnbmwD4CZIdvM7ze9TZGhQcVa+KbKycygzzaw9za1Tm
# 7RYAB9s+p/RkhAaNhdiLzD/0Kp0Ziomyg5qfGjaEpQwezSsl1tIY6++TlVEpJfiT
# jscHIoIKmRLnOsidindZjFgFrKZN4brFmWKJZA==
# SIG # End signature block
