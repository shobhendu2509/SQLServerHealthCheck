/*
	Purpose:	Captures all the usuful overview data you need for a SQL instance. 
				Very useful if you run this from a SSMS central Management Server and catch for all servers.
	
	Title:			INVENTORY - Database server information		
	Version			1.5
	Created by:		Tim Roberts
	Date Created:	2018-09-24

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2016-07-13	1.0		Initial Release.
	TR			2016-07-18	1.1		Added 'Agent XP's' data capture as needed by BaselineStatistics solution.
	TR			2017-10-10	1.2		Created a dynamic SQL segment to get the memory setting of server regardless of version. Can now be run on a Central Management Server easily.
	TR			2018-01-09	1.3		Adapted to deal with 2005 system start time.
	TR			2018-09-24	1.4		Added columns for 'max degree of parallelism', 'cost threshold for parallelism', 'contained database authentication', 'filestream access level'
	TR			2018-09-24	1.5		Added the IsClustered Column
	TR			2018-09-27	1.6		Added column [AG_configured] to advise if Availability Group service is configured on the instance.

IMPORTANT NOTES
===============
You need to comment or uncomment certain lines of code depending on the version of SQL Server you are running this against.
SQL 2005 has different schemas to 2008 and 2012, it also doesnt have some of the DMV's.
SQL 2008 doesnt have some of the DMV's of SQL 2012.

1. Below under the block of code for MEMORY, CPU and Server start time you need to pick which line of code to run for your version.
2. At the very bottom of this code under the 'Master code block' you need to comment or uncomment a column name and join for 'BU_Compress_ON'
	Uncomment it if running later than SQL Server 2008R2, compressed backups are not in standard edition prior to this.

The capture of Default Data and Tlog locations will only work post 2012. It requires a registry search prior which is beyond the scope of this code.

GENERAL DEVELOPMENT NOTES
=========================
Windows version helpful link: https://mikegagliardi.wordpress.com/2013/03/19/finding-the-os-version-of-a-database-server-via-t-sql/
Try this to get loads of OS information: exec XP_MSVER

Memory and other OS information link: http://dba.stackexchange.com/questions/20973/quick-look-at-how-much-ram-is-allocated-to-sql-server

More general information: https://technet.microsoft.com/en-us/library/aa224828(v=sql.80).aspx

Help inserting into the table http://sqlserverplanet.com/tsql/insert-stored-procedure-results-into-table
Gets all the SP_CONFIGURE information into a temporary table to use.

*/

/********* Block of code for Temp table to obtain MEMORY, CPU and Server start time ************/

DECLARE @SQLversionCHAR nvarchar(50)
DECLARE @SQLversionCHAR2 nvarchar(50)
DECLARE @SQLVersionINT INT
DECLARE @SQLVersionINT2 INT
DECLARE @SQLCode nvarchar(max)
DECLARE @SQLCode2 nvarchar(max)
DECLARE @Memvalue INT
DECLARE @MEMResults NVARCHAR(MAX)
DECLARE @StartTimeResults DATETIME


DECLARE @Mem_cpu_List TABLE 
(
 ServerName VARCHAR(255),
 cpu_count INT,
 [Memory (MB)] INT,
 sqlserver_start_time DATETIME
)


--This code block checks the version of SQL Server and gets the server memory value.
--If the version is lower than SQL 2012, it uses the different memory definition.
--The memory value is put into a variable to be used in the insert statement for the table. 
-- Got some source code from here: https://stackoverflow.com/questions/27738561/set-execute-sp-executesql-result-into-a-variable-in-sql
SET @SQLversionCHAR = REPLACE((SUBSTRING (CONVERT(nvarchar(50),(SERVERPROPERTY('ProductVersion'))), 1, 2)), '.','')
Set @SQLVersionINT = CONVERT(INT, @SQLversionCHAR) 

SET @SQLCode = 

 CASE 
	--SQL Server 2012 +
	WHEN @SQLVersionINT  > 10 
	THEN 'SELECT @MEMResults = physical_memory_kb/1024 FROM sys.dm_os_sys_info SysInfo'
	
	--SQL Server 2008
	WHEN @SQLVersionINT  = 90
	THEN 'SELECT @MEMResults =  physical_memory_in_bytes/1048576 FROM sys.dm_os_sys_info SysInfo'

	--SQL 2005
	WHEN @SQLVersionINT  = 80
	THEN 'SELECT @MEMResults =  physical_memory_in_bytes/1048576 FROM sys.dm_os_sys_info SysInfo'
	END

