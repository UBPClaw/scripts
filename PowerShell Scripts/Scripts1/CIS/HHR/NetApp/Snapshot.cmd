rem ###################################################################
rem # Script for gv_test: After Snapshot Process
rem # Created: 090804
rem # Modified: 
rem # Version: 1.0
rem ###################################################################

rem ###################################################################
rem # Command set for removing Disk Group from VEA

rem <insert veritas commands here>
psexec \\gremlin vxdg -g CIS_After -f deport


rem ###################################################################
rem # Command set for offlining LUN's from AFTER host
rem 
rsh M45 lun offline /vol/gv_test_clone_after/lun0.lun

rem ###################################################################
rem # Command set for unmapping LUN's from AFTER host
rem rsh M45 lun unmap /vol/gv_test_clone_after/lun0.lun gv_test 0 ******Failed
rsh M45 lun unmap /vol/gv_test_clone_after/lun0.lun gremlin


rem ###################################################################
rem # Command set for removing FlexClone volume in preparation
rem # for AFTER snapshot process

rsh M45 vol offline gv_test_clone_after
rsh M45 vol destroy gv_test_clone_after -f


rem ###################################################################
rem # Command set for creating AFTER snapshots for gv_test on M45
rem # This will keep rolling snapshots for 7 days

rsh M45 snap delete gv_test gv_test_after.6
rsh M45 snap rename gv_test gv_test_after.5 gv_test_after.6
rsh M45 snap rename gv_test gv_test_after.4 gv_test_after.5
rsh M45 snap rename gv_test gv_test_after.3 gv_test_after.4
rsh M45 snap rename gv_test gv_test_after.2 gv_test_after.3
rsh M45 snap rename gv_test gv_test_after.1 gv_test_after.2
rsh M45 snap rename gv_test gv_test_after.0 gv_test_after.1
rsh M45 snap create gv_test gv_test_after.0

rem ###################################################################
rem # Command set for creating FlexClone volume

rsh M45 vol clone create gv_test_clone_after -b gv_test gv_test_after.0

rem ###################################################################
rem # Command set for mapping LUN's to AFTER host

rsh M45 lun map /vol/gv_test_clone_after/lun0.lun gremlin

rem ###################################################################
rem # Command set for onlining LUN's for AFTER host

rsh M45 lun online /vol/gv_test_clone_after/lun0.lun

rem ###################################################################
rem # Command set for rescanning disks in VEA, assigning drive letter


psexec \\gremlin vxassist rescan
psexec \\gremlin vxdg -g GV_NA_Test -n CIS_After -f -C import
psexec \\gremlin vxassist -f assign \Device\HarddiskDmVolumes\CIS_After\Volume1 DriveLetter=R:
pause
