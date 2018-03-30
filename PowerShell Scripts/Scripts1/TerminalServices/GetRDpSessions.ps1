Function Get-ComputerSession {


[cmdletbinding(
        DefaultParameterSetName = 'session',
        ConfirmImpact = 'low'
)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True)]
            [string[]]$computer
        )             
Begin {
    $report = @()
    }



Process { 
ForEach($RdpServer in $computer) {



          $sessions = query session /server:$RdpServer
               ($sessions.count -1) | % {
                $temp = "" | Select Computer,SessionName, Username, Id, State, Type, Device
                $temp.Computer = $RdpServer
                $temp.SessionName = $sessions[$_].Substring(1,18).Trim()
                $temp.Username = $sessions[$_].Substring(19,20).Trim()
                $temp.Id = $sessions[$_].Substring(39,9).Trim()
                $temp.State = $sessions[$_].Substring(48,8).Trim()
                $temp.Type = $sessions[$_].Substring(56,12).Trim()
                $temp.Device = $sessions[$_].Substring(68).Trim()
                $report += $temp
			}
		}
	}
	End {
		$report
		}
}
Get-ComputerSession -computer "c-ofc2010-01"
