/****** Lists out all none local system accounts that have privileged access to SQL Server by a server fixed role membership ******/
SELECT b.[environment]
,a.[SQL Instance Name]
      ,[DateCaptured]
      ,[loginname]
      ,[type]
      ,[type_desc]
      ,[is_disabled]
      ,[sysadmin]
      ,[securityadmin]
      ,[serveradmin]
      ,[setupadmin]
      ,[processadmin]
      ,[diskadmin]
      ,[dbcreator]
      ,[bulkadmin]
      ,[create_date]
      ,[modify_date]
  FROM [DBAdmin_PROD].[dbo].[Inventory_ServerRoleMembers] a
  LEFT JOIN [dbo].[SourceServerList] b ON a.[SQL Instance Name] = b.[SQL Instance Name]


  Where 
(  [sysadmin] > 0
OR [securityadmin] > 0
OR  [serveradmin] > 0
OR  [setupadmin] > 0
OR [processadmin] > 0
OR [diskadmin] > 0
OR [dbcreator] > 0
OR  [bulkadmin] > 0)

AND [loginname] NOT LIKE 'NT AUTHORITY%' AND [loginname] NOT LIKE 'NT SERVICE%' AND [loginname] NOT LIKE 'sa'

order by b.[environment], a.[SQL Instance Name], a.[loginname]