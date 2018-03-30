Get-QADUser |  
where {$_.FirstName -ne $NUL -and $_.LastName -ne $NUL} | Format-Table FirstName, LastName, LogonName , Title | Out-File c:\DomainUsers.txt -append