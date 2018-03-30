This script runs from PSQL04
It needs the windows version of htpasswd.exe. This version is part of the OS and located at c:\windows\system32
This script compares two lists of accounts; existing and new. It then creates the password file for DPR and adds
only the new accounts.  Eric Dilger provides us with the file of new accounts.

The script is located at \\malibu\it\ntservers\scripts\DPR