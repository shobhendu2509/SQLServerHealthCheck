/****** Services  ******/
USE [DBAdmin]
SELECT 
		b.[environment],
		a.[MachineName]
      ,[name]
      ,[DisplayName]
      ,[state]
      ,[startmode]
      ,[startname]
      ,[PathName]
      ,[Description]
      ,[DateCaptured]
  FROM [DBAdmin].[dbo].[Checks_SQLServicesStatusWMI] a
      LEFT JOIN [dbo].[SourceServerList] b ON a.MachineName = b.MachineName
  
  WHERE b.ActiveStatus = 1
  --where MachineName like 'SCBRVSQL01'
  order by b.[environment], a.MachineName