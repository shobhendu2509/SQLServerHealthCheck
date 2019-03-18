# Reimports the list of servers, this is because this customer has a master list in the BaselineStatistics database.
Import-Module dbatools

Invoke-Sqlcmd -ServerInstance 'AUDCS01APP294W' -Database 'DBADmin' -Query "exec sp_update_server_list;"