exec sp_executeSQL @SQLCode, N'@MEMResults NVARCHAR(MAX) OUTPUT', @MEMResults OUTPUT

-- This code block enters the CPU and memory information into a temporary table to be used later.

SET @SQLversionCHAR = REPLACE((SUBSTRING (CONVERT(nvarchar(50),(SERVERPROPERTY('ProductVersion'))), 1, 2)), '.','')
Set @SQLVersionINT = CONVERT(INT, @SQLversionCHAR) 

IF @SQLVersionINT >= 10
	--SQL Server 2008 +
			Set @SQLCode2 = 'SELECT @StartTimeResults = sqlserver_start_time FROM sys.dm_os_sys_info SysInfo'
	ELSE
		--SQL Server 2005
			Set @SQLCode2 = 'SELECT @StartTimeResults = ''2005-01-01 00:00:01.000'' '

exec sp_executeSQL @SQLCode2, N'@StartTimeResults DATETIME OUTPUT', @StartTimeResults OUTPUT


INSERT INTO @Mem_cpu_List
( 
ServerName,
 cpu_count,
 [Memory (MB)],
 sqlserver_start_time --Have to remove this for SQL 2005
)

/************* Uncomment the line below depending on what version you are running this against, different schemas in different releases ********/


SELECT @@servername as 'ServerName', cpu_count, @MEMResults 'Memory (MB)', @StartTimeResults FROM sys.dm_os_sys_info SysInfo;
--SELECT @@servername as 'ServerName', cpu_count, @MEMResults 'Memory (MB)', sqlserver_start_time FROM sys.dm_os_sys_info SysInfo;


-- The code below for different versions of SQL is superceded as a result of the dynamic SQL Above. Saves lots of time when run on Central Management servers with a mix of versions.
--SQL Server 2012 +
--SELECT @@servername as 'ServerName', cpu_count, physical_memory_kb/1024 AS 'Memory (MB)', sqlserver_start_time FROM sys.dm_os_sys_info SysInfo;

--SQL Server 2008
--SELECT @@servername as 'ServerName', cpu_count, physical_memory_in_bytes/1048576 AS 'Memory (MB)', sqlserver_start_time FROM sys.dm_os_sys_info SysInfo;

--SQL Server 2005
--SELECT @@servername as 'ServerName', cpu_count, physical_memory_in_bytes/1048576 AS 'Memory (MB)', '2005-01-01 00:00:01.000' as 'sqlserver_start_time' FROM sys.dm_os_sys_info SysInfo;
--For versions prior to SQL 2012 need to use 'physical_memory_in_bytes' divide by 1048576 to get MB value
--select physical_memory_in_bytes as Bytes, physical_memory_in_bytes/1048576 as MB from sys.dm_os_sys_info 
--For SQL 2005 have to remove 'sqlserver_start_time' Instead put in a dummy value '2005-01-01 00:00:01.000'


/********* Temp table for all settings in sp_configure ********/
DECLARE @sp_configure_List TABLE 
(
 ServerName VARCHAR(255),
 InstanceName VARCHAR(255),
 name VARCHAR(255),
 minimum INT,
maximum INT,
config_value INT,
run_value INT

)

INSERT INTO @sp_configure_List
( 
name,
minimum,
maximum,
config_value,
run_value
)
EXEC sp_configure

UPDATE @sp_configure_List 
Set ServerName = @@SERVERNAME 
, InstanceName = @@SERVICENAME

--select ServerName, config_value as 'Agent_XPs' from @sp_configure_List ConList where name = 'Agent XPs'

--Might need another temp table to re-insert this so that it pulls the values back in a pivot table
-- Then pull the data from there 

--select @@SERVERNAME as 'SERVER Name', * from @sp_configure_List

