USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_Database_Inventory_Staging]    Script Date: 21/12/2018 10:40:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_Database_Information](
	[ServerName] [nvarchar](255) NULL,
	[InstanceName] [nvarchar](255) NULL,
	[SQL Server Version] [nvarchar](50) NULL,
	[SQL Edition] [nvarchar](255) NULL,
	[SERVER Collation] [nvarchar](255) NULL,
	[DatabaseName] [nvarchar](255) NULL,
	[AG Role] [nvarchar](50) NULL,
	[AG Group Name] [nvarchar](50) NULL,
	[Mirror State] [nvarchar](50) NULL,
	[Mirror Role] [nvarchar](50) NULL,
	[Mirror Safety level] [nvarchar](50) NULL,
	[Mirror Partner] [nvarchar](255) NULL,
	[InventoryDate] [datetime2](7) NULL,
	[create_date] [datetime2](7) NULL,
	[collation_name] [nvarchar](255) NULL,
	[state_desc] [nvarchar](50) NULL,
	[compatibility_level] [tinyint] NULL,
	[DBOwner] [nvarchar](255) NULL,
	[recovery_model_desc] [nvarchar](50) NULL,
	[is_auto_shrink_on] [bit] NULL,
	[is_auto_close_on] [bit] NULL,
	[is_auto_create_stats_on] [bit] NULL,
	[is_auto_update_stats_on] [bit] NULL,
	[RowSizeMB] [float] NULL,
	[LogSizeMB] [float] NULL,
	[StreamSizeMB] [float] NULL,
	[TextIndexSizeMB] [float] NULL,
	[Full Uncompressed Backup Size (MB)] [decimal](38, 5) NULL,
	[Full Compressed Backup Size (MB)] [decimal](38, 5) NULL,
	[Differential Compressed Backup Size (MB)] [decimal](38, 5) NULL,
	[Differential Uncompressed Backup Size (MB)] [decimal](38, 5) NULL,
	[Last FULL Backup Date] [datetime2](7) NULL,
	[Last Differential Backup Date] [datetime2](7) NULL,
	[Last Tlog Backup Date] [datetime2](7) NULL,
	[Log ship Server] [nvarchar](50) NULL
) ON [PRIMARY]
GO


