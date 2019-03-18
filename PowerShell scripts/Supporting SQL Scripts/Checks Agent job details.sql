/**************************************************************************************************************
	Purpose:	Agent jobs on the server and useful information of when they were created, modified and last run.
			
	Version			1.2
	Created by:		Tim Roberts
	Date Updated:	2018-08-09

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2017-04-13	1.0		Initial Release, modified from range of sources.
	TR			2017-06-22	1.1		Added more helpful information
	TR			2017-06-22	1.1		Added Servername and instancename
	TR			2018-08-09	1.2		Updated with next run date and time of the jobs.

NOTES:
Sources: https://www.sqlservercentral.com/Forums/Topic410789-8-1.aspx

***************************************************************************************************************/


-- Provide general information about all the Agent jobs, for example if they are enabled and their operator Name
--use msdb
--select suser_sname(s.owner_sid) as OwnerName, s.name, s.description, s.enabled, o.name as OperatorName, s.date_created, s.date_modified, s.job_id from sysjobs s
--left outer join sysoperators o on s.notify_email_operator_id = o.id
--where s.name not like 'syspolicy_purge_history'
--order by ownername, s.name


use msdb
select 
@@SERVERNAME ServerName, @@SERVICENAME InstanceName,
suser_sname(s.owner_sid) as OwnerName, s.name, s.description, s.enabled, jh.run_status,  o.name as OperatorName, s.date_created, s.date_modified, s.job_id,
MAX(CAST(
STUFF(STUFF(CAST(jh.run_date as varchar),7,0,'-'),5,0,'-') + ' ' + 
STUFF(STUFF(REPLACE(STR(jh.run_time,6,0),' ','0'),5,0,':'),3,0,':') as datetime)) AS [LastRun],
CAST(
		STUFF(STUFF(CAST(js.next_run_date as varchar),7,0,'-'),5,0,'-') + ' ' + 
		STUFF(STUFF(REPLACE(STR(js.next_run_time,6,0),' ','0'),5,0,':'),3,0,':') as datetime) [NextRun]

from sysjobs s
left outer join sysoperators o on s.notify_email_operator_id = o.id
left JOIN msdb.dbo.sysjobhistory jh ON jh.job_id = s.job_id AND jh.step_id = 0
LEFT OUTER JOIN dbo.sysjobschedules JS ON s.job_id = JS.job_id 

where s.name not like 'syspolicy_purge_history'
Group by s.owner_sid, s.name, s.description, s.enabled, jh.run_status, o.name , s.date_created, s.date_modified, s.job_id, js.next_run_date, js.next_run_time--, jh.run_duration
order by ownername, s.name 



--INNER JOIN msdb.dbo.sysjobhistory jh 
--ON jh.job_id = s.job_id AND jh.step_id = 0

/*--Provides the user SID based on the user name:
-- Pinched from this website: http://connect.microsoft.com/SQLServer/feedback/details/295846/job-owner-reverts-to-previous-owner-when-scheduled-maintenance-plan-is-edited
update msdb.dbo.sysssispackages
set [ownersid] = suser_sid('sa')
where [name] = 'MaintenancePlan'

-- Use this to work out the User SID
select suser_sid('sa')*/

/*
join sys.databases on sysjobs.owner_SID = sys.databases.owner_sid

select suser_sname(owner_sid) from sys.databases

select * from  sys.databases*/

--select * from  sysjobs



