/****** Script for SelectTopNRows command from SSMS  ******/

-- Use the name of the customer inventory database
use [DBAdmin]

SELECT 		b.[environment]
		,[ServerName]
      ,a.[MachineName]
      ,[InstanceName]
      ,a.[IsFCI_clustered]
      ,a.[AG_configured]
      ,[sqlserver_start_time]
      ,[Server Collation]
      ,[Edition]
      ,[ProductLevel]
      ,[SQLProductVersion]
      ,[SQLEngineEdition]
      ,[OS Version]
      ,[cpu_count]
      ,[Memory (MB)]
      ,[show_advanced_options]
      ,[minMem]
      ,[maxMem]
      ,[maxDOP]
      ,[CostParallel]
      ,[Filestream]
      ,[ContainDBauthentication]
      ,[OLEAutomatedProcs]
      ,[xp_cmdshell]
      ,[Agent_XPs]
      ,[c2AuditOn]
      ,[CPU_priority_boost_ON]
      ,[DBMail]
      ,[Integrated Security Only 1 = Integrated Only, 0 = Integrated and SQL Security]
      ,[IsSingleUser]
      ,[IsFullTextInstalled]
      ,[DAC_enabled]
      ,[Default_DATA_Files]
      ,[Default_TLOG_Files]
      ,[TEMPDB_MultipleDataFiles]
      ,[TEMPDB_EqualSize]
      ,[TEMP_DB_EqualMaxSize]
      ,[TEMPDB_EqualGrowth]
      ,[TEMPDB_NoFilesWithPercentGrowth]
      ,[BU_Compress_ON]
  FROM [DBAdmin].[dbo].[Checks_Instance_Information] a
  LEFT JOIN [dbo].[SourceServerList] b ON a.MachineName = b.MachineName

  --where
  --a.sqlserver_start_time < (getdate() - 180)

   order by b.[environment], a.MachineName