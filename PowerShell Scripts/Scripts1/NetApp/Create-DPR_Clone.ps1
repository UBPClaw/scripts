##################################################################
# 
#  Copy Monthly Data from the DPR share at vfs02\dpr
#  The vfs02_dpr_fc volume is located in the m1hosting domain
#  We need a way to copy the data to the QAPCE server on the
#  Repair Domain. We will create a clone of the vfs02_dpr_fc
#  volume and mount it on the vfiler malibu
#
##################################################################


###################################################################
# 
# Make a connection to the controller m45 and ranger
#
###################################################################

#$m35 = connect-nacontroller -name m35

$m45 = connect-nacontroller -name m45
$ranger = connect-nacontroller -name m45 -Vfiler ranger

###################################################################
# 
# Create the point in time snap shot vfs03_dpr_fc 
#
###################################################################


#New-NaVolClone malibu_dpr_clone vfs02_dpr_fc -SpaceReserve none -Controller $m35
New-NaVolClone ranger_dpr_clone vfs03_dpr_fc -SpaceReserve none -Controller $m45

###################################################################
# 
# Mount volume on vfiler Malibu
#
###################################################################
#Set-NaVfilerStorage malibu -AddStorage ranger_dpr_clone -Controller $m45

Set-NaVfilerStorage ranger -AddStorage ranger_dpr_clone -Controller $m45



 # Now you need to set up a share on malibu. Connect to malibu through computer managment to create share.
 # c:\vol\ranger_dpr_clone\share\DPR\Uploads   Share name DPRUploads
 # Give the share permissions Administrator Full, G_Data_Dev full
 add-NaCifsShare DPRUploads /vol/ranger_dpr_clone/share/DPR/Uploads -controller $ranger
 
 
 # Assign permissions to the file structure Uploads. This will take a while use CACLS
 # Assigg AuthUsers read
 # Toan can now access the file share from anywhere on the repair domain.
 
 # Map a drive to \\ranger\dpruploads and Run the following cacls command to set the permissions for data dev (I run from the server canyon)
 # cacls Z: /T /E /G "repair\G_Data_Dev":c
 # cacls Z: /T /E /G "repair\G_Field Technicians":F
 
 # The xcacls command will allow you to modify permissions remotely.
 # However, when running this for DPRuplods, it would get to an empty folder and then die.
  # xcacls \\ranger\DPRUploads\*.* /T /E /G "repair\G_Field Technicians":F
 # xcacls \\ranger\DPRUploads\*.* /T /E /G "repair\G_Data_Dev":rw
 
 
 