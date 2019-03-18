# Run this script to capture all the data you need for the weekly checks.
# Disregard any orange warnings for the Get-DbaLastGoodCheckDb (Database Integrity checks). It will skip the DR or AG replica databases that are not accessible.
# The script takes about 10 - 15 minutes to complete for UGL.

$startTime = Get-Date
Write-Host "The script was started " + $startTime.ToString("u") 

write-host "Truncating the temporary check tables ready for importing new data."
$ScriptToRun= $PSScriptRoot+"\TruncateCheckTables.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

# Introduce this once we have implemented the BaselineStatistics solution
#write-host "Reimporting the list of servers from the Master data source in BaselineStatistics"
#$ScriptToRun= $PSScriptRoot+"\ReimportServerList.ps1"
#Write-Host $ScriptToRun
#&$ScriptToRun

write-host "Getting Agent job data."
$ScriptToRun= $PSScriptRoot+"\Checks_AgentJobs_Inventory.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting Database inventory data."
$ScriptToRun= $PSScriptRoot+"\Checks_Database_Inventory.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting Database Integrity check data"
$ScriptToRun= $PSScriptRoot+"\Checks_DBCCLastGoodCheck.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting Data File data."
$ScriptToRun= $PSScriptRoot+"\Checks_DataFiles.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting disk information"
$ScriptToRun= $PSScriptRoot+"\Checks_Disk_Information.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting Instance information."
$ScriptToRun= $PSScriptRoot+"\Checks_InstanceInformation.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting members of Local Administrators group on each server."
$ScriptToRun= $PSScriptRoot+"\Checks_LocalAdministrators_group_members.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting SQL Server role memberships."
$ScriptToRun= $PSScriptRoot+"\Checks_ServerRole_membership.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting local server policy rights for SQL Server services."
$ScriptToRun= $PSScriptRoot+"\Checks_SQLServicesPolicyUserRights.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting Run status and which accounts are running all SQL Server services on all servers."
$ScriptToRun= $PSScriptRoot+"\Checks_ServicesWMI_method_AllServers.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

write-host "Getting SQL Server log data"
$ScriptToRun= $PSScriptRoot+"\Checks_SQL_log.ps1"
#Write-Host $ScriptToRun
&$ScriptToRun

$stopTime = Get-Date
Write-Host "The script was stopped " + $stopTime.ToString("u") 
