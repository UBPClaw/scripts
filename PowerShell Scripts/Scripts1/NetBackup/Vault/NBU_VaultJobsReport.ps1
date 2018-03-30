$GetVaultRept = Import-Csv  \\gremlin\d$\BKD_LOGS\Vault\Vault.csv |
	select -Unique Vault,Status,StartDate #| Format-Table -AutoSize
	$GetVaultRept