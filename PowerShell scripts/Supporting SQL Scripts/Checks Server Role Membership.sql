/**************************************************************************************************************
	Purpose:	Fixed Server role membership - including SYSADMIN
				
	Version			1.0
	Created by:		Tim Roberts
	Date Created:	2018-10-26

	Changes:
	Author		Date		Ver		Notes
	--------------------------------------------------------------------------------------
	TR			2018-10-26	1.0		Initial Release.


NOTES:
Use this to get a full list of members to the Fixed server roles on a server. Great for initial inventory capturing.

***************************************************************************************************************/



USE master
GO

SELECT  p.name AS [loginname] ,
        p.type ,
        p.type_desc ,
        p.is_disabled,
        s.sysadmin, S.securityadmin, S.serveradmin, S.setupadmin, S.processadmin, S.diskadmin, S.dbcreator, S.bulkadmin,
		p.create_date,
		p.modify_date

FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP') and loginname not in ('NT Service\MSSQLSERVER', 'NT SERVICE\SQLSERVERAGENT', 'NT SERVICE\SQLWriter', 'NT SERVICE\Winmgmt', 'distributor_admin')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%';