USE [DBAdmin]
GO

--Checks if it already exists, if not it creates the procedure, if so it just alters it.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Agent_jobs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_Agent_jobs] AS'
END
GO
ALTER PROCEDURE [dbo].[sp_Agent_jobs]

AS 

/****** 
Name:			Agent Job - Report details  

Author:			Tim Roberts 
Creation Date:	04/03/2019
Version:		1.1

Summary:	Shows all of the jobs and orders then descending according to the success of their outcome (run_status)


Modification History:
-------------------------------------------------------------------------------
Version Date		Name			Modification
-------------------------------------------------------------------------------
1.0 	02/01/2019	Tim Roberts		Initial release
1.1		04/03/2019	Tim Roberts		Change the join on the [SourceServerList] from [MachineName] to [SQL Instance Name] as most servers capture the Instance Name as Server name + instance name.


Look for
==========
	1.	Any job with a run_status of 0 (Failed), if so look at the line above and see if the same job ran more recently with a run status of 1 (Success)
		If so, ignore the failed run, this information will eventually age out of the logs. The most recent run is the most important.
		If however, you see a lot of entries for the same job having failed, this is worth investigating as may indicate an ongoing problem.
	
	2.	Jobs without operators. Some job, for example the 'Alert when Restart Happens', 'syspolicy_check_schedule_xxx' and 'BaselineStatsGathering_Hourly' jobs arent set to alert an operator if they fail. 
		This is because either they are configured to include an email alert in the job (Alert when Restart Happens) or would create unncessary noise.
		However, most jobs will benefit from an operator. Check that any jobs with a NULL value are suited not to have an operator.

Status of the job execution:
	0 = Failed
	1 = Succeeded
	2 = Retry
	3 = Canceled
	4 = In Progress

More information: https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobhistory-transact-sql?view=sql-server-2017

******/
SELECT
	SS.Environment
	,[ServerName]
	  ,[name] AS 'Job Name'
	  ,[run_status]
	  ,[LastRun]
	  ,[NextRun]
      ,[InstanceName]
      ,[OwnerName]
      ,[description]
      ,[enabled]
      ,[OperatorName]
      ,[date_created]
      ,[date_modified]
      ,[job_id]
      
  FROM [DBAdmin].[dbo].[Checks_AgentJobs] AJ
    INNER join [dbo].[SourceServerList] SS on SS.[SQL Instance Name] = AJ.ServerName
  where 
	  enabled = 1
 
  order by SS.Environment, ServerName, name asc, [LastRun] desc

