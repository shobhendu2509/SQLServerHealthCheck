/****** 
Name:			Truncates the check tables for fresh data.

Author:			Tim Roberts 
Creation Date:	08/04/2019
Version:		1.2


Modification History:
-------------------------------------------------------------------------------
Version Date		Name			Modification
-------------------------------------------------------------------------------
1.0 	10/01/2019	Tim Roberts		Initial release
1.1		28/02/2019	Tim Roberts		Updated with tables: [Checks_DataFiles], [Checks_LocalAdministrators_members], [Checks_ServerRoleMembers], [Checks_SQLServicesPolicyUserRights]
1.2		08/04/2019	Tim Roberts		Minor update, removed the explicit reference to DBADmin in each of the trucate commands. Will instead depend on the 'USE DBAdmin' command at the top of the sproc.


******/

USE [DBAdmin]
GO

--Checks if it already exists, if not it creates the procedure, if so it just alters it.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_truncate_check_tables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_truncate_check_tables] AS'
END
GO
ALTER PROCEDURE [dbo].[sp_truncate_check_tables]

AS 

-- Truncates the temporary check tables ready for new data
TRUNCATE TABLE [dbo].[Checks_AgentJobs]
TRUNCATE TABLE [dbo].[Checks_Database_Information]
TRUNCATE TABLE [dbo].[Checks_DataFiles]
TRUNCATE TABLE [dbo].[Checks_DBCCLastGoodCheck]
TRUNCATE TABLE [dbo].[Checks_Instance_Information]
TRUNCATE TABLE [dbo].[Checks_LocalAdministrators_members]
TRUNCATE TABLE [dbo].[Checks_ServerDiskInformation]
TRUNCATE TABLE [dbo].[Checks_ServerRoleMembers]
TRUNCATE TABLE [dbo].[Checks_SQL_Log]
TRUNCATE TABLE [dbo].[Checks_SQLServicesPolicyUserRights]
TRUNCATE TABLE [dbo].[Checks_SQLServicesStatusWMI]