USE [DBAdmin]

--INSERT INTO [DBAdmin].
--SELECT * FROM [DBAdmin_DEV].
--SELECT * FROM [DBAdmin_TEST].


INSERT INTO [DBAdmin].[dbo].[Checks_AgentJobs]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_AgentJobs]
INSERT INTO [DBAdmin].[dbo].[Checks_AgentJobs]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_AgentJobs]

INSERT INTO [DBAdmin].[dbo].[Checks_Database_Information]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_Database_Information]
INSERT INTO [DBAdmin].[dbo].[Checks_Database_Information]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_Database_Information]

INSERT INTO [DBAdmin].[dbo].[Checks_DataFiles]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_DataFiles]
INSERT INTO [DBAdmin].[dbo].[Checks_DataFiles]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_DataFiles]

INSERT INTO [DBAdmin].[dbo].[Checks_DBCCLastGoodCheck]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_DBCCLastGoodCheck]
INSERT INTO [DBAdmin].[dbo].[Checks_DBCCLastGoodCheck]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_DBCCLastGoodCheck]

INSERT INTO [DBAdmin].[dbo].[Checks_Instance_Information]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_Instance_Information]
INSERT INTO [DBAdmin].[dbo].[Checks_Instance_Information]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_Instance_Information]

INSERT INTO [DBAdmin].[dbo].[Checks_LocalAdministrators_members]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_LocalAdministrators_members]
INSERT INTO [DBAdmin].[dbo].[Checks_LocalAdministrators_members]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_LocalAdministrators_members]

INSERT INTO [DBAdmin].[dbo].[Checks_ServerDiskInformation]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_ServerDiskInformation]
INSERT INTO [DBAdmin].[dbo].[Checks_ServerDiskInformation]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_ServerDiskInformation]

INSERT INTO [DBAdmin].[dbo].[Checks_ServerRoleMembers]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_ServerRoleMembers]
INSERT INTO [DBAdmin].[dbo].[Checks_ServerRoleMembers]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_ServerRoleMembers]

INSERT INTO [DBAdmin].[dbo].[Checks_SQL_Log]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_SQL_Log]
INSERT INTO [DBAdmin].[dbo].[Checks_SQL_Log]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_SQL_Log]

INSERT INTO [DBAdmin].[dbo].[Checks_SQLServicesPolicyUserRights]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_SQLServicesPolicyUserRights]
INSERT INTO [DBAdmin].[dbo].[Checks_SQLServicesPolicyUserRights]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_SQLServicesPolicyUserRights]

INSERT INTO [DBAdmin].[dbo].[Checks_SQLServicesStatusWMI]
SELECT * FROM [DBAdmin_DEV].[dbo].[Checks_SQLServicesStatusWMI]
INSERT INTO [DBAdmin].[dbo].[Checks_SQLServicesStatusWMI]
SELECT * FROM [DBAdmin_TEST].[dbo].[Checks_SQLServicesStatusWMI]