/********* Temp table for SERVERPROPERTY information ***************/
DECLARE @SERVERPROPERTY_List TABLE 
(
[ServerName] VARCHAR(255),
[MachineName] NVARCHAR(255),
[InstanceName] VARCHAR(255),
[IsFCI_clustered] INT,
[AG_configured] INT,
[Server Collation] nVARCHAR(255),
[Edition] nVARCHAR(255),
[ProductLevel] nVARCHAR(10),
[SQLProductVersion] nvarchar(255),
[SQLEngineEdition] INT,
[OS Version] nvarchar(10),
[Integrated Security Only 1 = Integrated Only, 0 = Integrated and SQL Security] INT,
[IsSingleUser] INT,
[IsFullTextInstalled] INT,
[Default_DATA_Files] nvarchar(255),
[Default_TLOG_Files] nvarchar(255)
)

INSERT INTO @SERVERPROPERTY_List
( 
[ServerName], 
[MachineName], 
[InstanceName],
[IsFCI_clustered], 
[AG_configured],
[Server Collation], 
[Edition], 
[ProductLevel], 
[SQLProductVersion], 
[SQLEngineEdition], 
[OS Version], 
[Integrated Security Only 1 = Integrated Only, 0 = Integrated and SQL Security], 
[IsSingleUser], 
[IsFullTextInstalled],
[Default_DATA_Files],
[Default_TLOG_Files] 
)

-- Server property information: https://docs.microsoft.com/en-us/sql/t-sql/functions/serverproperty-transact-sql?view=sql-server-2017
SELECT
@@SERVERNAME as 'ServerName',
CONVERT(nvarchar(255),(SERVERPROPERTY('MachineName'))) AS MachineName,
@@SERVICENAME as 'InstanceName',
CONVERT(int,(SERVERPROPERTY('IsClustered'))) AS [IsFCI_clustered],
CONVERT(INT,(SERVERPROPERTY('IsHadrEnabled'))) AS [AG_configured],
CONVERT(nvarchar(255),(SERVERPROPERTY('Collation'))) AS 'Server Collation',
CONVERT(nvarchar(255),(SERVERPROPERTY('Edition'))) AS Edition ,
CONVERT(nvarchar(10),(SERVERPROPERTY('ProductLevel'))) AS ProductLevel,
CONVERT(nvarchar(255),(SERVERPROPERTY('ProductVersion'))) AS SQLProductVersion ,
CONVERT(int,(SERVERPROPERTY('EngineEdition'))) AS SQLEngineEdition ,
CONVERT(nvarchar(10),(RIGHT(SUBSTRING(@@VERSION, CHARINDEX('Windows NT', @@VERSION), 14), 3))) as 'OS Version',
--PhysicalMemory (@Mem_cpu_List)
--Product (already have this as product version)
--Platform (not needed only interested in SQL Server production level)
--Processors (@Mem_cpu_List)
--VersionString (dont need)
--Version (dont need)
--ProductLevel (dont need)
CONVERT(int,(SERVERPROPERTY('IsIntegratedSecurityOnly'))) AS 'Integrated Security Only 1 = Integrated Only, 0 = Integrated and SQL Security' ,
CONVERT(int,(SERVERPROPERTY('IsSingleUser'))) AS IsSingleUser ,
-- minMem (min server memory (MB) from @sp_configure_List)
-- maxMem (max server memory (MB) from @sp_configure_List)
-- Database Mail XPs (Database Mail XPs from  @sp_configure_List) helps us work out if alerting can be configured
-- clrRun (leave this for now)
-- OLEAutomatedProcs (Ole Automation Procedures from @sp_configure_List)
-- xp_cmdshell (xp_cmdshell @sp_configure_List)
-- remote admin connections (remote admin connections @sp_configure_List) This is the dedicated admin connection to use in emergencies
-- c2 audit mode (c2 audit mode from @sp_configure_List)
-- priority boost (priority boost from @sp_configure_List  want this OFF)
-- show advanced options (show advanced options from @sp_configure_List)

--(select conlist.config_value where conlist.name like 'Database Mail XPs') as 'Database Mail XPs',
CONVERT(int,(SERVERPROPERTY('IsFullTextInstalled'))) AS IsFullTextInstalled,
CONVERT(nvarchar(255),(SERVERPROPERTY('instancedefaultdatapath'))) AS [Default_DATA_Files], 
CONVERT(nvarchar(255),(SERVERPROPERTY('instancedefaultlogpath'))) AS [Default_TLOG_Files] 


