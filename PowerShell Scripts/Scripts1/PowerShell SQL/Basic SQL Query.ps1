clear
$SqlServer = "sqlproj"
$SqlCatalog = "NetBackup"
#$myuser = read-host "Enter Last Name to query for in Database: "
#*************** Query Below
#*******************************************************************************
# You can organize the querys any way you want. Any Valid Tsql
#statement should work... -Big Jelly. *
# $SqlQuery = "select name_agency, city, zip from T_Agency"
# $SqlQuery = "select * from T_USER"
$SqlQuery = "select policy from dbo.policy"
#where am_last_user = '$myuser' "
#*************** Query Above
#*******************************************************************************
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SqlServer; Database = $SqlCatalog; Integrated Security = false;Initial Catalog=netbackup; User iD=sa; Password=1scorpion;"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$SqlConnection.Close()
#Clear
$DataSet.Tables[0]
