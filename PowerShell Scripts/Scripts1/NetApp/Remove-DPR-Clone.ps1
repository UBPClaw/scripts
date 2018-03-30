 ##################################################################
 # 
 #  This script removes the clone after the copy is complete.
 #
 ##################################################################



##################################################################
# 
#                Connect to NetApp Controller M35
#
##################################################################


#$m35 = connect-nacontroller -name m35
$m45 = connect-nacontroller -name m45



###################################################################
# 
# remove, offline, and destroy the snapshot volume from dakota 
#
####################################################################

#set-navol malibu_dpr_clone -Offline -controller $m35
#remove-navol malibu_dpr_clone -controller $m35 -Confirm:$false 
#remove-NaSnapshot vfs02_dpr_fc clone_malibu_dpr_clone.1 -controller $m35 -Confirm:$false

set-navol ranger_dpr_clone -Offline -controller $m45
remove-navol ranger_dpr_clone -controller $m35 -Confirm:$false 
remove-NaSnapshot vfs03_dpr_fc clone_ranger_dpr_clone.1 -controller $m45 -Confirm:$false