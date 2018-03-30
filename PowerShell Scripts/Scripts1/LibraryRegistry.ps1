##################################################
# LibraryRegistry.ps1
# Functions within this file can be used to read and 
# manipulate the registry on a local or remote machine.
# 
# Created: 10/31/2006
# Author: Tyson Kopczynski
##################################################
#-------------------------------------------------
# Get-RegValue
#-------------------------------------------------
# Usage:        Used to read an HKLM a registry value 
#               on a local or remote machine.
# $Computer:    The name of the computer.
# $KeyPath:     The registry key path. 
#               ("SYSTEM\CurrentControlSet\Control")
# $ValueName:   The registry value name. ("CurrentUser") 
# $Type:        The registry value type. ("BIN", "DWORD", 
#               "EXP", "MULTI", or "STR")    

function Get-RegValue{
    param ($Computer, $KeyPath, $ValueName, $Type)

    $HKEY_LOCAL_MACHINE = 2147483650

    trap{write-host "[ERROR] $_" -Foregroundcolor Red; Continue}

    $Reg = get-wmiobject -Namespace Root\Default -computerName `
        $Computer -List | where-object `
        {$_.Name -eq "StdRegProv"}

    if ($Type -eq "BIN"){
        return $Reg.GetBinaryValue($HKEY_LOCAL_MACHINE, $KeyPath, `
            $ValueName)
        }
    elseif ($Type -eq "DWORD"){
        return $Reg.GetDWORDValue($HKEY_LOCAL_MACHINE, $KeyPath, `
            $ValueName)
        }
    elseif ($Type -eq "EXP"){
        return $Reg.GetExpandedStringValue($HKEY_LOCAL_MACHINE, `
            $KeyPath, $ValueName)
        }
    elseif ($Type -eq "MULTI"){
        return $Reg.GetMultiStringValue($HKEY_LOCAL_MACHINE, `
            $KeyPath, $ValueName)
        }
    elseif ($Type -eq "STR"){
        return $Reg.GetStringValue($HKEY_LOCAL_MACHINE, `
            $KeyPath, $ValueName)
        }
    }

#-------------------------------------------------
# Set-RegKey
#-------------------------------------------------
# Usage:        Used to create/set an HKLM registry key
#               on a local or remote machine.
# $Computer:    The name of the computer.
# $KeyPath:     The registry key path. 
#               ("SYSTEM\CurrentControlSet\Control") 

function Set-RegKey{
    param ($Computer, $KeyPath)

    $HKEY_LOCAL_MACHINE = 2147483650

    trap{write-host "[ERROR] $_" -Foregroundcolor Red; Continue}

    $Reg = get-wmiobject -Namespace Root\Default -computerName `
        $Computer -List | where-object `
        {$_.Name -eq "StdRegProv"}
        
    return $Reg.CreateKey($HKEY_LOCAL_MACHINE, $KeyPath)
    }

#-------------------------------------------------
# Set-RegValue
#-------------------------------------------------
# Usage:        Used to create/set an HKLM registry value
#               on a local or remote machine.
# $Computer:    The name of the computer.
# $KeyPath:     The registry key path. 
#               ("SYSTEM\CurrentControlSet\Control")
# $ValueName:   The registry value name. ("CurrentUser")
# $Value:       The registry value. ("value1", Array, Integer) 
# $Type:        The registry value type. ("BIN", "DWORD", 
#               "EXP", "MULTI", or "STR") 

function Set-RegValue{
    param ($Computer, $KeyPath, $ValueName, $Value, $Type)

    $HKEY_LOCAL_MACHINE = 2147483650

    trap{write-host "[ERROR] $_" -Foregroundcolor Red; Continue}

    $Reg = get-wmiobject -Namespace Root\Default -computerName `
        $Computer -List | where-object `
        {$_.Name -eq "StdRegProv"}

    if ($Type -eq "BIN"){
        return $Reg.SetBinaryValue($HKEY_LOCAL_MACHINE, $KeyPath, `
            $ValueName, $Value)
        }
    elseif ($Type -eq "DWORD"){
        return $Reg.SetDWORDValue($HKEY_LOCAL_MACHINE, $KeyPath, `
            $ValueName, $Value)
        }
    elseif ($Type -eq "EXP"){
        return $Reg.SetExpandedStringValue($HKEY_LOCAL_MACHINE, `
            $KeyPath, $ValueName, $Value)
        }
    elseif ($Type -eq "MULTI"){
        return $Reg.SetMultiStringValue($HKEY_LOCAL_MACHINE, `
            $KeyPath, $ValueName, $Value)
        }
    elseif ($Type -eq "STR"){
        return $Reg.SetStringValue($HKEY_LOCAL_MACHINE, `
            $KeyPath, $ValueName, $Value)
        }
    }
    
