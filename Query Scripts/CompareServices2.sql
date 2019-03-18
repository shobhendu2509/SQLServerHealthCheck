/*
Purpose:	Pivots the [MachineName] and service [Name] against the [Status] for each of the [DateCaptured] values. 
			Use this to compare the service status after changes, for example server reboots.
				
	Version			1.0
	Created by:		Tim Roberts
	Date Created:	2018-10-02

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2018-10-02	1.0		Initial Release.

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


DECLARE 
	@cols AS NVARCHAR(MAX),
    @colsNoNulls AS NVARCHAR(MAX),
	@query  AS NVARCHAR(MAX)

select @cols = STUFF((SELECT ',' + QUOTENAME([DateCaptured]) 
					  FROM [DBAdmin].[dbo].[SQLServicesStatus]
					  group by [DateCaptured]
					  order by [DateCaptured]
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')


-- The print allow to help with debugging.
 --print @cols

select @colsNoNulls = STUFF(
	( SELECT ', ISNULL(' + QUOTENAME([DateCaptured]) + ', ''0'') ' + 'AS ' + QUOTENAME([DateCaptured])
				FROM [DBAdmin].[dbo].[SQLServicesStatus]
			  group by [DateCaptured]
			  order by [DateCaptured]
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

-- The print allow to help with debugging.
--print @colsNoNulls

set @query = '
WITH P as (

SELECT [MachineName], [Name],' + @cols + '  from 
             (
                 SELECT 
				  [MachineName],
				  [Name]
				  ,[Status]
				  ,[DateCaptured]
			  FROM [DBAdmin].[dbo].[SQLServicesStatus] 
				  
            ) src
            pivot 
            (
                max(Status)
                for [DateCaptured] in (' + @cols + ')
            ) piv 
			
			)
		select [MachineName], [Name], ' + @colsNoNulls + '
		from P
		order by [MachineName], [Name];
			'
--print @query
execute(@query);
