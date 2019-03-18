#Script to capture current inventory information in the environment.
# DOES NOT SUPPORT SQL SERVER 2005 or below. If you need this, you may have to check the backup information manually for those instances as part of your checks.

Import-Module dbatools

$servers = Invoke-Sqlcmd -ServerInstance 'AUDCS01APP294W' -Database 'DBADmin' -Query "SELECT [SQL Instance Name] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [SQLVersion] <> '2005' AND [SQL_Access] = 1 AND [IsEnabled] = 1;"


foreach ($server in $servers) 
{ 
  Invoke-Sqlcmd -ServerInstance $server.Item("SQL Instance Name") -InputFile “C:\PebbleIT\Checks - weekly\PowerShell scripts\Supporting SQL Scripts\Checks Database Inventory.sql” | Write-DbaDataTable -SqlInstance AUDCS01APP294W -Table DBADmin.dbo.Checks_Database_Information -AutoCreateTable
}