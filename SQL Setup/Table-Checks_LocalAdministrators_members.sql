USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_LocalAdministrators_members]    Script Date: 28/02/2019 2:52:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_LocalAdministrators_members](
	[Member] [nvarchar](255) NULL,
	[ComputerName] [nvarchar](255) NULL,
	[LocalGroup] [nvarchar](255) NULL,
	[DateCaptured] [datetime2](7) NULL
) ON [PRIMARY]
GO
