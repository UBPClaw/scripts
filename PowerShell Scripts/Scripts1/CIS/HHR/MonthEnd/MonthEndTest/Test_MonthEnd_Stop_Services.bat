rem****This Bat file is for testing the Month End process. Only emails will be sent
rem****in this test. The actuall stopping of services, snappin, and resynching volumes
rem****will not happen.


rem hares -offline UniRPCService -sys EAGLE

rem hares -offline UniverseTelnetService -sys EAGLE

rem hares -offline UniverseResourceService -sys EAGLE

rem pskill tl_server.exe


REM*****Do a Rescan
	
vxassist rescan

call E:\Scripts\MonthEnd\MonthEndTest\Test_MonthEnd_Create_SnapShot_Before.cmd




