USE [DBAdmin]
GO

--Checks if it already exists, if not it creates the procedure, if so it just alters it.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Instance_Information]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_Instance_Information] AS'
END
GO
ALTER PROCEDURE [dbo].[sp_Instance_Information]

AS 


/****** 
Name:			Instance Information - Report details  

Author:			Tim Roberts 
Creation Date:	2nd Jan 2019
Version:		1.0

Summary:	Reports the Instance names, environment their patch level and when they stated up


Modification History:
-------------------------------------------------------------------------------
Version Date		Name			Modification
-------------------------------------------------------------------------------
1.0 	02/01/2019	Tim Roberts		Initial release

Look for
==========

	1.	Instances that havent been patched recently. Use this site to see the latest patches: https://sqlserverbuilds.blogspot.com/
		All instances should be patched to within 3 months of the most recent CU, Service pack or security update.
	2.  Any instnaces that have not been up for at least 1 week. Check to see if the restart was intended, if you dont know otherwise check the server system logs for errors.
		Some servers restart automatically as part of the windows update. Most customer disable this, but some do not.

******/
  SELECT 
	SS.Environment
	,INST.[ServerName] AS 'Server Name'
	,INST.[SQLProductVersion] AS 'SQL Version'
	,CONVERT(smalldatetime, INST.sqlserver_start_time) AS 'Up Since'

  FROM [DBAdmin].[dbo].[Checks_Instance_Information] INST
  INNER join [dbo].[SourceServerList] SS on SS.[MachineName] = INST.[MachineName]
  order by SS.Environment ASC, inst.ServerName ASC