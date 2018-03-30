# Match user to computer using text file for computers append to csv file

$Computer = @()
get-content C:\workdir\testscripts\monad\computerstest.txt |
foreach-object {
$name = $_
$ip = 0
$ping = New-Object Net.NetworkInformation.Ping
&{TRAP{$ip = $null;continue}
$ip = $ping.send("$name").address
if ($ip) { 
        $Computer += get-wmiobject Win32_ComputerSystem -computername $name -ErrorAction SilentlyContinue | select-Object Name,UserName 
      }ELSE { 
        write-host -fore 'yellow' "$name Not found" 
      }
   }
}

# Export to CSV
$Computer  | export-CSV c:\workdir\testscripts\monad\computer2user051506.csv -NoTypeInformation