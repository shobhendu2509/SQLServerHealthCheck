/*
Purpose:	Pivots the [MachineName] and service [Name] against the [Status] for each of the [DateCaptured] values. 
			Use this to compare the service status after changes, for example server reboots.

*************************************************************
NOTE: YOU NEED TO MANUALY ENTER THE DATE AND TIME YOU WANT TO START CHECKING FROM.
SEE LINE 71 (ish) in code below.
*************************************************************
				
	Version			1.0
	Created by:		Tim Roberts
	Date Created:	2018-10-02

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2018-10-02	1.0		Initial Release.
	TR			2018-10-02	1.1		Added the date captured from where clause, use this to limit the results.

NOTES: Depends on the DBAdmin database being installed.

I did look at adding the environment for each machine into the results. Unfortunatley WaterNSW have some servers that run both Production and UAT workloads.
Because of this, its too complicted to try to pick things apart as its not obvious, at least to a computer, which service relates to which environment.

This shows the server
  select * from [DBAdmin].[dbo].[SourceServerList]
  where machinename like 'CMDBS'


If you want something to help figure out what links to what, you can use the join in the statement below
         SELECT 
				  a.[MachineName],
				  b.[Environment],
				  a.[Name]
				  ,a.[Status]
				  ,a.[DateCaptured]
		  FROM [DBAdmin].[dbo].[SQLServicesStatus] a
		
		  	Inner join 
			
			(
			SELECT  distinct[MachineName], [Environment]
  FROM [DBAdmin].[dbo].[SourceServerList]
  where MachineName is not null
  ) b			
			 on b.[MachineName] = a.[MachineName]
			order by a.MachineName, a.name, a.DateCaptured


*/


/*
SELECT [MachineName]
      ,[name]
      ,[DisplayName]
      ,[state]
      ,[startmode]
      ,[startname]
      ,[DateCaptured]
  FROM [DBAdmin].[dbo].[SQLServicesStatusWMI]
*/

DECLARE 
	@cols AS NVARCHAR(MAX),
    @colsNoNulls AS NVARCHAR(MAX),
	@query  AS NVARCHAR(MAX),
	@DateFrom as NVARCHAR(MAX)

--Date to run check from 
SET @DateFrom = '2018-09-28 00:00:01.7479728'


select @cols = STUFF((SELECT ',' + QUOTENAME([DateCaptured]) 
					  FROM [DBAdmin].[dbo].[Checks_SQLServicesStatusWMI]
					  WHERE [DateCaptured] >= @DateFrom 
					  group by [DateCaptured]
					  order by [DateCaptured]
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')


-- The print allow to help with debugging.
 --print @cols

select @colsNoNulls = STUFF(
	( SELECT ', ISNULL(' + QUOTENAME([DateCaptured]) + ', ''0'') ' + 'AS ' + QUOTENAME([DateCaptured])
				FROM [DBAdmin].[dbo].[Checks_SQLServicesStatusWMI]
				WHERE [DateCaptured] >= @DateFrom 
			  group by [DateCaptured]
			  order by [DateCaptured]
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

-- The print allow to help with debugging.
--print @colsNoNulls

set @query = '
WITH P as (

SELECT [MachineName], [name],' + @cols + '  from 
             (
                 SELECT 
				  [MachineName],
				  [name]
				  ,[State]
				  ,[DateCaptured]
			  FROM [DBAdmin].[dbo].[Checks_SQLServicesStatusWMI] 
			  WHERE [DateCaptured] >= ''' + @DateFrom + '''
				  
            ) src
            pivot 
            (
                max(State)
                for [DateCaptured] in (' + @cols + ')
            ) piv 
			
			)
		select [MachineName], [name], ' + @colsNoNulls + '
		from P
		order by [MachineName], [name];
			'
--print @query
execute(@query);