#-------------------------------------------------
# Remove-RegKey
#-------------------------------------------------
# Usage:        Used to delete an HKLM registry key
#               on a local or remote machine.
# $Computer:    The name of the computer.
# $KeyPath:     The registry key path. 
#               ("SYSTEM\CurrentControlSet\Control") 

function Remove-RegKey{
    param ($Computer, $KeyPath)

    $HKEY_LOCAL_MACHINE = 2147483650

    trap{write-host "[ERROR] $_" -Foregroundcolor Red; Continue}

    $Reg = get-wmiobject -Namespace Root\Default -computerName `
        $Computer -List | where-object `
        {$_.Name -eq "StdRegProv"}
        
    return $Reg.DeleteKey($HKEY_LOCAL_MACHINE, $KeyPath)
    }

#-------------------------------------------------
# Remove-RegValue
#-------------------------------------------------
# Usage:        Used to delete an HKLM registry value
#               on a local or remote machine.
# $Computer:    The name of the computer.
# $KeyPath:     The registry key path. 
#               ("SYSTEM\CurrentControlSet\Control")
# $ValueName:   The registry value name. ("CurrentUser")

function Remove-RegValue{
    param ($Computer, $KeyPath, $ValueName)

    $HKEY_LOCAL_MACHINE = 2147483650

    trap{write-host "[ERROR] $_" -Foregroundcolor Red; Continue}

    $Reg = get-wmiobject -Namespace Root\Default -computerName `
        $Computer -List | where-object `
        {$_.Name -eq "StdRegProv"}
        
    return $Reg.DeleteValue($HKEY_LOCAL_MACHINE, $KeyPath, $ValueName)
    }
