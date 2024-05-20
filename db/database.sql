USE [ESCOMEDICS]
GO
/****** Object:  Table [dbo].[pacientes]    Script Date: 20/05/2024 11:35:47 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pacientes](
	[id_paciente] [varchar](15) NOT NULL,
	[nombre] [varchar](30) NOT NULL,
	[ap_paterno] [varchar](15) NOT NULL,
	[ap_materno] [varchar](15) NOT NULL,
	[direccion] [varchar](100) NOT NULL,
	[curp] [varchar](18) NOT NULL,
	[telefono] [varchar](10) NULL,
 CONSTRAINT [PK_pacientes] PRIMARY KEY CLUSTERED 
(
	[id_paciente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[usuarios]    Script Date: 20/05/2024 11:35:47 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usuarios](
	[id_usuario] [varchar](12) NOT NULL,
	[correo_usuario] [varchar](50) NOT NULL,
	[password_usuario] [varchar](100) NOT NULL,
	[tipo_usuario] [int] NOT NULL,
 CONSTRAINT [PK_usuarios] PRIMARY KEY CLUSTERED 
(
	[id_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
