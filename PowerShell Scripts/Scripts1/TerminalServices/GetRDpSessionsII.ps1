$Rdpserver = "c-ofc2010-01"



foreach ($RdpSession in $Rdpserver)

{

($Sessions.count -1) | % {
$sessions = query session /server:$RdpSession

$temp = "" | Select Computer,SessionName, Username, Id, State, Type, Device
                $temp.Computer = $RdpSession
                $temp.SessionName = $sessions[$_].Substring(1,18).Trim()
                $temp.Username = $sessions[$_].Substring(19,20).Trim()
                $temp.Id = $sessions[$_].Substring(39,9).Trim()
                $temp.State = $sessions[$_].Substring(48,8).Trim()
                $temp.Type = $sessions[$_].Substring(56,12).Trim()
                $temp.Device = $sessions[$_].Substring(68).Trim()
				
				$temp.SessionName + "," + $temp.state
				 
				}
				
				
				 
				}
				