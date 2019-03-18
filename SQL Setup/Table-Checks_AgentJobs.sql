USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_AgentJobs_Inventory_Staging]    Script Date: 21/12/2018 10:30:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_AgentJobs](
	[ServerName] [nvarchar](255) NULL,
	[InstanceName] [nvarchar](255) NULL,
	[OwnerName] [nvarchar](255) NULL,
	[name] [nvarchar](500) NULL,
	[description] [nvarchar](1000) NULL,
	[enabled] [tinyint] NULL,
	[run_status] INT NULL,
	[OperatorName] [nvarchar](255) NULL,
	[date_created] [datetime2](7) NULL,
	[date_modified] [datetime2](7) NULL,
	[job_id] [uniqueidentifier] NULL,
	[LastRun] [datetime2](7) NULL,
	[NextRun] [datetime2](7) NULL
) ON [PRIMARY]
GO


