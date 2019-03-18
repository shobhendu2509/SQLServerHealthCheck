/***********************************************************************************

	Version 0.2
	Created by:		Tim Roberts
	Date Created:	2017-11-28
	
	Title:			Gets database file information, really good for general assessment of all data files on a server. 
	Purpose:		Helps work out any bad growth parameters or log files that are too big. Includes stall reads and writes.

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2014-08-13  0.1		First initial copy.
	TR			2017-05-11	1.0		Recovery mode added to output. Useful to determine if a full backup must be run if you shrink the log file.
	TR			2017-06-22	1.1		Added Servername and instancename
	TR			2017-11-28	1.2		Added column for maximum file size as some organisations still set this.

***********************************************************************************/


--1st script with all the file information except stall waits.
DECLARE @DBInfo TABLE  
( ServerName VARCHAR(100),  
DatabaseName VARCHAR(100),  
FileSizeMB INT,
MaxSize INT,  
LogicalFileName sysname,  
PhysicalFileName NVARCHAR(520),  
Status sysname,  
Updateability sysname,  
RecoveryMode sysname,  
FreeSpaceMB INT,  
FreeSpacePct VARCHAR(7),  
FreeSpacePages INT,  
PollDate datetime)  

DECLARE @command VARCHAR(5000)  

SELECT @command = 'Use [' + '?' + '] SELECT  
@@servername as ServerName,  
' + '''' + '?' + '''' + ' AS DatabaseName,  
CAST(sysfiles.size/128.0 AS int) AS FileSize,  
sysfiles.maxsize AS MaxSize,
sysfiles.name AS LogicalFileName, sysfiles.filename AS PhysicalFileName,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,  
CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, ' + '''' +  
       'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) AS FreeSpaceMB,  
CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY(sysfiles.name,  
' + '''' + 'SpaceUsed' + '''' + ' ) AS int)/128.0)/(sysfiles.size/128.0))  
AS decimal(4,2))) AS varchar(8)) + ' + '''' + '%' + '''' + ' AS FreeSpacePct,  
GETDATE() as PollDate FROM dbo.sysfiles'  
INSERT INTO @DBInfo  
   (ServerName,  
   DatabaseName,  
   FileSizeMB,
   MaxSize,  
   LogicalFileName,  
   PhysicalFileName,  
   Status,  
   Updateability,  
   RecoveryMode,  
   FreeSpaceMB,  
   FreeSpacePct,  
   PollDate)  
EXEC sp_MSforeachdb @command  


/*
-- 2nd script (stall wait information per data file)
SELECT DB_NAME(fs.database_id) AS [Database Name], mf.name as 'Logical File Name', CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms],
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.physical_name, mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 
fs.io_stall_write_ms, fs.num_of_writes, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io]
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_stall_ms DESC OPTION (RECOMPILE);

*/

--Select statement to combine the two.


SELECT 
@@SERVERNAME ServerName, @@SERVICENAME InstanceName,
DB_NAME(fs.database_id) AS [Database Name], mf.name as 'Logical File Name', DBInfo.RecoveryMode, CAST(fs.io_stall_read_ms/(1.0 + fs.num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms],
CAST(fs.io_stall_write_ms/(1.0 + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
CAST((fs.io_stall_read_ms + fs.io_stall_write_ms)/(1.0 + fs.num_of_reads + fs.num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms],
--CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], DBInfo.FreeSpaceMB, DBInfo.FreeSpacePct, mf.growth / 128 as autogrowMB, mf.is_percent_growth as 'autogrowAsPercentage_1Yes_0No', mf.physical_name , mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 
CONVERT(DECIMAL(18,2), mf.size/128.0) AS [File Size (MB)], mf.max_size AS [MaxSize], DBInfo.FreeSpaceMB, DBInfo.FreeSpacePct, mf.growth / 128 as autogrowMB, mf.is_percent_growth as 'autogrowAsPercentage_1Yes_0No', mf.physical_name , mf.type_desc, fs.io_stall_read_ms, fs.num_of_reads, 

fs.io_stall_write_ms, fs.num_of_writes, fs.io_stall_read_ms + fs.io_stall_write_ms AS [io_stalls], fs.num_of_reads + fs.num_of_writes AS [total_io]
FROM sys.dm_io_virtual_file_stats(null,null) AS fs
INNER JOIN sys.master_files AS mf WITH (NOLOCK)
ON fs.database_id = mf.database_id
AND fs.[file_id] = mf.[file_id]
LEFT JOIN @DBInfo AS DBInfo ON mf.physical_name = DBInfo.PhysicalFileName COLLATE DATABASE_DEFAULT
--ORDER BY avg_io_stall_ms DESC OPTION (RECOMPILE);
order by [Database Name], [Logical File Name]


