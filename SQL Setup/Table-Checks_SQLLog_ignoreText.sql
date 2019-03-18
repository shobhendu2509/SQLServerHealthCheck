USE [DBAdmin]
GO

/****** Object:  Table [dbo].[Checks_SQLLog_ignoreText]    Script Date: 3/01/2019 2:48:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Checks_SQLLog_ignoreText](
	[InstanceName] [nvarchar](255) NULL,
	[TextStatus] [int] NULL,
	[Text] [nvarchar](255) NULL
) ON [PRIMARY]
GO


