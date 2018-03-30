$dadate = get-date -f M-d-yyyy
ren \\gremlin\d$\BKD_LOGS\Policies\Policies_latest.txt Policies_$dadate.txt
# psexec \\gremlin "D:\program files\veritas\netbackup\bin\admincmd\bppllist" | Out-File \\gremlin\d$\BKD_LOGS\Policies\Policies_latest.txt
cd "D:\program files\veritas\netbackup\bin\admincmd" 
bppllist | Out-File d:\BKD_LOGS\Policies\Policies_latest.txt