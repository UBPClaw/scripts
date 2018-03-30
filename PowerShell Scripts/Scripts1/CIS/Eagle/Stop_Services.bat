REM This Bat file will Freeze the Cluster preventing an automatic failover from one server
REM to the other when the Universe services are stopped.  The following 3 Univers services
REM will then be stopped: unirpc, uvtelnet, and universe. Once the services have been stopped,
REM this bat file will call the create_snapshot_before.cmd. This bat file will snap off the
REM before volume for backup.


hares -offline UniRPCService -sys EAGLE

hares -offline UniverseTelnetService -sys EAGLE

hares -offline UniverseResourceService -sys EAGLE

pskill tl_server.exe
	


call E:\Scripts\create_snapshot_before.cmd