/*-------------------------------
Block of code to get tempdb information
Adapted from here: https://blogs.msdn.microsoft.com/dfurman/2010/04/05/tempdb-configuration-check-script/
-------------------------------*/
DECLARE @tempDB_info TABLE 
(
 ServerName VARCHAR(255),
 InstanceName VARCHAR(255),
[TEMPDB_MultipleDataFiles] VARCHAR(5),
[TEMPDB_EqualSize] VARCHAR(5),
[TEMP_DB_EqualMaxSize] VARCHAR(5),
[TEMPDB_EqualGrowth] VARCHAR(5),
[TEMPDB_NoFilesWithPercentGrowth] VARCHAR(5)

)

		DECLARE @tempDB_info_source TABLE 
		(
		[size] INT,
		[max_size] INT,
		[growth] INT,
		[is_percent_growth] INT,
		[AvgSize] INT,
		[AvgMaxSize] INT,
		[AvgGrowth] INT
		)

		INSERT INTO @tempDB_info_source 
		( 
		[size], 
		[max_size], 
		[growth], 
		[is_percent_growth], 
		[AvgSize], 
		[AvgMaxSize], 
		[AvgGrowth]
		)


		SELECT  size, 
				max_size, 
				growth, 
				is_percent_growth, 
				AVG(CAST(size AS decimal(18,4))) OVER() AS AvgSize, 
				AVG(CAST(max_size AS decimal(18,4))) OVER() AS AvgMaxSize, 
				AVG(CAST(growth AS decimal(18,4))) OVER() AS AvgGrowth 
		FROM tempdb.sys.database_files  
		WHERE   type_desc = 'ROWS' 
				AND 
				state_desc = 'ONLINE' 
		--) 


INSERT INTO @tempDB_info 
( 
[TEMPDB_MultipleDataFiles], 
[TEMPDB_EqualSize], 
[TEMP_DB_EqualMaxSize], 
[TEMPDB_EqualGrowth], 
[TEMPDB_NoFilesWithPercentGrowth]
)

		SELECT  CASE WHEN (SELECT scheduler_count FROM sys.dm_os_sys_info)  
						  BETWEEN COUNT(1)  
							  AND COUNT(1) * 2 
					 THEN 'YES' 
					 ELSE 'NO' 
				END 
				AS MultipleDataFiles, 
				CASE SUM(CASE size WHEN AvgSize THEN 1 ELSE 0 END)  
					 WHEN COUNT(1) THEN 'YES' 
					 ELSE 'NO' 
				END AS EqualSize, 
				CASE SUM(CASE max_size WHEN AvgMaxSize THEN 1 ELSE 0 END)  
					 WHEN COUNT(1) THEN 'YES'  
					 ELSE 'NO'  
				END AS EqualMaxSize, 
				CASE SUM(CASE growth WHEN AvgGrowth THEN 1 ELSE 0 END)  
					 WHEN COUNT(1) THEN 'YES' 
					 ELSE 'NO' 
				END AS EqualGrowth, 
				CASE SUM(CAST(is_percent_growth AS smallint))  
					 WHEN 0 THEN 'YES' 
					 ELSE 'NO' 
				END AS NoFilesWithPercentGrowth  

		from @tempDB_info_source 

UPDATE @tempDB_info 
Set ServerName = @@SERVERNAME 
, InstanceName = @@SERVICENAME

--select * from @tempDB_info

/*---------------------------
END OF TEMPDB CODE BLOCK
----------------------------*/



