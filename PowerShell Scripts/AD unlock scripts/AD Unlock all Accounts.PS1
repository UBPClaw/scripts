#unlock all locked accounts
Search-ADAccount -LockedOut | Unlock-ADAccount
Read-Host -Prompt "Press Enter to exit"
