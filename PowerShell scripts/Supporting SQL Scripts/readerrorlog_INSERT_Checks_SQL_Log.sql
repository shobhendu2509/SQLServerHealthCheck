/**************************************************************************************************************
	Purpose:	Captures the SQL log and imports into a table for analysis.
				
	Version			1.1
	Created by:		Tim Roberts
	Date Created:	2019-04-08

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2019-04-08	1.0		Initial Release.

NOTES:
Adapted from: https://www.mssqltips.com/sqlservertip/1476/reading-the-sql-server-log-files-using-tsql/

This procedure takes four parameters:
	1.Value of error log file you want to read: 0 = current, 1 = Archive #1, 2 = Archive #2, etc...
	2.Log file type: 1 or NULL = error log, 2 = SQL Agent log 
	3.Search string 1: String one you want to search for 
	4.Search string 2: String two you want to search for to further refine the results

Can insert values into a temp table then query it: http://blog.sqlauthority.com/2009/09/23/sql-server-insert-values-of-stored-procedure-in-table-use-table-valued-function/
*/

--exec sp_readerrorlog 0, 1--, 'login'

/*Create TempTable */
CREATE TABLE #tempTable ([LogDate] DATETIME, [ProcessInfo] nVarChar(50), [Text] nVarChar(max));

/* Run SP and Insert Value in TempTable */
INSERT INTO #tempTable ([LogDate], [ProcessInfo], [Text])
EXEC sp_readerrorlog 0, 1;

/* SELECT from TempTable */
SELECT @@SERVERNAME as 'InstanceName', *
FROM #tempTable

Order by LogDate

/* Clean up */
DROP TABLE #tempTable;