USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Inventory_ServerRoleMembers]    Script Date: 28/02/2019 3:16:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_ServerRoleMembers](
	[SQL Instance Name] [nvarchar](255) NULL,
	[DateCaptured] [datetime2](7) NULL,
	[loginname] [nvarchar](255) NULL,
	[type] [nvarchar](10) NULL,
	[type_desc] [nvarchar](50) NULL,
	[is_disabled] [bit] NULL,
	[sysadmin] [int] NULL,
	[securityadmin] [int] NULL,
	[serveradmin] [int] NULL,
	[setupadmin] [int] NULL,
	[processadmin] [int] NULL,
	[diskadmin] [int] NULL,
	[dbcreator] [int] NULL,
	[bulkadmin] [int] NULL,
	[create_date] [datetime2](7) NULL,
	[modify_date] [datetime2](7) NULL
) ON [PRIMARY]
GO


