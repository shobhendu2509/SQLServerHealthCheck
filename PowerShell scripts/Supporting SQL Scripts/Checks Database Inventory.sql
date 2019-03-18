/***********************************************************************************

	Version 3.0
	Created by:		Tim Roberts
	Date Created:	2017-06-26
	
	Title:			BaselineStatistics version of Reports all databases on an instance, ready to copy into an inventory spreadhseet.
	Pre-Reqs:		Configuration of the Baseline Statistics database.

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR		2015-10-12  1.0		Initial release to help with SQL Consolidation project.
	TR		2016-02-11  2.0		Doesnt depend on the BaselineStatistics database. Problematic as some nights the job to capture data file sizes doesnt run for some or all DB's. This means the results below are not accurate.
	TR		2016-02-22	2.1		Added Log shipping secondary Server name. Shows the secondary server name for any databases that are log shipped.
	TR		2016-03-01	2.2		Added database creation date.
	TR		2016-03-10  2.3		Added the size of last full backup. This was needed at UGL to help decide the amount of backup storage required for databases.
	TR		2016-03-24	2.4		Added last accessed information. Depends on BaselineStatistics module installed by Pebble IT.
	TR		2016-06-28	2.5		Removed BaselineStatistics components so can be run on any SQL Server.
	TR		2016-07-01	2.6		Custom script for Water NSW.
	TR		2016-07-21	2.7		Added last dates and times of backups for differential and transaction log backups. Did not include the sizes, only recording size of the full backups.
	TR		2017-06-22	2.8		Added Servername and instancename
	TR		2017-06-26	3.0		Adapted to provided data for Availabilitry Groups and added details for mirrored databases.
	TR		2017-10-10	3.1		Added differential backup size information as is helpful when calculating total backup storage needs.


Sources
========

AG Data
--------
https://www.mssqltips.com/sqlservertip/3206/finding-primary-replicas-for-sql-server-2012-alwayson-availability-groups-with-powershell/
https://www.pythian.com/blog/list-of-sql-server-databases-in-an-availability-group/


***********************************************************************************/

--This block of code captures the most recent backups during the past 7 days.
DECLARE @ver nvarchar(128)
SET @ver = CAST(serverproperty('ProductVersion') AS nvarchar)
SET @ver = SUBSTRING(@ver, 1, CHARINDEX('.', @ver) - 1)

--select @ver

