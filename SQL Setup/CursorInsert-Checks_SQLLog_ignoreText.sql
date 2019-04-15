/****** 
Name:			Cursor populate SQL Log text to ignore. 

Author:			Tim Roberts 
Creation Date:	4th Feb 2019
Version:		1.1

Summary:	Cursor to populate the table Checks_SQLLog_ignoreText with standard messages to ignore in the SQL log.


Modification History:
-------------------------------------------------------------------------------
Version Date		Name			Modification
-------------------------------------------------------------------------------
1.0 	02/01/2019	Tim Roberts		Initial release
1.1		04/02/2019	Tim Roberts		Updated to use the SQL Instance name as opposed the machine name. Otherwise the results wont join properly in the query. 
									Some customers have their default instance named.
									Also added extra lines for SQL 2005 servers.
1.2		11/04/2019	Tim Roberts		Updated the 'Log was backed up' exclusion to include SQL 2017 instances.

Look for
==========
Nothing at this time.

******/


USE DBAdmin

DECLARE @ServerName as nvarchar(255) -- pick a suitable data type for your needs.

DECLARE ServerNameCursor CURSOR FOR 
	--PUT YOUR SELET STATEMENT HERE. 
	SELECT [SQL Instance Name]
	FROM [DBAdmin].[dbo].[SourceServerList] 
	WHERE [ActiveStatus] = 1 AND [IsEnabled] = 1 AND [SQL_Access] = 1
	ORDER BY [MachineName]

OPEN ServerNameCursor 
FETCH NEXT FROM ServerNameCursor INTO @ServerName

WHILE @@FETCH_STATUS = 0   
BEGIN 

 -- Do what ever shit you need to do on this row. 

 PRINT @ServerName

 INSERT INTO [DBAdmin].[dbo].[Checks_SQLLog_ignoreText] ([InstanceName], [TextStatus], [Text]) VALUES
 
(@ServerName, 1, 'CHECKDB for database%finished without errors on%'),
(@ServerName, 1, 'DBCC CHECKDB%found 0 errors and repaired 0 errors%'),
(@ServerName, 1, 'BACKUP DATABASE WITH DIFFERENTIAL successfully%'),
(@ServerName, 1, 'Log was backed up%'),
(@ServerName, 1, 'Database backed up%This is an informational message only. No user action is required%'),
(@ServerName, 1, 'DBCC CHECKTABLE%found 0 errors and repaired 0 errors%'),
(@ServerName, 1, '%transactions rolled forward in database%This is an informational message only. No user action is required%'),
(@ServerName, 1, '%transactions rolled back in database%This is an informational message only. No user action is required%'),
(@ServerName, 1, '(c) Microsoft Corporation.'),
(@ServerName, 1, 'Authentication mode is MIXED'),
(@ServerName, 1, 'All rights reserved.'),
(@ServerName, 1, 'Microsoft SQL Server 20%'),
(@ServerName, 1, 'UTC adjustment%'),
(@ServerName, 1, 'The service account%'),
(@ServerName, 1, 'Server process ID is%'),
(@ServerName, 1, 'Command Line Startup Parameters:'),
(@ServerName, 1, 'Logging SQL Server messages in file%'),
(@ServerName, 1, 'This instance of SQL Server last reported using a process ID of %'),
(@ServerName, 1, 'BACKUP DATABASE successfully processed%'),
(@ServerName, 1, 'Database differential changes were backed up%'),
(@ServerName, 1, 'Server local connection provider is ready%'),
(@ServerName, 1, 'I/O was resumed on database%'),
(@ServerName, 1, 'I/O is frozen on database%'),
(@ServerName, 1, 'System Manufacturer%'),
(@ServerName, 1, 'Authentication mode is%'),
(@ServerName, 1, 'Default collation%'),
(@ServerName, 1, 'Log was restored%'),
(@ServerName, 1, 'This instance of SQL Server has been using a process ID of%'),
(@ServerName, 1, 'The error log has been reinitialized%'),
(@ServerName, 1, '(c) 2005 Microsoft Corporation.%'),
(@ServerName, 1, 'Registry startup parameters%'),

(@ServerName, 1, 'Starting up database%'),
(@ServerName, 1, 'SQL Server is now ready for client connections. This is an informational message; no user action is required.'),
(@ServerName, 1, 'The SQL Server Network Interface library successfully registered the Service Principal Name%'),
(@ServerName, 1, 'Server named pipe provider is ready to accept connection%'),
(@ServerName, 1, 'Server is listening on%'),
(@ServerName, 1, 'Server name is%'),
(@ServerName, 1, 'A self-generated certificate was successfully loaded for encryption%'),
(@ServerName, 1, 'SQL Server is starting at normal priority base%This is an informational message only. No user action is required%')

;


FETCH NEXT FROM ServerNameCursor INTO @ServerName
END

CLOSE ServerNameCursor;
DEALLOCATE ServerNameCursor