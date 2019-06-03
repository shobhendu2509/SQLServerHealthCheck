USE [DBAdmin]
GO

--Checks if it already exists, if not it creates the procedure, if so it just alters it.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_DBCC_Last]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_DBCC_Last] AS'
END
GO
ALTER PROCEDURE [dbo].[sp_DBCC_Last]

AS 

/****** 
Name:			DBCC checks - Report details  

Author:			Tim Roberts 
Creation Date:	03/06/2019
Version:		1.2

Summary:	Shows any databases that may have integrity issues or have not recently been checked.


Modification History:
-------------------------------------------------------------------------------
Version Date		Name			Modification
-------------------------------------------------------------------------------
1.0 	02/01/2019	Tim Roberts		Initial release
1.1		04/03/2019	Tim Roberts		Change the join on the [SourceServerList] from [MachineName] to [SQL Instance Name] as most servers capture the Instance Name as Server name + instance name.
1.2		03/06/2019	Tim Roberts		Changed the join on the [MachineName] as had trouble at Comcare with it running the other way. We may need to review this and find a universal way to make this work.

Look for
==========

	1.	Any database with a status other than OK.
	2.  Any database with that has not been checked in more than 7 days.

******/

SELECT 
	   SS.Environment
      ,[Status]
      ,[DaysSinceLastGoodCheckDb]
	  ,[ComputerName]
      ,[InstanceName]
      ,[SqlInstance]
      ,[Database]
      ,[DatabaseCreated]
      ,[LastGoodCheckDb]
      ,[DaysSinceDbCreated]
      ,[DataPurityEnabled]
      ,[CreateVersion]
      ,[DbccFlags]
  FROM [DBAdmin].[dbo].[Checks_DBCCLastGoodCheck] DBLast
  --INNER join [dbo].[SourceServerList] SS on SS.[SQL Instance Name] = DBLast.[SqlInstance]
  INNER join [dbo].[SourceServerList] SS on SS.[MachineName] = DBLast.[ComputerName]
  ORDER BY SS.Environment, DBLast.[SqlInstance], DBLast.[Database]
 

