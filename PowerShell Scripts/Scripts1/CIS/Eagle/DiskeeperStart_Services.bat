REM This Bat file will UnFreeze the Cluster.
REm and start the UniRPCService,the UniverseTelnetService, and the UniverseResouceServce.
REM The UniverseResouceServce is automatically started by the UniverseTelnetService.

hares -online UniRPCService -sys EAGLE

hares -online UniverseTelnetService -sys EAGLE
