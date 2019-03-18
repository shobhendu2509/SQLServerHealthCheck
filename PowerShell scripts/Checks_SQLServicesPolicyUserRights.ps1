#Make sure the powershell module is located in the location details below, so it can be imported.
Import-Module "C:\PebbleIT\Checks - weekly\PowerShell scripts\Supporting PS modules\UserRights.ps1"

$servers = Invoke-Sqlcmd -ServerInstance 'PCBRVSEM01\SQL01' -Database 'DBAdmin' -Query "SELECT DISTINCT [MachineName] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [Environment] IN ('STAGING', 'PROD') AND [OSVersion] <> '5.2' AND [IsEnabled] = 1 AND [RDP_access] = 1 AND [UAC_enabled] = 0;"
$dateNow = Get-Date 

foreach ($server in $servers) 
{ 
   # write-host $server.Item("MachineName")

    Get-AccountsWithUserRight -Computer $server.Item("MachineName") -Right SeServiceLogonRight, SeBatchLogonRight, SeLockMemoryPrivilege , SeManageVolumePrivilege | 
    select @{Name='account';Expression={[string]::join(“;”, ($_.account))}}, right, @{l="server";e={$server.Item("MachineName")}}, @{l="DateCaptured";e={$dateNow}} | ConvertTo-DbaDataTable | Write-DbaDataTable -SqlInstance PCBRVSEM01\SQL01 -Table DBADmin.dbo.Checks_SQLServicesPolicyUserRights -AutoCreateTable

  
}