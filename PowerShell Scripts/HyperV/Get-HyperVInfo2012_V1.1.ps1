if ( (Get-Module -Name virtualmachinemanager -ErrorAction SilentlyContinue) -eq $null ) 
{ 
    import-module virtualmachinemanager
} 


Function Time-Stamp {
 (get-date).toString('yyyyMMddhhmmss')
}

$log = "\\malibu\it\VirtualEnvironments\HyperV\VMs2012_"+(Time-Stamp)+".csv"
$log2 = "\\malibu\it\VirtualEnvironments\HyperV\Hosts2012_"+(Time-Stamp)+".csv"
$html = "\\malibu\it\VirtualEnvironments\HyperV\VMs2012_"+(Time-Stamp)+".html"

function Get-VMdata{
<#
.SYNOPSIS
Get the configuration data of the VMs in Hyper-V via SCVMM 2012
 
.DESCRIPTION
Use this function to get all VMs configuration in case of disaster or just statistics
 
.PARAMETER  xyz 
 
.NOTES
Author: Niklas Akerlund / RTS
Date: 2012-02-13
#>
param (
	$VMHostGroup = "All Hosts",
	[Parameter(ValueFromPipeline=$True)][Alias('ClusterName')]
	$VMHostCluster = $null,
	$VMHost = $null,
	[string]$CSVFile = "VMdata.csv",
    [string]$HTMLReport = "VMdata.html"
    )
	
	$report = @()
	if ($VMHostCluster -eq $null){
		$VMHosts = (Get-SCVMHostGroup -Name $VMhostGroup).AllChildHosts
	}else{
			$VMHosts = (Get-SCVMHostCluster -Name $VMHostCluster).Nodes
	}
#adding sort
	$VMs = $VMHosts | Get-SCVirtualMachine | sort HostName
	
	foreach ($VM in $VMs) {
		$CustomGroup = Get-SCCustomProperty -Name "Group"
		$Group = Get-SCCustomPropertyValue -InputObject $VM -CustomProperty $CustomGroup
		$VHDs = $VM | Get-SCVirtualDiskDrive
		$VHDsMaxSize = $VM.VirtualHarddisks | select MaximumSize
		$sum = $VHDsMaxSize.maximumsize -join '+'
		$TotalSize = Invoke-Expression $sum
		$i = "1"
		foreach ($VHDconf in $VHDs){ 
			if($i -eq "1"){
				$data = New-Object PSObject -property @{
					Group=$Group.Value
					VMName=$VM.Name
					VMDescription=$VM.Description
					VMStatus=$VM.Status
					VMOperatingSystem=$VM.OperatingSystem
					vCPUs=$VM.CPUCount
			    MemoryGB= $VM.Memory/1024
					VHDName = $VHDconf.VirtualHardDisk.Name
					VHDSize = [Math]::Round($VHDconf.VirtualHardDisk.MaximumSize/1GB)
					VHDCurrentSize = [Math]::Round($VHDconf.VirtualHardDisk.Size/1GB)
					VHDTotalSize = [Math]::Round($TotalSize/1GB)
					VHDType = $VHDconf.VirtualHardDisk.VHDType
					VHDBusType = $VHDconf.BusType
					VHDBus = $VHDconf.Bus
					VHDLUN = $VHDconf.Lun
					VHDDatastore = $VHDconf.VirtualHardDisk.HostVolume
					HostName = $VM.HostName
				}
				$i= "2"
			}else{
				$data = New-Object PSObject -property @{
					VMName=""
			        vCPUs=""
			        MemoryGB= ""
					VHDName = $VHDconf.VirtualHardDisk.Name
					VHDSize = [Math]::Round($VHDconf.VirtualHardDisk.MaximumSize/1GB)
					VHDCurrentSize = [Math]::Round($VHDconf.VirtualHardDisk.Size/1GB)
					VHDType = $VHDconf.VirtualHardDisk.VHDType
					VHDBusType = $VHDconf.BusType
					VHDBus = $VHDconf.Bus
					VHDLUN = $VHDconf.Lun
					VHDDatastore = $VHDconf.VirtualHardDisk.HostVolume
				}
			}
			$report +=$data	
		}
	}
	$report | Select-Object Group,VMName,VMDescription,VMStatus,VMOperatingSystem,vCPUs,MemoryGB,VHDName,VHDSize,VHDCurrentSize,VHDTotalSize,VHDType,VHDBusType,VHDBus,VHDLUN,VHDDatastore,HostName | Export-Csv -Path $log -NoTypeInformation -UseCulture
}

Get-VMdata
Get-VMHost -vmmserver powc-scvm-02-pv | sort-object Computername | select Computername, VMHostGroup, OperatingSystem, @{n='TotalMemory (GB)';e={($_.TotalMemory / 1gb).tostring("F02")}}, @{n='AvailableMemory (GB)';e={($_.AvailableMemory / 1kb).tostring("F02")}}, PhysicalCPUCount, CoresPerCPU, LogicalCPUCount |  export-csv $log2 -notype