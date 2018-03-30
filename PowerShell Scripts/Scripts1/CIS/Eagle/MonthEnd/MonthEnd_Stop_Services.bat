REM This Bat file will Freeze the Cluster preventing an automatic failover from one server
REM to the other when the Universe services are stopped.  The following 3 Univers services
REM will then be stopped: unirpc, uvtelnet, and universe. Once the services have been stopped,
REM this bat file will call the create_snapshot_before.cmd. This bat file will snap off the
REM before volume for backup.


hares -offline UniRPCService -sys EAGLE

hares -offline UniverseTelnetService -sys EAGLE

hares -offline UniverseResourceService -sys EAGLE

pskill tl_server.exe
	

REM This script stops the above services, calls E:\Scripts\MonthEnd\MonthEnd_Create_SnapShot_Before.cmd
REM and then exits
REM To see E:\Scripts\MonthEnd\MonthEnd_Create_SnapShot_Before.cmd for the remaining process

call E:\Scripts\MonthEnd\MonthEnd_Create_SnapShot_Before.cmd






