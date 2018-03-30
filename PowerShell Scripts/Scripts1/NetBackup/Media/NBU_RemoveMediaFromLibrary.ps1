# ==================================================================================================================
# \\malibu\it\NTServers\Scripts\NetBackup\Media\NBU_RemoveMediaFromLibrary.ps1
# Date 11/09/2009
# Bryan K. DeBrun
# This script removes the media ID from the library.
# If media is returnned from off-site and we don't return the media to a slot in the libarary, the library will think
# it still needs to request the piece of media from off-site. Until the media is inserted back into the library, it has
# no idea that the media has been requested. The problem with this is we have only 300 available slots in the library and
# they are occupied most of the time.  
# The script below will loop through a text file containing media ids and if the media is not in a slot, the media will
# be removed from the library. We can then put the media on the shelf in the server room for future use.

# Execute this script from gremlin.
# ==================================================================================================================


#Remove-Item D:\BKD_LOGS\Media\ClearFromLib.txt

# Besure to change the path below if necessary.

$Gtapes = gc D:\BKD_LOGS\Media\ClearFromLib.txt

# So, for each tape listed to be requested for return and is not
# already occupying a slot in the library, remove from the library
# Until I get this completely automated, add the desired media to
# the file called ClearFromLib.txt

foreach ($tape in $Gtapes )

	{
	   $slot =  vmquery -m $tape |
			where-object {$_-match "robot slot:"}|
			ForEach-Object {$_-replace "robot ",""}|
			ForEach-Object {$_-replace "            ",""}|
			ForEach-Object {$_-replace "Slot:",""}
	
				if ($slot -eq $NUL)
	
				{
	 				vmdelete -m $tape 
	 
				}
	
	}