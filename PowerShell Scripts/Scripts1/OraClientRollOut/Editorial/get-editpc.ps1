remove-Item c:\temp\editorialpc6.txt
remove-Item c:\temp\edpc2.txt
$s=get-content C:\workdir\Meps\EditorialDeptUID.txt #List of Editors from Active directory
$s | %{
select-string -path C:\workdir\ADPC2User20070119014631.log -pattern $_ | add-content c:\temp\editorialpc6.txt
}
$frun = gc c:\temp\editorialpc6.txt | foreach {$_.split(":",[StringSplitOptions]::RemoveEmptyEntries)[3]}
$frun2 = $frun | foreach {$_.split(" -",[StringSplitOptions]::RemoveEmptyEntries)[0]} | Out-File c:\temp\edpc2.txt -Append -encoding ASCII