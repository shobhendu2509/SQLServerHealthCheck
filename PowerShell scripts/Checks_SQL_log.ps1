#Script to capture current inventory information in the environment.

Import-Module dbatools

$servers = Invoke-Sqlcmd -ServerInstance 'AUDCS01APP294W' -Database 'DBADmin' -Query "SELECT [SQL Instance Name] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [SQL_Access] = 1 AND [IsEnabled] = 1;"


foreach ($server in $servers) 
{ 

 Invoke-Sqlcmd -ServerInstance $server.Item("SQL Instance Name") -InputFile “C:\PebbleIT\Checks - weekly\PowerShell scripts\Supporting SQL Scripts\readerrorlog_INSERT_Checks_SQL_Log.sql” | Write-DbaDataTable -SqlInstance AUDCS01APP294W -Table DBADmin.dbo.Checks_SQL_Log -AutoCreateTable
 
}