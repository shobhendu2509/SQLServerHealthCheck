USE [DBAdmin]
GO

/****** Used to list out all of the servers you will be monitoring using the check scripts ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SourceServerList](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[SQL Instance Name] [nvarchar](255) NULL,
	[MachineName] [nvarchar](255) NULL,
	[Environment] [nvarchar](255) NULL,
	[Domain] [nvarchar](255) NULL,
	[RDP_Access] [int] NULL,
	[SQL_Access] [int] NULL,
	[ServerDescr] [varchar](4000) NULL,
	[ServerIP] [varchar](20) NULL,
	[OSType] [varchar](50) NULL,
	[OSVersion] [varchar](100) NULL,
	[SQLVersion] [nvarchar](255) NULL,
	[IsFCI_clustered] [bit] NULL,
	[AG_configured] [int] NULL,
	[ActiveStatus] [int] NULL,
	[IsEnabled] [bit] NULL,
	[UAC_enabled] [int] NULL,
	[BackupLocation] [nvarchar](256) NULL,
	[BackupMethod] [nvarchar](20) NULL,
	[comments] [nvarchar](255) NULL,
	[decom_change_ref] [nvarchar](255) NULL
) ON [PRIMARY]
GO


