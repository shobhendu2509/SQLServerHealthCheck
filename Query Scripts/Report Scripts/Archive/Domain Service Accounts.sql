/****** Domain Service Accounts and permissions under local policies. For example to run as a service.  ******/

-- BE AWARE A CATCHALL FOR THIS MIGHT BE THE SERVICE IS UNDER THE GROUP 'BUILTIN\Administrators' AND THAT ACCOUNT IS LISTED UNDER THE APPROPRIATE POLICY

-- ENTER THE NAME OF THE CUSTOMER INVENTORY DATABASE HERE
USE [Comcare_inventory]

--Temporary tables to contain the CTE for the Domain Service accounts and policies. We need this as have to join the CTE result sets together.
CREATE TABLE #DomainServiceAccounts
(
[MachineName] NVARCHAR(255) NULL,
[startname] NVARCHAR(255) NULL
)

CREATE TABLE #ServerPolicies
(
[account] NVARCHAR(2000) NULL,
[Right] NVARCHAR(100) NULL,
[server] NVARCHAR(255) NULL,
[DateCaptured] datetime2 NULL
)

-- Inserts all the results of the DomainServiceAccounts into the temporary table. 
-- We only want the distinct names of servers and domain service accounts that run on those servers.
-- We exclude any service accounts that are local to the OS. It is assumed these have the necessary permissions. 
;with DomainServiceAccounts_cte as

(
SELECT distinct [MachineName], [startname]
  FROM [Comcare_inventory].[dbo].[Inventory_SQLServicesStatusWMI]
  where [startname] not like 'NT Service%' and [startname] not like 'LocalSystem'  and [startname] not like 'NT AUTHORITY%'
  
)
 
INSERT INTO #DomainServiceAccounts 
 select * from DomainServiceAccounts_cte
 order by [MachineName], [startname]

 -- Inserts all the results of the ServerPolicies into the temporary table. 
 ;with ServerPolicies_cte as
 (
 SELECT [account]
      ,[Right]
      ,[server]
      ,[DateCaptured]
  FROM [Comcare_inventory].[dbo].[Inventory_SQLServicesPolicyUserRights]
 -- where server = 'DCBR03VSQL17'and [Right] = 'SeServiceLogonRight' --AND [Right] like '%DEV\svc_dev_sql_sa%'
   --where [Right] = 'SeServiceLogonRight'
  )
 
 INSERT INTO #ServerPolicies
  SELECT * FROM ServerPolicies_cte
  ORDER BY [server]

 -- Select testing
 --SELECT * FROM #DomainServiceAccounts 
 --SELECT * FROM #ServerPolicies

 /************* RUN AS A SERVICE POLICY CHECKS ********************/
 --Results set to show if the account the service is running under is in the local policy group. 
 -- Any value greater than 0 in the 'ServiceListed' column means the service is listed. Any with 0 mean it is not. Any with NULL that also have NULL for 'Service runs as' mean we probably have not captured the information due to insufficient access rights.
-- BE AWARE A CATCHALL FOR THIS MIGHT BE THE SERVICE IS UNDER THE GROUP 'BUILTIN\Administrators' AND THAT ACCOUNT IS LISTED UNDER THE APPROPRIATE POLICY
	 SELECT c.Environment, a.account, a.[Right], a.[server], a.DateCaptured, B.startname AS 'Service runs as'
	 ,CHARINDEX(B.[startname], [account]) AS ServiceListed
	 FROM #ServerPolicies a 
	 LEFT JOIN #DomainServiceAccounts b ON b.[MachineName] = a.[server]
	 left JOIN [dbo].[SourceServerList] c ON c.[MachineName] COLLATE Latin1_General_CI_AS = b.[MachineName]
	 WHERE A.[Right] = 'SeServiceLogonRight'
	 ORDER BY c.Environment, a.[server]


/************* LOG ON AS A BATCH PROCESS POLICY  ********************/
 --Results set to show if the account the service is running under is in the local policy group. 
 -- Any value greater than 0 in the 'ServiceListed' column means the service is listed. Any with 0 mean it is not. Any with NULL that also have NULL for 'Service runs as' mean we probably have not captured the information due to insufficient access rights.
	 SELECT c.Environment, a.account, a.[Right], a.[server], a.DateCaptured, B.startname AS 'Service runs as'
	 ,CHARINDEX(B.[startname], [account]) AS ServiceListed
	 FROM #ServerPolicies a 
	 LEFT JOIN #DomainServiceAccounts b ON b.[MachineName] = a.[server]
	 left JOIN [dbo].[SourceServerList] c ON c.[MachineName] COLLATE Latin1_General_CI_AS = b.[MachineName]
	 WHERE A.[Right] = 'SeBatchLogonRight'
	 ORDER BY c.Environment, a.[server]


/************* LOCK PAGES IN MEMORY POLICY CHECKS ********************/
 --Results set to show if the account the service is running under is in the local policy group. 
 -- Any value greater than 0 in the 'ServiceListed' column means the service is listed. Any with 0 mean it is not. Any with NULL that also have NULL for 'Service runs as' mean we probably have not captured the information due to insufficient access rights.
	 SELECT c.Environment, a.account, a.[Right], a.[server], a.DateCaptured, B.startname AS 'Service runs as'
	 ,CHARINDEX(B.[startname], [account]) AS ServiceListed
	 FROM #ServerPolicies a 
	 LEFT JOIN #DomainServiceAccounts b ON b.[MachineName] = a.[server]
	 left JOIN [dbo].[SourceServerList] c ON c.[MachineName] COLLATE Latin1_General_CI_AS = b.[MachineName]
	 WHERE A.[Right] = 'SeLockMemoryPrivilege'
	 ORDER BY c.Environment, a.[server]

 
 DROP TABLE #DomainServiceAccounts
 DROP TABLE #ServerPolicies

 -- This is a great resource!
 --https://gallery.technet.microsoft.com/scriptcenter/Get-GroupMember-Get-Local-72fecf21
 
 -- Also tried this.
 --https://social.technet.microsoft.com/Forums/scriptcenter/en-US/6fba4e06-2b3f-4c43-9352-3fb33a1951c0/get-all-members-of-local-admin-group-for-list-of-servers