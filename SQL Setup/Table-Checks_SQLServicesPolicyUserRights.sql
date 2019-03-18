USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_SQLServicesPolicyUserRights]    Script Date: 28/02/2019 3:36:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_SQLServicesPolicyUserRights](
	[account] [nvarchar](2000) NULL,
	[Right] [nvarchar](100) NULL,
	[server] [nvarchar](255) NULL,
	[DateCaptured] [datetime2](7) NULL
) ON [PRIMARY]
GO


