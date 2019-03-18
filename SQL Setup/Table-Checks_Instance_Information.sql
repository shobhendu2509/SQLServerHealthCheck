USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_Instance_Inventory_Staging]    Script Date: 21/12/2018 10:37:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_Instance_Information](
	[ServerName] [nvarchar](255) NULL,
	[MachineName] [nvarchar](255) NULL,
	[InstanceName] [nvarchar](255) NULL,
	[IsFCI_clustered] [int] NULL,
	[AG_configured] [int] NULL,
	[sqlserver_start_time] [datetime2](7) NULL,
	[Server Collation] [nvarchar](255) NULL,
	[Edition] [nvarchar](255) NULL,
	[ProductLevel] [nvarchar](50) NULL,
	[SQLProductVersion] [nvarchar](50) NULL,
	[SQLEngineEdition] [int] NULL,
	[OS Version] [nvarchar](50) NULL,
	[cpu_count] [int] NULL,
	[Memory (MB)] [int] NULL,
	[show_advanced_options] [int] NULL,
	[minMem] [int] NULL,
	[maxMem] [int] NULL,
	[maxDOP] [int] NULL,
	[CostParallel] [int] NULL,
	[Filestream] [int] NULL,
	[ContainDBauthentication] [int] NULL,
	[OLEAutomatedProcs] [int] NULL,
	[xp_cmdshell] [int] NULL,
	[Agent_XPs] [int] NULL,
	[c2AuditOn] [int] NULL,
	[CPU_priority_boost_ON] [int] NULL,
	[DBMail] [int] NULL,
	[Integrated Security Only 1 = Integrated Only, 0 = Integrated and SQL Security] [int] NULL,
	[IsSingleUser] [int] NULL,
	[IsFullTextInstalled] [int] NULL,
	[DAC_enabled] [int] NULL,
	[Default_DATA_Files] [nvarchar](1000) NULL,
	[Default_TLOG_Files] [nvarchar](1000) NULL,
	[TEMPDB_MultipleDataFiles] [nvarchar](10) NULL,
	[TEMPDB_EqualSize] [nvarchar](10) NULL,
	[TEMP_DB_EqualMaxSize] [nvarchar](10) NULL,
	[TEMPDB_EqualGrowth] [nvarchar](10) NULL,
	[TEMPDB_NoFilesWithPercentGrowth] [nvarchar](10) NULL,
	[BU_Compress_ON] [int] NULL
) ON [PRIMARY]
GO


