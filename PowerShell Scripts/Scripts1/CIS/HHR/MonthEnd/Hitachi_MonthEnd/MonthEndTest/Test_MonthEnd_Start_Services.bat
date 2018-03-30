REM This Bat file will UnFreeze the Cluster.
REm and start the UniRPCService,the UniverseTelnetService, and the UniverseResouceServce.
REM The UniverseResouceServce is automatically started by the UniverseTelnetService.

REM*** Execute a Scan

vxassist rescan

call E:\Scripts\MonthEnd\MonthEndTest\Test_LookFor_XLR_Y.bat

