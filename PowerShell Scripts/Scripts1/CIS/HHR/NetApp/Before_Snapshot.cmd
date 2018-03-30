rem ###################################################################
rem # Script for gv_test: After Snapshot Process
rem # Created: 090804
rem # Modified: 
rem # Version: 1.0
rem ###################################################################

rem ###################################################################
rem # Command set for removing Disk Group from VEA

rem <insert veritas commands here>
psexec \\nova vxdg -g CIS_before -f deport


rem ###################################################################
rem # Command set for offlining LUN's from BEFORE host
rem 
rsh M45 lun offline /vol/gv_test_clone_before/lun0.lun

rem ###################################################################
rem # Command set for unmapping LUN's from BEFORE host
rem rsh M45 lun unmap /vol/gv_test_clone_before/lun0.lun gv_test 0 ******Failed
rsh M45 lun unmap /vol/gv_test_clone_before/lun0.lun nova


rem ###################################################################
rem # Command set for removing FlexClone volume in preparation
rem # for before snapshot process

rsh M45 vol offline gv_test_clone_before
rsh M45 vol destroy gv_test_clone_before -f


rem ###################################################################
rem # Command set for creating before snapshots for gv_test on M45
rem # This will keep rolling snapshots for 7 days

rsh M45 snap delete gv_test gv_test_before.6
rsh M45 snap rename gv_test gv_test_before.5 gv_test_before.6
rsh M45 snap rename gv_test gv_test_before.4 gv_test_before.5
rsh M45 snap rename gv_test gv_test_before.3 gv_test_before.4
rsh M45 snap rename gv_test gv_test_before.2 gv_test_before.3
rsh M45 snap rename gv_test gv_test_before.1 gv_test_before.2
rsh M45 snap rename gv_test gv_test_before.0 gv_test_before.1
rsh M45 snap create gv_test gv_test_before.0

rem ###################################################################
rem # Command set for creating FlexClone volume

rsh M45 vol clone create gv_test_clone_before -b gv_test gv_test_before.0

rem ###################################################################
rem # Command set for mapping LUN's to before host

rsh M45 lun map /vol/gv_test_clone_before/lun0.lun nova

rem ###################################################################
rem # Command set for onlining LUN's for before host

rsh M45 lun online /vol/gv_test_clone_before/lun0.lun

rem ###################################################################
rem # Command set for rescanning disks in VEA, assigning drive letter


psexec \\nova vxassist rescan
psexec \\nova vxdg -g GV_NA_Test -n CIS_before -f -C import
psexec \\nova vxassist -f assign \Device\HarddiskDmVolumes\CIS_before\Volume1 DriveLetter=R:
pause
