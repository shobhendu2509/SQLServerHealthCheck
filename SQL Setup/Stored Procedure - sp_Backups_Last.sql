USE [DBAdmin]
GO

--Checks if it already exists, if not it creates the procedure, if so it just alters it.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Backups_Last]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_Backups_Last] AS'
END
GO
ALTER PROCEDURE [dbo].[sp_Backups_Last]

AS 


/****** 
Name:			Last Backups - Report details  

Author:			Tim Roberts 
Creation Date:	4th Mar 2019
Version:		1.2

Summary:	Shows when each database was last backed up.
			SECONDARY AG replicas and any the database is not 'RESTORING' (ie: not the DR part of a log shipping)

Modification History:
-------------------------------------------------------------------------------
Version Date		Name			Modification
-------------------------------------------------------------------------------
1.0 	02/01/2019	Tim Roberts		Initial release
1.1		04/02/2019	Tim Roberts		Added columns to show days since the last backup for that type.
1.2		04/03/2019	Tim Roberts		Change the join on the [SourceServerList] from [MachineName] to [SQL Instance Name] as most servers capture the Instance Name as Server name + instance name.

Look for
==========

	1.  Any database with no FULL backup within 4 days and no differential backup within 24 hours. 
		If the database hasnt been backed up within 7 days, check to see if its part of an AG. 
			If so, check the other syncronous replicas. They may have run the backup, by default we configure the PRIMARY to run backups as SECONDARY's can technical auto switch to ASYNC. 
			It might also be the DB was recently failed over to the current replica and the backup ran on another server that was the primary. 

	2.	Any database in FULL recovery mode that hasnt got a transaction log backup within 1 hour of when the master script was run (6am).
		All transaction log backups should be within 1 hour of 5am or thereabouts for databases in full recovery model.


******/


SELECT 
	   SS.Environment
	  ,[ServerName]
      ,[InstanceName]
      ,[DatabaseName]
	  ,[recovery_model_desc]
	  ,[Last FULL Backup Date]
	  ,DATEDIFF(DAY, [Last FULL Backup Date], [InventoryDate]) AS 'Days since last FULL'
      ,[Last Differential Backup Date]
	  ,DATEDIFF(DAY, [Last Differential Backup Date], [InventoryDate]) AS 'Days since last DIFF'
      ,[Last Tlog Backup Date]
	  ,DATEDIFF(HOUR, [Last Tlog Backup Date], [InventoryDate]) AS 'Hours since last TLOG'
      ,[AG Role]
      ,[AG Group Name]
      ,[Mirror State]
      ,[Mirror Role]
      ,[Mirror Safety level]
      ,[Mirror Partner]
      ,[InventoryDate]
      ,[create_date]
      ,[state_desc]
      ,[Log ship Server]
  FROM [DBAdmin].[dbo].[Checks_Database_Information] DBInfo

    INNER join [dbo].[SourceServerList] SS on SS.[SQL Instance Name] = DBInfo.[ServerName]

  WHERE [AG Role] <> 'SECONDARY'
  AND [state_desc] <> 'RESTORING'

	ORDER BY SS.Environment,  DBInfo.ServerName, DBInfo.[recovery_model_desc] desc, DBInfo.[DatabaseName] asc
GO