# SIG # Begin signature block
# MIIMywYJKoZIhvcNAQcCoIIMvDCCDLgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGIlyVNR2UmB9udi/ANqVMyKc
# S0+gggorMIIDJzCCApCgAwIBAgIBATANBgkqhkiG9w0BAQQFADCBzjELMAkGA1UE
# BhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTESMBAGA1UEBxMJQ2FwZSBUb3du
# MR0wGwYDVQQKExRUaGF3dGUgQ29uc3VsdGluZyBjYzEoMCYGA1UECxMfQ2VydGlm
# aWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEhMB8GA1UEAxMYVGhhd3RlIFByZW1p
# dW0gU2VydmVyIENBMSgwJgYJKoZIhvcNAQkBFhlwcmVtaXVtLXNlcnZlckB0aGF3
# dGUuY29tMB4XDTk2MDgwMTAwMDAwMFoXDTIwMTIzMTIzNTk1OVowgc4xCzAJBgNV
# BAYTAlpBMRUwEwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93
# bjEdMBsGA1UEChMUVGhhd3RlIENvbnN1bHRpbmcgY2MxKDAmBgNVBAsTH0NlcnRp
# ZmljYXRpb24gU2VydmljZXMgRGl2aXNpb24xITAfBgNVBAMTGFRoYXd0ZSBQcmVt
# aXVtIFNlcnZlciBDQTEoMCYGCSqGSIb3DQEJARYZcHJlbWl1bS1zZXJ2ZXJAdGhh
# d3RlLmNvbTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA0jY2aovXwlue2oFB
# Yo847kkEVdbQ7xwblRZH7xhINTpS9CtqBo87L+pW46+GjZ4X9560ZXUCTe/LCaIh
# Udib0GfQug2SBhRz1JPLlyoAnFxODLz6FVL88kRu2hFKbgifLy3j+ao6hnO2RlNY
# yIkFvYMRuHM/qgeN9EJN50CdHDcCAwEAAaMTMBEwDwYDVR0TAQH/BAUwAwEB/zAN
# BgkqhkiG9w0BAQQFAAOBgQAmSCwWwlj66BZ0DKqqX1Q/8tfJeGBeXm43YyJ3Nn6y
# F8Q0ufUIhfzJATj/Tb7yFkJD57taRvvBxhEf8UqwKEbJw8RCfbz6q1lu1bdRiBHj
# pIUZa4JMpAwSremkrj/xw0llmozFyD4lt5SZu5IycQfwhl7tUCemDaYj+bvLpgcU
# QjCCA04wggK3oAMCAQICAQowDQYJKoZIhvcNAQEFBQAwgc4xCzAJBgNVBAYTAlpB
# MRUwEwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEdMBsG
# A1UEChMUVGhhd3RlIENvbnN1bHRpbmcgY2MxKDAmBgNVBAsTH0NlcnRpZmljYXRp
# b24gU2VydmljZXMgRGl2aXNpb24xITAfBgNVBAMTGFRoYXd0ZSBQcmVtaXVtIFNl
# cnZlciBDQTEoMCYGCSqGSIb3DQEJARYZcHJlbWl1bS1zZXJ2ZXJAdGhhd3RlLmNv
# bTAeFw0wMzA4MDYwMDAwMDBaFw0xMzA4MDUyMzU5NTlaMFUxCzAJBgNVBAYTAlpB
# MSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMR8wHQYDVQQD
# ExZUaGF3dGUgQ29kZSBTaWduaW5nIENBMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCB
# iQKBgQDGuLknYK8L45FpZdt+je2R5qrxvtXt/m3ULH/RcHf7JplXtN0/MLjcIepo
# jYGS/C5LkTWEIPLaSrq0/ObaiPIgxSGSCUeVoAkcpnm+sUwd/PGKblTSaaHxTJM6
# Qf591GR7Y0X3YGAdMR2k6dMPi/tuJiSzqP/l5ZDUtMLcUGCuWQIDAQABo4GzMIGw
# MBIGA1UdEwEB/wQIMAYBAf8CAQAwQAYDVR0fBDkwNzA1oDOgMYYvaHR0cDovL2Ny
# bC50aGF3dGUuY29tL1RoYXd0ZVByZW1pdW1TZXJ2ZXJDQS5jcmwwHQYDVR0lBBYw
# FAYIKwYBBQUHAwIGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIBBjApBgNVHREEIjAg
# pB4wHDEaMBgGA1UEAxMRUHJpdmF0ZUxhYmVsMi0xNDQwDQYJKoZIhvcNAQEFBQAD
# gYEAdrKc7hOfG/YtNJKURXM03I5rLlz8TH2J68No8deZDy4dF8i1Fou+zYoFBvIZ
# SToDWwXJII5tUuF2gaDDZYoiZ+QcU1M3Rr+81y/re57QFEVsQCEI4l11dmYwHvTf
# goovvfOiDL8d258UoppyN02wd0joSj8JzlUZLO/mByThr+wwggOqMIIDE6ADAgEC
# AhAaB4sUlpgPs6Hq/y+uOpfhMA0GCSqGSIb3DQEBBQUAMFUxCzAJBgNVBAYTAlpB
# MSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMR8wHQYDVQQD
# ExZUaGF3dGUgQ29kZSBTaWduaW5nIENBMB4XDTA2MTAwNTAwMDAwMFoXDTA4MTAw
# NDIzNTk1OVowczELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExEDAO
# BgNVBAcTB09ha2xhbmQxFzAVBgNVBAoTDmNvbXBhbnlhYmMuY29tMQswCQYDVQQL
# EwJJVDEXMBUGA1UEAxMOY29tcGFueWFiYy5jb20wggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDa7qCoFx5g8HE6wIc3IEYVU2xbeWFL57b/zPkRwPZcvJfY
# ypC/IijwGYV0fOZOUmiMXL+/EoMlMszmGYGiQbeweDVijGYYfAyDeiXsa3NDt1ud
# dbN3iBjoYST/fetkdL1e6yactF29MpHMtVwA5Mgr6TXTr4msMBAdG487J/ujKLAb
# Bv8SvsV8olNqeOAkqcUJG2xcNEU6z/wrEhfriPgHHsGyDf4gKztCUeroWGyVJPz5
# Rq3Wpgi07zs5VKxNiSufjOh8ew5gboVylJ2efvHhLUb62YoW4Vq2nQGmjL3HX5w5
# wsEsCKoD8ZLGT8qlK1YMmfoK/VZJsP+ydfGHtKcJAgMBAAGjgdgwgdUwDAYDVR0T
# AQH/BAIwADA+BgNVHR8ENzA1MDOgMaAvhi1odHRwOi8vY3JsLnRoYXd0ZS5jb20v
# VGhhd3RlQ29kZVNpZ25pbmdDQS5jcmwwHwYDVR0lBBgwFgYIKwYBBQUHAwMGCisG
# AQQBgjcCARYwHQYDVR0EBBYwFDAOMAwGCisGAQQBgjcCARYDAgeAMDIGCCsGAQUF
# BwEBBCYwJDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AudGhhd3RlLmNvbTARBglg
# hkgBhvhCAQEEBAMCBBAwDQYJKoZIhvcNAQEFBQADgYEAT0BOmxgOLTPPqPhCKqf9
# 17nHCn1w0Bp0Qg/MJnsMuAqRuIL+Wlvxrp6DAPfzvrTI1wKd5b5TwuKwub0u45CI
# qSdglyF4efza6ksSmEPRaUGEnY2/p8Nc9ku7K+MPBTnFGfPFwfvFschi+8KMP1f/
# c4+QHoGcSRgRxhJjb+T9YxwxggIKMIICBgIBATBpMFUxCzAJBgNVBAYTAlpBMSUw
# IwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMR8wHQYDVQQDExZU
# aGF3dGUgQ29kZSBTaWduaW5nIENBAhAaB4sUlpgPs6Hq/y+uOpfhMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3
# DQEJBDEWBBQqIU/EoI+TwkSUnAmSueKwgk9zgzANBgkqhkiG9w0BAQEFAASCAQBK
# Pw2eVHBQcV4f/q4T7vCOADUHVBWelJje4ggokqcOs7Y5RoyjrXqQ9qwcm8Jdn40b
# q729BOvcOCXCrG2tUpuAir1ptjQcO4RxypNBKsgQmH59/DewXV/PT2LmtOAxQ6sI
# viVPUx1IEvTZksZ8lzXnO5SebXIGbl5JreD88mZlkDBPfnLXtYsEK7DCnEHv8Xo1
# Un5CVOOYBn82JlZVo4Yc0uYMDjmwP+LIBIx3wt7Yky+xOFYJl8fKpw3BlIq1Cre1
# QzM0porlYA62YUDAwd25XaRF19Rzt/RcuQomYH658/1z2pZLZFtL5lgaKytrEjS4
# Wd5iSmV5YTpk7nwVV8mA
# SIG # End signature block
