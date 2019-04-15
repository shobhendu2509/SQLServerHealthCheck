/***** View that shows all SQL Agent jobs and if the last run was a success or fail***/

	USE [DBAdmin]
	GO


	IF EXISTS(SELECT 1 FROM SYS.VIEWS WHERE NAME='vwAgent_jobs' AND TYPE='v')
	DROP VIEW [vwAgent_jobs];
	GO

	CREATE VIEW [dbo].[vwAgent_jobs] AS

	-- Creates a CTE and then in turn uses that to show if the most recent job run succeeded.
	-- If it failed we can use this to investigate. If it suceeded and previous jobs failed, we can probably ignore the failures.
	WITH AgentJobsCTE AS
	(
	SELECT
		SS.Environment
		,[ServerName]
		  ,[name] AS 'Job Name'
		  ,[enabled]
		  ,[run_status]
		  ,RankRecent = row_number() over
			(
				partition by SS.Environment, [ServerName], [name]
				order by [LastRun] desc
			)
		  ,[LastRun]
		  ,[NextRun]
		  ,[InstanceName]
		  ,[OwnerName]
		  ,[description] 
		  ,[OperatorName]
		  ,[date_created]
		  ,[date_modified]
		  ,[job_id]
 
	  FROM [DBAdmin].[dbo].[Checks_AgentJobs] AJ
		INNER join [dbo].[SourceServerList] SS on SS.[SQL Instance Name] = AJ.ServerName
	  WHERE 
		  ENABLED = 1

	)

	SELECT 

		[Environment]
		,[ServerName]
		  ,[Job Name]
		  ,[enabled]
		  ,CASE 
				WHEN ([run_status] = 1 AND RankRecent = 1) THEN 1 --Last run was successful
				WHEN ([run_status] = 0 AND RankRecent = 1) THEN 0 -- Last run was unsuccessful
				ELSE NULL -- Earlier runs were unsuccessful, but a more recent run was successful.
			END AS [MostRecentSuccessOrFail]
		  ,[run_status]
		  ,[RankRecent]
		  ,[OperatorName]
		  ,[LastRun]
		  ,[NextRun]
		  ,[InstanceName]
		  ,[OwnerName]
		  ,[description]
		  
		  ,[date_created]
		  ,[date_modified]
		  ,[job_id]


	 FROM AgentJobsCTE

	-- order by Environment, ServerName, [Job Name] asc, [LastRun] desc

GO




