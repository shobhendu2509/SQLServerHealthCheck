#Script to capture current inventory information in the environment.

$servers = Invoke-Sqlcmd -ServerInstance 'PCBRVSQL01\SQL01' -Database 'DBADmin_PROD' -Query "SELECT [SQL Instance Name] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [Environment] IN ('STAGING', 'PROD') AND [SQLVersion] <> '2005' AND [SQL_Access] = 1 AND [IsEnabled] = 1;"


foreach ($server in $servers) 
{ 

 #write-host $server.Item("SQL Instance Name")
 Invoke-Sqlcmd -ServerInstance $server.Item("SQL Instance Name") -InputFile “C:\PebbleIT\Checks - weekly\PowerShell scripts\Supporting SQL Scripts\Checks Data File information.sql” | Write-DbaDataTable -SqlInstance PCBRVSEM01\SQL01 -Table DBADmin.dbo.Checks_DataFiles -AutoCreateTable

}