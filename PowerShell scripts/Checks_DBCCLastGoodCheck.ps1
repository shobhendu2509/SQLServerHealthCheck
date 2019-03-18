# DBCC Checks. Get date/time for last known good DBCC CHECKDB and writes to a table in your database. Excludes tempdb.
Import-Module dbatools

$servers = Invoke-Sqlcmd -ServerInstance 'AUDCS01APP294W' -Database 'DBAdmin' -Query "SELECT [SQL Instance Name] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [SQL_Access] = 1 AND [IsEnabled] = 1;"

foreach ($server in $servers) 
{ 
  Get-DbaLastGoodCheckDb -SqlInstance $server.Item("SQL Instance Name") -ExcludeDatabase tempdb | Write-DbaDataTable -SqlInstance AUDCS01APP294W -Table DBADmin.dbo.Checks_DBCCLastGoodCheck -AutoCreateTable
}