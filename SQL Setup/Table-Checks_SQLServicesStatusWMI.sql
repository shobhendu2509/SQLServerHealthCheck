USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_SQLServicesStatusWMI]    Script Date: 28/02/2019 4:08:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_SQLServicesStatusWMI](
	[MachineName] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[DisplayName] [nvarchar](255) NULL,
	[state] [nvarchar](255) NULL,
	[startmode] [nvarchar](255) NULL,
	[startname] [nvarchar](255) NULL,
	[PathName] [nvarchar](500) NULL,
	[Description] [nvarchar](1000) NULL,
	[DateCaptured] [datetime2](7) NULL
) ON [PRIMARY]
GO


