remove-Item c:\workdir\meps\GraphicsDept\Graphicspc6.txt
remove-Item c:\workdir\meps\GraphicsDept\Graphicspc2.txt

#You will need an updated text file with all computers in the domain.
#You will need to launch C:\Workdir\ActiveDirectory\ADPC2User.ps1 to create the list.
#The list will be dumped to C:\Workdir\Meps.
#If you already have a current list, then simply copy and paste the name from C:\Workdir\Meps.
$getLog =Read-Host "Copy and paste the log name"

$s=get-content C:\workdir\Meps\GraphicsDept\GraphicsDeptUID.txt #List of Editors from Active directory
$s | %{
select-string -path C:\workdir\meps\$getLog -pattern $_ | add-content c:\workdir\meps\GraphicsDept\Graphicspc6.txt
}
$frun = gc c:\workdir\meps\GraphicsDept\Graphicspc6.txt | foreach {$_.split(":",[StringSplitOptions]::RemoveEmptyEntries)[3]}
$frun2 = $frun | foreach {$_.split(" -",[StringSplitOptions]::RemoveEmptyEntries)[0]} | Out-File c:\workdir\meps\GraphicsDept\Graphicspc2.txt -Append -encoding ASCII