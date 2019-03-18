USE [DBAdmin]
GO

--Checks if it already exists, if not it creates the procedure, if so it just alters it.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_update_server_list]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_update_server_list] AS'
END
GO
ALTER PROCEDURE [dbo].[sp_update_server_list]

AS 


/****** 
Name:			 Update server list from BaselineStatistics DBServers Table  

Author:			Tim Roberts 
Creation Date:	10th Jan 2019
Version:		1.0

Summary:	As UGL already have a better reporting tool, we get the Source Server list from an already established table on the server.
			This means we can run this check process in addition / for testing. But still use the master server list. 

Modification History:
-------------------------------------------------------------------------------
Version Date		Name			Modification
-------------------------------------------------------------------------------
1.0 	10th Jan 2019	Tim Roberts		Initial release


******/

--Deletes everything in the target table, ready for a new refresh.
TRUNCATE TABLE [DBAdmin].[dbo].[SourceServerList]


/****** Update server list from BaselineStatistics DBServers Table ******/
INSERT INTO [DBAdmin].[dbo].[SourceServerList]
([SQL Instance Name]
      ,[MachineName]
      ,[Environment]
      ,[RDP_Access]
      ,[SQL_Access]
      ,[ServerDescr]
      ,[OSType]
      ,[OSVersion]
      ,[SQLVersion]
      ,[IsFCI_clustered]
      ,[ActiveStatus]
      ,[IsEnabled]
      ,[UAC_enabled]
      ,[BackupLocation]
      ,[BackupMethod]
)

SELECT 

	[ServerName],
	[ServerName] as 'MachineName',
	[Category],
	1,
	1,
	[ServerDescr],
	[OSType],
	[OSVersion],
	[DBVersion],
	[IsClustered],
	[ActiveStatus],
	[IsEnabled],
	0,
	[BackupLocation],
	[BackupMethod]

FROM [BaselineStatistics].[dbo].[DBServers]