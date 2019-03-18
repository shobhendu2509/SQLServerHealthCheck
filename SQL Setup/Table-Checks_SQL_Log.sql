USE [DBAdmin]
GO

/******  Creates the table that will host the latest SQL log information for each instance ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_SQL_Log](

[InstanceName] [nvarchar](255) NULL,
[LogDate] [datetime2](7) NULL,
[ProcessInfo] NVARCHAR(50),
[Text] NVARCHAR(MAX)

) ON [PRIMARY]
GO