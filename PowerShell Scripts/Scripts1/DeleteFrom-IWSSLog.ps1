# ==========================================================================================================
# 
# Microsoft PowerShell File 
# 
# NAME: DeleteFrom-IWSSLog.ps1
# 
# DATE: 04-07-08
# 
# COMMENT: The script connects to the iwss database on Savana, deletes from the tb_url_usage table any row
# older than 25 days
# ==========================================================================================================

$cn = new-object System.Data.SqlClient.SqlConnection("Data Source=Savana;Integrated Security=SSPI;Initial Catalog=iwss");
$cn.Open()
$sql = "DELETE FROM tb_url_usage WHERE date_field < GETDATE()- 15"
$cmd = new-object "System.Data.SqlClient.SqlCommand" ($sql, $cn)
$cmd.CommandTimeout = 0
$dr = $cmd.ExecuteReader()
$dr.Close()
$cn.Close()