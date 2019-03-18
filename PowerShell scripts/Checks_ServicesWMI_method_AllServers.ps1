#Script to get service status for all SQL related services in all environments.
# This is a great article that helped me figure this out: https://blogs.technet.microsoft.com/heyscriptingguy/2012/02/15/the-scripting-wife-uses-powershell-to-find-service-accounts/

# Exclusions: RDP access (admin access to server), UAC must be disabled. However, this can run on Windows 2003 if necessary. Not all servers may allow WMI connections, in which case try the powershell function instead (Get-Service). 
# At the time of writing this script the following servers are excluded because UAC is enabled: RSDBS, VMBIAS	
# At the time of writing this script the following servers are excluded because we dont have remote access: SIL-SCCM01

#Import-Module "C:\Program Files\WindowsPowerShell\Modules\dbatools\dbatools.psd1"
#$servers = Invoke-Sqlcmd -ServerInstance 'PCBRVSQL01\SQL01' -Database 'DBADmin' -Query "SELECT [MachineName] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [RDP_access] = 1 AND [UAC_enabled] = 0;"

$servers = Invoke-Sqlcmd -ServerInstance 'PCBRVSEM01\SQL01' -Database 'DBAdmin' -Query "SELECT DISTINCT [MachineName] FROM [dbo].[SourceServerList] WHERE [ActiveStatus] >= 1 AND [Environment] IN ('STAGING', 'PROD')  AND [OSVersion] <> '5.2' AND [IsEnabled] = 1 AND [RDP_access] = 1 AND [UAC_enabled] = 0;"

$dateNow = Get-Date 


foreach ($server in $servers) 
{ 
 #This bit gets the name of the server so it can be used in the output
 $machinename =  $server.Item("MachineName")

   #write-host $server.Item("MachineName")
   Get-WmiObject win32_service -ComputerName $server.Item("MachineName") | where {$_.DisplayName -like "*SQL*"} | select @{l="MachineName";e={$machinename}}, name, DisplayName, state, startmode, startname, PathName, Description, @{l="DateCaptured";e={$dateNow}} | ConvertTo-DbaDataTable | Write-DbaDataTable -SqlInstance PCBRVSEM01\SQL01 -Table DBADmin.dbo.Checks_SQLServicesStatusWMI -AutoCreateTable

}