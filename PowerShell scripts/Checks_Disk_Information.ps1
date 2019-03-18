#Captures disk information for all servers and puts it in a table.
# Wont work if UAC is enabled, or if the OS is on Windows 2003 or prior (PowerShell doesnt exist), or if you dont have admin access to the server.
# If the customer has windows 2003 servers, you need to check this manually for those servers.

Import-Module dbatools

$servers = Invoke-Sqlcmd -ServerInstance 'AUDCS01APP294W' -Database 'DBADmin' -Query "SELECT DISTINCT [MachineName] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [OSVersion] <> '5.2' AND [IsEnabled] = 1 AND [RDP_access] = 1 AND [UAC_enabled] = 0;"
$dateNow = Get-Date 

foreach ($server in $servers) 
{ 

    Get-DbaDiskSpace -ComputerName $server.Item("MachineName") | select ComputerName, Name, Label, Capacity, Free, PercentFree, BlockSize, IsSqlDisk, @{l="DateCaptured";e={$dateNow}} | Write-DbaDataTable -SqlInstance AUDCS01APP294W -Table DBADmin.dbo.Checks_ServerDiskInformation -AutoCreateTable

}