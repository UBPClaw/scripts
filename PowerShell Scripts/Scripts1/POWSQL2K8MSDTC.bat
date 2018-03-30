REM *****************************************************************************
REM Create the SQL2K8 MS DTC cluster Group
REM *****************************************************************************
cluster POWSQL2K8CLUS group "SQL2K8 MS DTC" /create
cluster POWSQL2K8CLUS group "SQL2K8 MS DTC" /prop Description="MSDTC For SQL Instances"
REM *****************************************************************************

REM *****************************************************************************
REM Create the Physical Disk resource.
REM *****************************************************************************
cluster res "Disk N:" /create /Group:"SQL2K8 MS DTC" /TYPE:"Physical Disk"
cluster res "Disk N:" /priv Drive="N:"
cluster res "Disk N:" /prop Description="Physical Disk for MSDTC resource"
cluster res "Disk N:" /ADDOWNER:PSQL04
cluster res "Disk N:" /ADDOWNER:PSQL05
cluster res "Disk N:" /On
REM ******************************************************************************

REM *****************************************************************************
REM Create the Cluster Resouce M1 Cluster MSDTC IP for the SQL2K8 MS DTC Cluster Group
REM *****************************************************************************
cluster res "M1 Cluster MSDTC IP" /create /Group:"SQL2K8 MS DTC" /TYPE:"IP Address"
cluster res "M1 Cluster MSDTC IP" /priv Address="192.168.204.163"
cluster res "M1 Cluster MSDTC IP" /priv SubnetMask="255.255.255.0"
cluster res "M1 Cluster MSDTC IP" /priv Network="Public"
cluster res "M1 Cluster MSDTC IP" /priv EnableNetBIOS="1"
cluster res "M1 Cluster MSDTC IP" /prop Description="IP for MSDTC resource"
Cluster res "M1 Cluster MSDTC IP" /ADDOWNER:PSQL04
Cluster res "M1 Cluster MSDTC IP" /ADDOWNER:PSQL05
cluster res "M1 Cluster MSDTC IP" /ADDDEP:"DISK N:"
Cluster res "M1 Cluster MSDTC IP" /On
REM ******************************************************************************


REM *****************************************************************************
REM Create the Network Name resource for the SQL2K8 MS DTC Cluster Group
REM *****************************************************************************
cluster res "MSDTC Network Name" /CREATE /GROUP:"SQL2K8 MS DTC" /TYPE:"Network Name"
cluster res "MSDTC Network Name" /priv Name="POWSQL2K8MSDTC"
cluster res "MSDTC Network Name" /priv RequireDNS="1"
cluster res "MSDTC Network Name" /prop Description="Network Name for MSDTC resource"
cluster res "MSDTC Network Name" /ADDDEP:"M1 Cluster MSDTC IP"
Cluster res "MSDTC Network Name" /ADDOWNER:PSQL04
Cluster res "MSDTC Network Name" /ADDOWNER:PSQL05
Cluster res "MSDTC Network Name" /On
REM *****************************************************************************

REM *****************************************************************************
REM Create the Microsoft Distributed Transaction Coordinator resource. 
REM This is needed for SQL.
REM *****************************************************************************
cluster POWSQL2K8CLUS res "POWSQL2K8CLUS MSDTC" /CREATE /GROUP:"SQL2K8 MS DTC" /TYPE:"Distributed Transaction Coordinator"
cluster POWSQL2K8CLUS res "POWSQL2K8CLUS MSDTC" /ADDDEP:"M1 Cluster MSDTC IP"
cluster POWSQL2K8CLUS res "POWSQL2K8CLUS MSDTC" /ADDDEP:"Disk N:" 
cluster POWSQL2K8CLUS res "POWSQL2K8CLUS MSDTC" /ADDDEP:"MSDTC Network Name"
cluster res "POWSQL2K8CLUS MSDTC" /prop Description="Microsoft Distributed Transaction Coordinator resource"
Cluster res "POWSQL2K8CLUS MSDTC" /ADDOWNER:PSQL04
Cluster res "POWSQL2K8CLUS MSDTC" /ADDOWNER:PSQL05
Cluster res "POWSQL2K8CLUS MSDTC" /On
REM *****************************************************************************