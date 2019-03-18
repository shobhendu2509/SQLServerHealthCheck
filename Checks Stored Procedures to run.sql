/* Checks stored procedures */

/****
Output
	INSTANCE NAME
	ENVIRONMENT
	SQL VERSION
	UP SINCE

Look for
==========
	1.	Instances that havent been patched recently. Use this site to see the latest patches: https://sqlserverbuilds.blogspot.com/
		All instances should be patched to within 3 months of the most recent CU, Service pack or security update.
	2.  Any instnaces that have not been up for at least 1 week. Check to see if the restart was intended, if you dont know otherwise check the server system logs for errors.
		Some servers restart automatically as part of the windows update. Most customer disable this, but some do not.
******/

EXEC [DBAdmin].[dbo].[sp_Instance_Information]



/****
Output
	DISK FREE in Percent.

If no results are shown all disks have more disk free than that specified in the @PercentFree  parameter

Parameter you can change
========================
Change the value for the @PercentFree parameter to show any disks with a percentage free lowere than that value. 
The default is 100, the execute command below is set to 25, change this to 50 if for example you want to see any drives with less than 50% disk free.

Look for
==========
	1.	Any disks with less than 20% free. Suggest the customer increases above 20%.
	2.  Any disks with less than 10% free. Raise a ticket with the customer Service desk asking for enough storage to take about 20% free.
	3.  Any disk with less than 5% free. Escalate to the customer manager and recommend immedate expansion of the disk to about 10% free.   
******/

EXEC [DBAdmin].[dbo].[sp_Disk_Free] @PercentFree = 25



/****
Output
	AGENT JOBS - Most recent historical informaiton for agent jobs, including the most recent failures. 
	
Look for
==========
	1.	Any job with a run_status of 0 (Failed), if so look at the row above and see if the same job ran more recently with a run status of 1 (Success)
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

EXEC [DBAdmin].[dbo].[sp_Agent_jobs]


/****
Output
	BACKUPS

Backup Schedule
===============
	1. Databases should have...
		a. FULL backup on a Sunday and Wednesday night.
		b. DIFFERENTIAL backup every other night.
		c. Transaction log backup every hour (assuming database is in FULL recovery model).
		
		Any database without a Differential backup within 24 hours, should have a full backup with 24 hours.

Look for
==========
	1.  Any database with no FULL backup within 4 days and no differential backup within 24 hours. 
		If the database hasnt been backed up within 7 days, check to see if its part of an AG. 
			If so, check the other syncronous replicas. They may have run the backup, by default we configure the PRIMARY to run backups as SECONDARY's can technical auto switch to ASYNC. 
			It might also be the DB was recently failed over to the current replica and the backup ran on another server that was the primary. 

	2.	Any database in FULL recovery mode that hasnt got a transaction log backup within 1 hour of when the master script was run (6am).
		All transaction log backups should be within 1 hour of 5am or thereabouts for databases in full recovery model.
******/

EXEC [DBAdmin].[dbo].[sp_Backups_Last]



/****
Output
	DBCC information (Database Integrity Checks)

Look for
==========
	1.	Any database with a status other than OK.
	2.  Any database with that has not been checked in more than 7 days.
******/

EXEC [DBAdmin].[dbo].[sp_DBCC_Last]



/****
Output
	DBCC information (Database Integrity Checks)

Look for
==========
	1.	Anything unusual in the logs for the servers. If you regularly find the same issues and they are nothing to worry about, you can add them to the exclusion list in the table [dbo].[Checks_SQLLog_ignoreText]
******/

EXEC [DBAdmin].[dbo].[sp_Checks_SQLLog]