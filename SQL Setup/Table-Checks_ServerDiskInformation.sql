USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_ServerDiskInformation]    Script Date: 21/12/2018 10:41:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_ServerDiskInformation](
	[ComputerName] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[Label] [nvarchar](255) NULL,
	[Capacity] [bigint] NULL,
	[Free] [bigint] NULL,
	[PercentFree] [float] NULL,
	[BlockSize] [int] NULL,
	[IsSqlDisk] [nvarchar](50) NULL,
	[DateCaptured] [datetime2](7) NULL
) ON [PRIMARY]
GO


