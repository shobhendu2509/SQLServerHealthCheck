USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Checks_DataFiles]    Script Date: 28/02/2019 1:19:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_DataFiles](
	[ServerName] [nvarchar](255) NULL,
	[InstanceName] [nvarchar](255) NULL,
	[Database Name] [nvarchar](255) NULL,
	[Logical File Name] [nvarchar](255) NULL,
	[RecoveryMode] [nvarchar](50) NULL,
	[avg_read_stall_ms] [decimal](38, 5) NULL,
	[avg_write_stall_ms] [decimal](38, 5) NULL,
	[avg_io_stall_ms] [decimal](38, 5) NULL,
	[File Size (MB)] [decimal](38, 5) NULL,
	[MaxSize] [int] NULL,
	[FreeSpaceMB] [int] NULL,
	[FreeSpacePct] [nvarchar](50) NULL,
	[autogrowMB] [int] NULL,
	[autogrowAsPercentage_1Yes_0No] [bit] NULL,
	[physical_name] [nvarchar](1000) NULL,
	[type_desc] [nvarchar](50) NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[io_stalls] [bigint] NULL,
	[total_io] [bigint] NULL
) ON [PRIMARY]
GO