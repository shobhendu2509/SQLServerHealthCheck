USE [DBAdmin]
GO

--Checks if it already exists, if not it creates the procedure, if so it just alters it.
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_Checks_SQLLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_Checks_SQLLog] AS'
END
GO
ALTER PROCEDURE [dbo].[sp_Checks_SQLLog]

AS 

/*
	Purpose:	Use this stored procedure to return the filtered results from the SQL log.
				This helps weed out the noise based on what we have entered into the [Checks_SQLLog_ignoreText] table.
	
	Title:			INVENTORY - Database server information		
	Version			1.0
	Created by:		Tim Roberts
	Date Created:	2019-04-01

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2019-04-01	1.0		Initial Release.


IMPORTANT NOTES
===============
Create a stored procedure using this code.
Its a pre-requisite the [Checks_SQLLog_ignoreText] table has been created.

*/

-- Temporary table to hold all the results.
CREATE TABLE #tempTable ([Environment] NVARCHAR(255), [InstanceName] NVARCHAR(255), [LogDate] DATETIME, [ProcessInfo] nVarChar(50), [Text] nVarChar(max))


	/* Outer cursor for the server name and rows to bring back*/

	DECLARE @ServerName as nvarchar(255) 
	DECLARE ServerName CURSOR FOR 
		--Gets a list of SQL Instances currently active in the environment. This will be used in the inner cursor to get filtered data from the [Checks_SQL_Log] table.
			SELECT [SQL Instance Name]
			FROM [DBAdmin].[dbo].[SourceServerList]
			WHERE [SQL_Access] = 1 AND [ActiveStatus] = 1 AND [IsEnabled] = 1

	OPEN ServerName
	FETCH NEXT FROM ServerName INTO @ServerName

	WHILE @@FETCH_STATUS = 0   
	BEGIN 

	DECLARE @SQL2 as NVARCHAR(MAX) 
	SET @SQL2 = ''

		 /*Inner Cursor containing the text to ignore from the logs for each server*/
			DECLARE @IgnoreText as nvarchar(255) 
			DECLARE @SQLWhereStuff As NVARCHAR(MAX)

			--With the starting part needed for the WHERE clause string.
			SET @SQLWhereStuff = '[text] not like '''

			DECLARE IGNORETEXT CURSOR FOR 
				--Gets the rows for the cursor to run through for a specific server (provided by the outer cursor).
				SELECT [Text] FROM [DBAdmin].[dbo].[Checks_SQLLog_ignoreText] WHERE [InstanceName] = @ServerName AND [TextStatus] = 1

			OPEN IGNORETEXT

			FETCH NEXT FROM IGNORETEXT INTO @IgnoreText

				WHILE @@FETCH_STATUS = 0   
					BEGIN 

					 -- Builds up the WHERE clause string.
					 SET @SQLWhereStuff = + @SQLWhereStuff + @IgnoreText + ''' AND [text] not like '''
 
				FETCH NEXT FROM IGNORETEXT INTO @IgnoreText

			END

				-- @SQLWhereStuff with the end part needed for the string
				SET @SQLWhereStuff = + @SQLWhereStuff + ''''

			CLOSE IGNORETEXT;
			DEALLOCATE IGNORETEXT

			--Inserts the log entries for review into the temporary table
			SET @SQL2 = '
			INSERT INTO #tempTable ([Environment], [InstanceName], [LogDate], [ProcessInfo], [Text])
			SELECT 
					SS.Environment
					,[InstanceName]
				  ,[LogDate]
				  ,[ProcessInfo]
				  ,[Text]
			  FROM [DBAdmin].[dbo].[Checks_SQL_Log] CHKS
			  INNER join [dbo].[SourceServerList] SS on SS.[SQL Instance Name] = CHKS.[InstanceName]
			  WHERE CHKS.[InstanceName] = ''' + @ServerName + ''' AND ' + @SQLWhereStuff + ';'

			  EXEC (@SQL2)

	FETCH NEXT FROM ServerName INTO @ServerName
	END

	-- Returns all of the filtered results for review.
	SELECT * FROM #tempTable
	Order by [Environment], [InstanceName] ASC, [LogDate] ASC

	CLOSE ServerName;
	DEALLOCATE ServerName

	DROP TABLE #tempTable

	GO