/***** Count of SQL versions by environment ******/

-- ENTER CUSTOMER INVENTORY DATABASE HERE
USE [DBAdmin]

-- Number of instances and their versions. 
    SELECT [Environment], count ([SQLVersion]) as [CountInstances], [SQLVersion]
   FROM [dbo].[SourceServerList]
   WHERE ActiveStatus = 1
   group by  [SQLVersion], [Environment]


-- Number of databases across servers
	SELECT b.[Environment], count (a.[DatabaseName]) as [Count of Databases], b.[SQLVersion]
	
	FROM [dbo].[Checks_Database_Information] a
	left JOIN [dbo].[SourceServerList] b ON a.[ServerName] = b.[SQL Instance Name]
	WHERE b.ActiveStatus = 1
	group by  b.[SQLVersion], b.[Environment]
    order by b.[environment], b.[SQLVersion]


