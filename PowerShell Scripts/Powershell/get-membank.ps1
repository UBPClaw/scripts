$strComputer = Read-Host "Enter Computer Name"
 $colSlots = Get-WmiObject -Class "win32_PhysicalMemoryArray" -namespace "root\CIMV2" `
 -computerName $strComputer
 $colRAM = Get-WmiObject -Class "win32_PhysicalMemory" -namespace "root\CIMV2" `
 -computerName $strComputer
 
#Foreach ($objSlot In $colSlots){
#     "Total Number of DIMM Slots: " + $objSlot.MemoryDevices
# }
# Foreach ($objRAM In $colRAM) {
#     "Memory Installed: " + $objRAM.DeviceLocator
#     "Memory Size: " + ($objRAM.Capacity / 1GB) + " GB"
# }

$colSlots | ForEach {“Total Number of DIMM Slots: ” + $_.MemoryDevices}
 
$colRAM | ForEach {
“Memory Installed: ” + $_.DeviceLocator
“Memory Size: ” + ($_.Capacity / 1GB) + ” GB”
}
