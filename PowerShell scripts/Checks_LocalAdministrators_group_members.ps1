#Make sure the powershell module is located in the location details below, so it can be imported.
Import-Module "C:\PebbleIT\Checks - weekly\PowerShell scripts\Supporting PS modules\Get-GroupMember.ps1"

$servers = Invoke-Sqlcmd -ServerInstance 'PCBRVSEM01\SQL01' -Database 'DBAdmin' -Query "SELECT DISTINCT [MachineName] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [Environment] IN ('STAGING', 'PROD') AND [RDP_Access] = 1 AND [IsEnabled] = 1;"
$dateNow = Get-Date 


foreach ($server in $servers) 
{ 
 #This bit gets the name of the server so it can be used in the output
 $machinename =  $server.Item("MachineName")

   Get-GroupMember Administrators -ComputerName $server.Item("MachineName") | select Member, ComputerName, LocalGroup, @{l="DateCaptured";e={$dateNow}} | Write-DbaDataTable -SqlInstance PCBRVSEM01\SQL01 -Table DBAdmin.dbo.Checks_LocalAdministrators_members -AutoCreateTable

}