/*********** MASTER QUERY BLOCK that brings back all the results into a single row per instance *************/
SELECT
SRVl.[ServerName], 
SRVl.[MachineName], 
SRVl.[InstanceName], 
[IsFCI_clustered],
[AG_configured],
MCPU.[sqlserver_start_time],
SRVl.[Server Collation], 
SRVl.[Edition], 
SRVl.[ProductLevel], 
SRVl.[SQLProductVersion], 
SRVl.[SQLEngineEdition], 
SRVl.[OS Version],
MCPU.[cpu_count],
MCPU.[Memory (MB)],
AOPtions.show_advanced_options,
mem1.minMem,
mem2.maxMem,
[maxDOPtbl].[maxDOP],
[CostParalleltbl] .[CostParallel],
[Filestreamltbl].[Filestream],
[containedtbl].[ContainDBauthentication],
ole1.OLEAutomatedProcs,
xpcmd.[xp_cmdshell],
AXP.Agent_XPs,
[AUDIT].c2AuditOn,
BOOST.CPU_priority_boost_ON,
mail.DBMail,
SRVl.[Integrated Security Only 1 = Integrated Only, 0 = Integrated and SQL Security],
SRVl.IsSingleUser,
SRVl.IsFullTextInstalled,
DAC.DAC_enabled,
SRVl.Default_DATA_Files,
SRVl.Default_TLOG_Files,
TDB.[TEMPDB_MultipleDataFiles], 
TDB.[TEMPDB_EqualSize], 
TDB.[TEMP_DB_EqualMaxSize], 
TDB.[TEMPDB_EqualGrowth], 
TDB.[TEMPDB_NoFilesWithPercentGrowth]


/*** Uncomment the lines in the code block below if on SQL Server 2008R2 or higher **/
, BUCOMP.BU_Compress_ON
/*** Uncomment the lines in the code block above if on SQL Server 2008R2 or higher **/

FROM @SERVERPROPERTY_List SRVl
LEFT JOIN @Mem_cpu_List MCPU ON MCPU.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'minMem' from @sp_configure_List ConList where name = 'min server memory (MB)') mem1 ON mem1.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'maxMem' from @sp_configure_List ConList where name = 'max server memory (MB)' ) mem2 ON mem1.ServerName = SRVl.[ServerName]

LEFT JOIN (select ServerName, config_value as 'maxDOP' from @sp_configure_List ConList where name = 'max degree of parallelism') [maxDOPtbl] ON [maxDOPtbl].ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'CostParallel' from @sp_configure_List ConList where name = 'cost threshold for parallelism' ) [CostParalleltbl] ON [CostParalleltbl].ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'Filestream' from @sp_configure_List ConList where name = 'filestream access level' ) [Filestreamltbl] ON [Filestreamltbl].ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'ContainDBauthentication' from @sp_configure_List ConList where name = 'contained database authentication' ) [containedtbl] ON [containedtbl].ServerName = SRVl.[ServerName]

--contained database authentication

LEFT JOIN (select ServerName, config_value as 'DBMail' from @sp_configure_List ConList where name = 'Database Mail XPs'  ) Mail ON Mail.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'OLEAutomatedProcs' from @sp_configure_List ConList where name = 'Ole Automation Procedures') ole1 ON ole1.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'xp_cmdshell' from @sp_configure_List ConList where name = 'xp_cmdshell') xpCmd ON xpCmd.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'DAC_enabled' from @sp_configure_List ConList where name = 'remote admin connections') DAC ON DAC.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'c2AuditOn' from @sp_configure_List ConList where name = 'c2 audit mode') [AUDIT] ON [AUDIT].ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'CPU_priority_boost_ON' from @sp_configure_List ConList where name = 'priority boost') BOOST ON BOOST.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'show_advanced_options' from @sp_configure_List ConList where name = 'show advanced options') AOPtions ON AOptions.ServerName = SRVl.[ServerName]
LEFT JOIN (select * from @tempDB_info) TDB ON TDB.ServerName = SRVl.[ServerName]
LEFT JOIN (select ServerName, config_value as 'Agent_XPs' from @sp_configure_List ConList where name = 'Agent XPs') AXP ON AXP.ServerName = SRVl.[ServerName]


/*** Uncomment the lines in the code block below if on SQL Server 2008R2 or higher **/
LEFT JOIN (select ServerName, config_value as 'BU_Compress_ON' from @sp_configure_List ConList where name = 'backup compression default') BUCOMP ON BUCOMP.ServerName = SRVl.[ServerName]
/*** Uncomment the lines in the code block above if on SQL Server 2008R2 or higher **/


/* Could be used as an alternate to get the OS version *******/
--SELECT RIGHT(SUBSTRING(@@VERSION, 
--CHARINDEX('Windows NT', @@VERSION), 14), 3)
--select CHARINDEX('Windows NT', @@VERSION)
--exec XP_MSVER
--Temp table, insert into this, then join up for the main query.




