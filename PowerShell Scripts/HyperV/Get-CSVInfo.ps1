Import-Module FailoverClusters


#*************************
#* Retrieve Cluster Name *
#*************************
([string]$ClusterName = $(read-host "Enter Cluster Name"))

$objs = @()

$csvs = Get-ClusterSharedVolume -Cluster $ClusterName
foreach ( $csv in $csvs )
{
   $csvinfos = $csv | select -Property Name -ExpandProperty SharedVolumeInfo
   foreach ( $csvinfo in $csvinfos )
   {
      $obj = New-Object PSObject -Property @{
         Name        = $csv.Name
         Path        = $csvinfo.FriendlyVolumeName
         Size        = $csvinfo.Partition.Size
         FreeSpace   = $csvinfo.Partition.FreeSpace
         UsedSpace   = $csvinfo.Partition.UsedSpace
         PercentFree = $csvinfo.Partition.PercentFree
      }
      $objs += $obj
   }
}

$objs | sort Freespace -descending | ft -auto Name,Path,@{ Label = "Size(GB)" ; Expression = { "{0:N2}" -f ($_.Size/1024/1024/1024) } },@{ Label = "FreeSpace(GB)" ; Expression = { "{0:N2}" -f ($_.FreeSpace/1024/1024/1024) } },@{ Label = "UsedSpace(GB)" ; Expression = { "{0:N2}" -f ($_.UsedSpace/1024/1024/1024) } },@{ Label = "PercentFree" ; Expression = { "{0:N2}" -f ($_.PercentFree) } }