@echo off
cls
rem ************************
rem * Check for CIS Volume *
rem ************************
psexec \\eagle vxvol volinfo w:>C:\CIS_Volume_Info.log
if errorlevel=1 echo CIS volume is missing>C:\CIS_Volume_Info.log


rem *****************************************************
rem * Check for SnapShot Before Volume on Remote System *
rem *****************************************************
psexec \\xlr vxvol volinfo x:>C:\CIS_Before_Volume_Info.log
if errorlevel=1 echo SnapShot is still mirrored>C:\CIS_Before_Volume_Info.log


rem ****************************************************
rem * Check for SnapShot After Volume on Remote System *
rem ****************************************************
psexec \\xlr vxvol volinfo y:>C:\CIS_After_Volume_Info.log
if errorlevel=1 echo SnapShot is still mirrored>C:\CIS_After_Volume_Info.log
