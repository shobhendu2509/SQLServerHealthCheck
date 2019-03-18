# Prepares the tables.
# Truncates the temporary check tables by running the stored procedure
Import-Module dbatools

Invoke-Sqlcmd -ServerInstance 'AUDCS01APP294W' -Database 'DBADmin' -Query "exec sp_truncate_check_tables;"

