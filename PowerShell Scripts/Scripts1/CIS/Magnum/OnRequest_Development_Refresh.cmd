@echo off
rem ****************************
rem * Setup Paths and Log-File *
rem ****************************
set source1=W:\UV\Accounts\Mitchell1\CISPUB83
set source2=W:\UV\Accounts\Mitchell1\CISPRG8
set destination1=F:\UV\Accounts\Mitchell1\CISPUB83.DVLP
set destination2=F:\UV\accounts\Mitchell1\CISPRG8.DVLP
set logfile=OnRequestTestEnv_Refresh



rem ******************
rem * Start Robocopy *
rem ******************
robocopy %source1% %destination1% /MIR /COPY:DAT /R:2 /W:5 /NP /XF SELOG SEWK SECURITY SEAUDIT RPTDEFS.USER RPTHDRS.USER /LOG:C:\Scripts\%logfile%.log /TEE
robocopy %source2% %destination2% /MIR /COPY:DAT /R:2 /W:5 /NP /XF SELOG SEWK SECURITY SEAUDIT RPTDEFS.USER RPTHDRS.USER  /LOG:C:\Scripts\%logfile%.log /TEE