IF @ver >= 11
	/***********************************************************************************
	  Covers versions abover SQL 2012 that may have availability groups configured
	***********************************************************************************/
	BEGIN
	;with backup_cte as

	 (SELECT 
	   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,
	   msdb.dbo.backupset.database_name, 
	   msdb.dbo.backupset.backup_start_date, 
	   msdb.dbo.backupset.backup_finish_date,
	   msdb.dbo.backupset.expiration_date,
	   CASE msdb..backupset.type 
		   WHEN 'D' THEN 'FULL' 
		   WHEN 'I' THEN 'Differential'
		   WHEN 'L' THEN 'Log' 
	   END AS backup_type, 
	   msdb.dbo.backupset.backup_size,
	   msdb.dbo.backupset.compressed_backup_size,
	   msdb.dbo.backupmediafamily.logical_device_name, 
	   msdb.dbo.backupmediafamily.physical_device_name,  
	   msdb.dbo.backupset.name AS backupset_name,
	   msdb.dbo.backupset.description,

	   rownum = row_number() over
				(
					partition by database_name, type 
					order by backup_finish_date desc
				)
		FROM   msdb.dbo.backupmediafamily 
		   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
		WHERE  (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7 )

	   )

	   		--This block presents the data for the inventory. You can change the backup type you wish to get size information for. In this case we pull back the FULL backup information.
			SELECT
			@@SERVERNAME ServerName, @@SERVICENAME InstanceName, 
			SERVERPROPERTY('ProductVersion') as 'SQL Server Version', SERVERPROPERTY('Edition') as 'SQL Edition',  SERVERPROPERTY('Collation') as 'SERVER Collation',
			 DB_NAME(db.database_id) DatabaseName, 
	 
			 --AG code block
			 ISNULL(AGINfo.AG_Role, 'NA') AS [AG Role],
			 ISNULL(AGINfo.AvailabilityGroupName, 'NA') AS [AG Group Name],
	 
			--Mirror info code block
			ISNULL(MirrorDBInfo.mirroring_state_desc, 'NA') AS [Mirror State],
			ISNULL(MirrorDBInfo.mirroring_role_desc, 'NA') AS [Mirror Role],
			ISNULL(MirrorDBInfo.mirroring_safety_level_desc, 'NA') AS [Mirror Safety level],
			ISNULL(MirrorDBInfo.mirroring_partner_name, 'NA') AS [Mirror Partner],

			 getdate() InventoryDate, create_date, db.collation_name, db.state_desc, 
			-- LastAccess.MostRecentAccess,
			 compatibility_level, suser_sname(owner_sid) DBOwner, recovery_model_desc, db.is_auto_shrink_on, db.is_auto_close_on, is_auto_create_stats_on, is_auto_update_stats_on, 
			(CAST(mfrows.RowSize AS FLOAT)*8)/1024 RowSizeMB,
			(CAST(mflog.LogSize AS FLOAT)*8)/1024 LogSizeMB,
			(CAST(mfstream.StreamSize AS FLOAT)*8)/1024 StreamSizeMB,
			(CAST(mftext.TextIndexSize AS FLOAT)*8)/1024 TextIndexSizeMB,
			BUINFO.[Full Uncompressed Backup Size (MB)],
			BUINFO.[Full Compressed Backup Size (MB)],
			BUDiffINFO.[Differential Compressed Backup Size (MB)],
			BUDiffINFO.[Differential Uncompressed Backup Size (MB)],
			BUINFO.backup_finish_date as 'Last FULL Backup Date',
			BUDiffINFO.backup_finish_date as 'Last Differential Backup Date',
			BULogINFO.backup_finish_date as 'Last Tlog Backup Date',
			ISNULL(LShip.secondary_server, 'Not Configured') AS 'Log ship Server'
	
		FROM sys.databases db
			LEFT JOIN (SELECT database_id, SUM(size) RowSize FROM sys.master_files WHERE type = 0 GROUP BY database_id, type) mfrows ON mfrows.database_id = db.database_id
			LEFT JOIN (SELECT database_id, SUM(size) LogSize FROM sys.master_files WHERE type = 1 GROUP BY database_id, type) mflog ON mflog.database_id = db.database_id
			LEFT JOIN (SELECT database_id, SUM(size) StreamSize FROM sys.master_files WHERE type = 2 GROUP BY database_id, type) mfstream ON mfstream.database_id = db.database_id
			LEFT JOIN (SELECT database_id, SUM(size) TextIndexSize FROM sys.master_files WHERE type = 4 GROUP BY database_id, type) mftext ON mftext.database_id = db.database_id
			LEFT JOIN (SELECT secondary_server, secondary_database from [msdb].[dbo].[log_shipping_primary_secondaries]) LShip ON LShip.secondary_database = db.name
			

			--Join to provide the last FULL backup information
			LEFT JOIN (
			select
			compressed_backup_size/1024000 as 'Full Compressed Backup Size (MB)', --Comment this out for SQL 2005 servers as Compressed backups not supported.
			backup_size/1024000 as 'Full Uncompressed Backup Size (MB)',
			rownum,
			database_name,
			backup_finish_date,
			backup_type
			from backup_cte
			where 
			rownum = 1 and backup_type = 'FULL' 
			and database_name not in ('master', 'model', 'msdb', 'tempdb')
			--order by database_name, backup_finish_date desc
			) BUINFO ON BUINFO.database_name = db.name


			--Join to provide the last Differential backup information
			LEFT JOIN (
			select
			compressed_backup_size/1024000 as 'Differential Compressed Backup Size (MB)', --Comment this out for SQL 2005 servers as Compressed backups not supported.
			backup_size/1024000 as 'Differential Uncompressed Backup Size (MB)',
			rownum,
			database_name,
			backup_finish_date,
			backup_type
			from backup_cte
			where 
			rownum = 1 and backup_type = 'Differential' 
			and database_name not in ('master', 'model', 'msdb', 'tempdb')
			--order by database_name, backup_finish_date desc
			) BUDiffINFO ON BUDiffINFO.database_name = db.name


			--Join to provide the last Transaction log backup information
			LEFT JOIN (
			select
			compressed_backup_size/1024000 as 'Compressed Backup Size (MB)', --Comment this out for SQL 2005 servers as Compressed backups not supported.
			backup_size/1024000 as 'Uncompressed Backup Size (MB)',
			rownum,
			database_name,
			backup_finish_date,
			backup_type
			from backup_cte
			where 
			rownum = 1 and backup_type = 'Log' 
			and database_name not in ('master', 'model', 'msdb', 'tempdb')
			--order by database_name, backup_finish_date desc
			) BULogINFO ON BULogINFO.database_name = db.name


				--Join to provide Availability Group information
	
			LEFT JOIN (
	
	
				SELECT
					AG.name AS [AvailabilityGroupName],
					ISNULL(agstates.primary_replica, '') AS [PrimaryReplicaServerName],
					ISNULL(arstates.role, 3) AS [LocalReplicaRole],
					ISNULL(arstates.role_desc, '') AS [AG_Role],
					dbcs.database_name AS [DatabaseName],
					ISNULL(dbrs.synchronization_state, 0) AS [SynchronizationState],
					ISNULL(dbrs.is_suspended, 0) AS [IsSuspended],
					ISNULL(dbcs.is_database_joined, 0) AS [IsJoined]
					FROM master.sys.availability_groups AS AG
					LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states as agstates
					   ON AG.group_id = agstates.group_id
					INNER JOIN master.sys.availability_replicas AS AR
					   ON AG.group_id = AR.group_id
					INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
					   ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
					INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs
					   ON arstates.replica_id = dbcs.replica_id
					LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbrs
					   ON dbcs.replica_id = dbrs.replica_id AND dbcs.group_database_id = dbrs.group_database_id
					--ORDER BY AG.name ASC, dbcs.database_name
			)	 
				AGInfo ON AGInfo.DatabaseName = db.name
	
			-- Information for all mirrored databases
			LEFT JOIN
			(
			SELECT DB_NAME([database_id]) as 'DatabaseName', [database_id], [mirroring_state], [mirroring_state_desc], [mirroring_role], [mirroring_role_desc], [mirroring_safety_level], [mirroring_safety_level_desc], [mirroring_partner_name], [mirroring_partner_instance], [mirroring_witness_name], [mirroring_witness_state] from sys.database_mirroring
			)
			MirrorDBInfo ON MirrorDBInfo.database_id = db.database_id

			where  DB_NAME(db.database_id) not in ('master', 'model', 'msdb', 'tempdb')
			order by  DB_NAME(db.database_id);
	END
	
	ELSE
			BEGIN

		/***********************************************************************************
			Covers versions below SQL 2012
		***********************************************************************************/

		--This block of code captures the most recent backups during the past 7 days.
		;with backup_cte as

		 (SELECT 
		   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,
		   msdb.dbo.backupset.database_name, 
		   msdb.dbo.backupset.backup_start_date, 
		   msdb.dbo.backupset.backup_finish_date,
		   msdb.dbo.backupset.expiration_date,
		   CASE msdb..backupset.type 
			   WHEN 'D' THEN 'FULL' 
			   WHEN 'I' THEN 'Differential'
			   WHEN 'L' THEN 'Log' 
		   END AS backup_type, 
		   msdb.dbo.backupset.backup_size,
		   msdb.dbo.backupset.compressed_backup_size,
		   msdb.dbo.backupmediafamily.logical_device_name, 
		   msdb.dbo.backupmediafamily.physical_device_name,  
		   msdb.dbo.backupset.name AS backupset_name,
		   msdb.dbo.backupset.description,

		   rownum = row_number() over
					(
						partition by database_name, type 
						order by backup_finish_date desc
					)
			FROM   msdb.dbo.backupmediafamily 
			   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
			WHERE  (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7 )

		   )

		   --This block presents the data for the inventory. You can change the backup type you wish to get size information for. In this case we pull back the FULL backup information.
			SELECT
			@@SERVERNAME ServerName, @@SERVICENAME InstanceName, 
			SERVERPROPERTY('ProductVersion') as 'SQL Server Version', SERVERPROPERTY('Edition') as 'SQL Edition',  SERVERPROPERTY('Collation') as 'SERVER Collation',
			 DB_NAME(db.database_id) DatabaseName, 
			 
			  --AG code block (Blank entries)
			 'NA' AS [AG Role],
			 'NA' AS [AG Group Name],
			 
			 --Mirror info code block
			ISNULL(MirrorDBInfo.mirroring_state_desc, 'NA') AS [Mirror State],
			ISNULL(MirrorDBInfo.mirroring_role_desc, 'NA') AS [Mirror Role],
			ISNULL(MirrorDBInfo.mirroring_safety_level_desc, 'NA') AS [Mirror Safety level],
			ISNULL(MirrorDBInfo.mirroring_partner_name, 'NA') AS [Mirror Partner],



			 getdate() InventoryDate, create_date, db.collation_name, db.state_desc, 
			-- LastAccess.MostRecentAccess,
			 compatibility_level, suser_sname(owner_sid) DBOwner, recovery_model_desc, db.is_auto_shrink_on, db.is_auto_close_on, is_auto_create_stats_on, is_auto_update_stats_on, 
			(CAST(mfrows.RowSize AS FLOAT)*8)/1024 RowSizeMB,
			(CAST(mflog.LogSize AS FLOAT)*8)/1024 LogSizeMB,
			(CAST(mfstream.StreamSize AS FLOAT)*8)/1024 StreamSizeMB,
			(CAST(mftext.TextIndexSize AS FLOAT)*8)/1024 TextIndexSizeMB,
			BUINFO.[Full Uncompressed Backup Size (MB)],
			BUINFO.[Full Compressed Backup Size (MB)],
			BUDiffINFO.[Differential Compressed Backup Size (MB)],
			BUDiffINFO.[Differential Uncompressed Backup Size (MB)],
			BUINFO.backup_finish_date as 'Last FULL Backup Date',
			BUDiffINFO.backup_finish_date as 'Last Differential Backup Date',
			BULogINFO.backup_finish_date as 'Last Tlog Backup Date',
			ISNULL(LShip.secondary_server, 'Not Configured') AS 'Log ship Server'
	
		FROM sys.databases db
			LEFT JOIN (SELECT database_id, SUM(size) RowSize FROM sys.master_files WHERE type = 0 GROUP BY database_id, type) mfrows ON mfrows.database_id = db.database_id
			LEFT JOIN (SELECT database_id, SUM(size) LogSize FROM sys.master_files WHERE type = 1 GROUP BY database_id, type) mflog ON mflog.database_id = db.database_id
			LEFT JOIN (SELECT database_id, SUM(size) StreamSize FROM sys.master_files WHERE type = 2 GROUP BY database_id, type) mfstream ON mfstream.database_id = db.database_id
			LEFT JOIN (SELECT database_id, SUM(size) TextIndexSize FROM sys.master_files WHERE type = 4 GROUP BY database_id, type) mftext ON mftext.database_id = db.database_id
			LEFT JOIN (SELECT secondary_server, secondary_database from [msdb].[dbo].[log_shipping_primary_secondaries]) LShip ON LShip.secondary_database = db.name
						
			--Join to provide the last FULL backup information
			LEFT JOIN (
			select
			compressed_backup_size/1024000 as 'Full Compressed Backup Size (MB)', --Comment this out for SQL 2005 servers as Compressed backups not supported.
			backup_size/1024000 as 'Full Uncompressed Backup Size (MB)',
			rownum,
			database_name,
			backup_finish_date,
			backup_type
			from backup_cte
			where 
			rownum = 1 and backup_type = 'FULL' 
			and database_name not in ('master', 'model', 'msdb', 'tempdb')
			--order by database_name, backup_finish_date desc
			) BUINFO ON BUINFO.database_name = db.name


			--Join to provide the last Differential backup information
			LEFT JOIN (
			select
			compressed_backup_size/1024000 as 'Differential Compressed Backup Size (MB)', --Comment this out for SQL 2005 servers as Compressed backups not supported.
			backup_size/1024000 as 'Differential Uncompressed Backup Size (MB)',
			rownum,
			database_name,
			backup_finish_date,
			backup_type
			from backup_cte
			where 
			rownum = 1 and backup_type = 'Differential' 
			and database_name not in ('master', 'model', 'msdb', 'tempdb')
			--order by database_name, backup_finish_date desc
			) BUDiffINFO ON BUDiffINFO.database_name = db.name


			--Join to provide the last Transaction log backup information
			LEFT JOIN (
			select
			compressed_backup_size/1024000 as 'Compressed Backup Size (MB)', --Comment this out for SQL 2005 servers as Compressed backups not supported.
			backup_size/1024000 as 'Uncompressed Backup Size (MB)',
			rownum,
			database_name,
			backup_finish_date,
			backup_type
			from backup_cte
			where 
			rownum = 1 and backup_type = 'Log' 
			and database_name not in ('master', 'model', 'msdb', 'tempdb')
			--order by database_name, backup_finish_date desc
			) BULogINFO ON BULogINFO.database_name = db.name

			-- Information for all mirrored databases
			LEFT JOIN
			(
			SELECT DB_NAME([database_id]) as 'DatabaseName', [database_id], [mirroring_state], [mirroring_state_desc], [mirroring_role], [mirroring_role_desc], [mirroring_safety_level], [mirroring_safety_level_desc], [mirroring_partner_name], [mirroring_partner_instance], [mirroring_witness_name], [mirroring_witness_state] from sys.database_mirroring
			)
			MirrorDBInfo ON MirrorDBInfo.database_id = db.database_id

			where  DB_NAME(db.database_id) not in ('master', 'model', 'msdb', 'tempdb')
			order by  DB_NAME(db.database_id)
		
END