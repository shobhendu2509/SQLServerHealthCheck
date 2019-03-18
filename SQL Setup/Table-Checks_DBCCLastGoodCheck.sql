USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Checks_DBCCLastGoodCheck]    Script Date: 21/12/2018 10:42:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_DBCCLastGoodCheck](
	[ComputerName] [nvarchar](255) NULL,
	[InstanceName] [nvarchar](255) NULL,
	[SqlInstance] [nvarchar](255) NULL,
	[Database] [nvarchar](255) NULL,
	[DatabaseCreated] [datetime2](7) NULL,
	[LastGoodCheckDb] [datetime2](7) NULL,
	[DaysSinceDbCreated] [float] NULL,
	[DaysSinceLastGoodCheckDb] [int] NULL,
	[Status] [nvarchar](100) NULL,
	[DataPurityEnabled] [bit] NULL,
	[CreateVersion] [int] NULL,
	[DbccFlags] [int] NULL
) ON [PRIMARY]
GO


