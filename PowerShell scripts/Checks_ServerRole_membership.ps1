#Script to capture any login that is a member of a server fixed role. 

$servers = Invoke-Sqlcmd -ServerInstance 'PCBRVSEM01\SQL01' -Database 'DBAdmin' -Query "SELECT [SQL Instance Name] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [Environment] IN ('STAGING', 'PROD') AND [SQLVersion] <> '2005' AND [SQL_Access] = 1 AND [IsEnabled] = 1;"
$dateNow = Get-Date 

foreach ($server in $servers) 
{ 

 Invoke-Sqlcmd -ServerInstance $server.Item("SQL Instance Name") -InputFile “C:\PebbleIT\Checks - weekly\PowerShell scripts\Supporting SQL Scripts\Checks Server Role Membership.sql” | select @{l="SQL Instance Name";e={$server.Item("SQL Instance Name")}}, @{l="DateCaptured";e={$dateNow}}, loginname, type, type_desc, is_disabled, sysadmin, securityadmin, serveradmin, setupadmin, processadmin, diskadmin, dbcreator, bulkadmin, create_date, modify_date | Write-DbaDataTable -SqlInstance PCBRVSEM01\SQL01 -Table DBADmin.dbo.Checks_ServerRoleMembers -AutoCreateTable

}