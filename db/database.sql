USE [master]
GO
/****** Object:  Database [ESCOMEDICS]    Script Date: 29/06/2024 12:19:43 p. m. ******/
CREATE DATABASE [ESCOMEDICS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ESCOMEDICS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ESCOMEDICS.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ESCOMEDICS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\ESCOMEDICS_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [ESCOMEDICS] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ESCOMEDICS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ESCOMEDICS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET ARITHABORT OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ESCOMEDICS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ESCOMEDICS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ESCOMEDICS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ESCOMEDICS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET RECOVERY FULL 
GO
ALTER DATABASE [ESCOMEDICS] SET  MULTI_USER 
GO
ALTER DATABASE [ESCOMEDICS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ESCOMEDICS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ESCOMEDICS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ESCOMEDICS] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ESCOMEDICS] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ESCOMEDICS] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [ESCOMEDICS] SET QUERY_STORE = ON
GO
ALTER DATABASE [ESCOMEDICS] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [ESCOMEDICS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_001_login]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_001_login] 
(
	@email varchar(100),
	@password varchar(20)
)
RETURNS 
@login_usuario TABLE 
(
	id_usuario Int,
	nombre varchar(100),
	ap_paterno varchar(100),
	ap_materno varchar(100),
	id_rol int,
	email_usuario varchar(100)
)
AS
BEGIN
	declare @id_usuario as int;
	declare @nombre as varchar(100);
	declare @ap_paterno as varchar(100);
	declare @ap_materno as varchar(100);
	declare @id_rol as int;

	select 
		@id_usuario = id_usuario,
		@nombre = nombre,
		@ap_paterno = ap_paterno,
		@ap_materno = ap_materno,
		@id_rol = id_rol
	from 
		Usuarios 
	where 
		correo = @email 
	and 
		contrasena = @password;

	if @id_usuario is null
		insert into @login_usuario( id_usuario ) values (0)
	else
		insert into @login_usuario( id_usuario, nombre, ap_paterno, ap_materno, id_rol, email_usuario ) values( @id_usuario, @nombre, @ap_paterno, @ap_materno, @id_rol, @email )
	
	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_002_obtiene_menu_usuario]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_002_obtiene_menu_usuario] 
(
	@rol_usuario int
)
RETURNS 
@menuUsuario TABLE 
(
	json_menu varchar(MAX)
)
AS
BEGIN
	declare @id_menu int, @desc_menu varchar(100), @id_submenu int, @des_submenu varchar(100);
	declare @json nvarchar(MAX);
	declare @anterior int = 0;
	declare @contador int = 0;
	set @json = '{"opcion_menu":[{ "id" :'+cast(@rol_usuario as varchar(1))+', "menu":['
	declare MenusCursor cursor for
		select 
			p.id_submenu,
			s.descripcion,
			m.id_menu,
			m.descripcion
		from
			Permisos p
			inner join Submenus s on s.id_submenu = p.id_submenu
			inner join Menus m on m.id_menu = s.id_menu
		where 
			p.id_rol = @rol_usuario
		order by m.id_menu

	open MenusCursor;
	fetch next from MenusCursor into @id_submenu, @des_submenu, @id_menu, @desc_menu;


	while @@FETCH_STATUS = 0
	begin
		if @anterior <> @id_menu
		begin
			if @contador = 1
			begin
				set @json = @json + ']},';
				set @contador = 0;
			end
			set @json = @json + 
				'{"id_menu":' + cast(@id_menu as varchar(10)) +
				',"descripcion":"' + @desc_menu + 
				'","submenus":[';

				if @id_submenu is not null
				begin
					set @json = @json + '{"id":'+ cast(@id_submenu as varchar(10)) + 
						',"descripcion":"'+@des_submenu+'"}';
					set @contador = @contador + 1
				end
				else
					set @json = @json + ']';

			set @anterior = @id_menu;
		end
		else if @anterior = @id_menu
		begin
			set @json = @json + ',{"id":' + cast(@id_submenu as varchar(10)) + 
				',"descripcion":"' + @des_submenu + '"}';
		end
		fetch next from MenusCursor into @id_submenu, @des_submenu, @id_menu, @desc_menu;
	end

	set @json = @json + ']}]}]}';
	close MenusCursor;
	deallocate MenusCursor;
	 insert into @menuUsuario(json_menu)values(@json);

	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_003_obtiene_disponibilidad_consultas]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_003_obtiene_disponibilidad_consultas]
(
	@cedula_prof varchar(8)
)
RETURNS 
@disponibildad TABLE
(
	json_disponibilidad varchar(MAX)
)
AS
BEGIN
	
	declare @fecha_consulta date, @hora_consulta time(7), @hora_entrada time(7), @hora_salida time(7);
	declare @json nvarchar(MAX);
	declare @anterior date = '2000-01-01';
	declare @contador int = 0;
	declare @hora_disponible time;
	set @json = '{';
	
	declare DisponibilidadCursor cursor for
		select 
			c.fecha_consulta,
			c.hora_consulta,
			h.hora_entrada,
			h.hora_salida
		from Medicos m 
			inner join Empleados e on e.id_empleado = m.id_empleado
			inner join Horarios h on h.id_horario = e.id_horario
			left join Consultas c on c.cedula_prof = m.cedula_prof
		where m.cedula_prof = @cedula_prof

	open DisponibilidadCursor;
	fetch next from DisponibilidadCursor into @fecha_consulta, @hora_consulta, @hora_entrada, @hora_salida;
	

	set @json = @json + 
	'"hora_entrada":"'+cast(@hora_entrada as varchar(8))+'",'+
	'"hora_salida":"'+cast(@hora_salida as varchar(8))+'",'+
	'"consultas_agendadas":[';
	
	if @fecha_consulta is null
		set @json = @json + ']}';
	else
	begin

	while @@FETCH_STATUS = 0
	begin
		if cast(@anterior as varchar(10)) <> cast(@fecha_consulta as varchar(10))
		begin
			if @contador = 1
			begin
				set @json = @json + ']},'
				set @contador = 0;
			end
			set @json = @json + 
			'{"fecha_consulta":"' + cast(@fecha_consulta as varchar(20)) + 
			'",'+
			'"horas":[';
			if @hora_consulta is not null
			begin
				set @json = @json +
					'{"hora_ocupada":'+
					'"'+cast(@hora_consulta as varchar(5))+'"}'
					set @contador = 1;
			end 
			set @anterior = @fecha_consulta;
		end
		else if cast(@anterior as varchar(10)) = cast(@fecha_consulta as varchar(10))
		begin
			set @json = @json + ',{"hora_ocupada":"'+ cast(@hora_consulta as varchar(5))+'"}';
		end
		fetch next from DisponibilidadCursor into @fecha_consulta, @hora_consulta, @hora_entrada, @hora_salida;;
	end

	set @json = @json + ']}]}';
	end
	close DisponibilidadCursor;
	deallocate DisponibilidadCursor;
	 insert into @disponibildad(json_disponibilidad)values(@json);
	
	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_004_obtiene_citas_agendadas_paciente]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fn_004_obtiene_citas_agendadas_paciente]
(
	@id_paciente int,
	@estatus int
)
RETURNS 
@citas_paciente TABLE 
(
	json_citas varchar(max)
)
AS
BEGIN
		
	declare @id_consulta int,
			@fecha_consulta date, 
			@hora_consulta time(7), 
			@nombre varchar(50), 
			@ap_paterno varchar(50), 
			@ap_materno varchar(50),
			@id_consultorio int,
			@piso_consultorio int,
			@estatus_cita int,
			@especialidad varchar(50);

	declare @json nvarchar(MAX);
	declare @anterior int = 0;
	declare @contador int = 0;
	set @json = '{"consultas":[';
	declare CitasCursor cursor for
		select 
			c.id_consulta,
			c.fecha_consulta,
			c.hora_consulta,
			c.nombre,
			c.ap_paterno,
			c.ap_materno,
			c.id_consultorio,
			c.piso_consultorio,
			c.estatus_consulta,
			c.nombre_especialidad
		from 
			v_006_citas_paciente c 
		where 
			c.id_paciente = @id_paciente 
		and 
			c.estatus_consulta = @estatus 

	open CitasCursor;
	fetch next from CitasCursor into @id_consulta, @fecha_consulta, @hora_consulta, @nombre, @ap_paterno, @ap_materno, @id_consultorio, @piso_consultorio, @estatus_cita, @especialidad;


	while @@FETCH_STATUS = 0
	begin
			if @contador >= 1
				set @json = @json + ','
			set @json = @json + '{"id_consulta":' + cast( @id_consulta as varchar(5)) + ',' +
						'"fecha_consulta": "'+ cast( @fecha_consulta as varchar(10)) + '",'+
						'"hora_consulta": "'+ cast( @hora_consulta as varchar(5)) + '",' +
						'"nombre_medico":"' + @nombre + ' ' + @ap_paterno + ' ' + @ap_materno + '",'+
						'"consultorio":' + cast(@id_consultorio as varchar(3)) + ','+
						'"piso_consultorio":' + cast( @piso_consultorio as varchar(2) )+ ','+
						'"especialidad": "'+ @especialidad +'"}';
			set @contador = @contador + 1;
		fetch next from CitasCursor into @id_consulta, @fecha_consulta, @hora_consulta, @nombre, @ap_paterno, @ap_materno, @id_consultorio, @piso_consultorio, @estatus_cita, @especialidad;
	end

	set @json = @json + ']}';
	close CitasCursor;
	deallocate CitasCursor;
	 insert into @citas_paciente(json_citas)values(@json);
	
	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[sf_001_login]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[sf_001_login]
(
	@email varchar(100),
	@password varchar(100)
)
RETURNS int
AS
BEGIN
	declare @id_user as int;

	select @id_user = id_usuario from Usuarios where correo = @email and contrasena = @password

	if @id_user is null
		set @id_user = 0

	return @id_user

END
GO
/****** Object:  Table [dbo].[Medicos]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medicos](
	[cedula_prof] [varchar](8) NOT NULL,
	[estatus] [int] NOT NULL,
	[id_empleado] [int] NOT NULL,
	[id_especialiad] [int] NOT NULL,
	[id_consultorio] [int] NOT NULL,
 CONSTRAINT [PK_Medicos] PRIMARY KEY CLUSTERED 
(
	[cedula_prof] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles_Usuarios]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles_Usuarios](
	[id_rol] [int] NOT NULL,
	[rol_usuario] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_rol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuarios]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuarios](
	[id_usuario] [int] NOT NULL,
	[nombre] [nvarchar](255) NULL,
	[ap_paterno] [nvarchar](255) NULL,
	[ap_materno] [nvarchar](255) NULL,
	[sexo] [int] NULL,
	[curp] [nvarchar](255) NULL,
	[telefono] [nvarchar](255) NULL,
	[direccion] [nvarchar](255) NULL,
	[correo] [nvarchar](255) NULL,
	[contrasena] [nvarchar](255) NULL,
	[fecha_registro] [date] NULL,
	[id_rol] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Empleados]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Empleados](
	[id_empleado] [int] NOT NULL,
	[tipo_empleado] [int] NULL,
	[estatus] [int] NULL,
	[id_horario] [int] NULL,
	[id_usuario] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_empleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Horarios]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Horarios](
	[id_horario] [int] NOT NULL,
	[descripcion_horario] [varchar](50) NOT NULL,
	[hora_entrada] [time](7) NOT NULL,
	[hora_salida] [time](7) NOT NULL,
 CONSTRAINT [PK_Horarios] PRIMARY KEY CLUSTERED 
(
	[id_horario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_002_detalles_medico]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_002_detalles_medico]
AS
SELECT        u.nombre, u.ap_paterno, u.ap_materno, u.sexo, u.curp, u.telefono, u.correo, e.id_horario, m.id_especialiad AS id_especialidad, m.cedula_prof, m.id_consultorio, u.id_usuario, e.id_empleado, h.hora_entrada, h.hora_salida
FROM            dbo.Usuarios AS u INNER JOIN
                         dbo.Empleados AS e ON e.id_usuario = u.id_usuario INNER JOIN
                         dbo.Medicos AS m ON m.id_empleado = e.id_empleado INNER JOIN
                         dbo.Roles_Usuarios AS ro ON ro.id_rol = u.id_rol INNER JOIN
                         dbo.Horarios AS h ON h.id_horario = e.id_horario
GO
/****** Object:  Table [dbo].[Pacientes]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pacientes](
	[id_paciente] [int] NOT NULL,
	[tipo_paciente] [int] NOT NULL,
	[id_usuario] [int] NOT NULL,
 CONSTRAINT [PK_Pacientes] PRIMARY KEY CLUSTERED 
(
	[id_paciente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_003_detalles_paciente]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_003_detalles_paciente]
AS
SELECT        u.nombre, u.ap_paterno, u.ap_materno, u.telefono, u.sexo, u.correo, u.direccion, u.curp, u.id_rol, u.id_usuario, p.id_paciente, ro.rol_usuario
FROM            dbo.Usuarios AS u INNER JOIN
                         dbo.Pacientes AS p ON p.id_usuario = u.id_usuario INNER JOIN
                         dbo.Roles_Usuarios AS ro ON ro.id_rol = u.id_rol
GO
/****** Object:  Table [dbo].[Recepcionistas]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recepcionistas](
	[id_recepcionista] [int] NOT NULL,
	[id_empleado] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_recepcionista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_004_detalles_recepcionista]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_004_detalles_recepcionista]
AS
SELECT        u.nombre, u.ap_paterno, u.ap_materno, u.telefono, u.sexo, u.correo, u.direccion, u.curp, u.id_rol, e.id_horario, u.id_usuario, e.id_empleado, r.id_recepcionista, ro.rol_usuario
FROM            dbo.Usuarios AS u INNER JOIN
                         dbo.Empleados AS e ON e.id_usuario = u.id_usuario INNER JOIN
                         dbo.Recepcionistas AS r ON r.id_empleado = e.id_empleado INNER JOIN
                         dbo.Roles_Usuarios AS ro ON ro.id_rol = u.id_rol
GO
/****** Object:  Table [dbo].[Farmaceuticos]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Farmaceuticos](
	[id_farmaceutico] [int] NOT NULL,
	[id_empleado] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_farmaceutico] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_005_detalles_farmaceutico]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_005_detalles_farmaceutico]
AS
SELECT        u.nombre, u.ap_paterno, u.ap_materno, u.telefono, u.sexo, u.correo, u.direccion, u.curp, u.id_rol, e.id_horario, u.id_usuario, e.id_empleado, f.id_farmaceutico
FROM            dbo.Usuarios AS u INNER JOIN
                         dbo.Empleados AS e ON e.id_usuario = u.id_usuario INNER JOIN
                         dbo.Farmaceuticos AS f ON f.id_empleado = e.id_empleado
GO
/****** Object:  View [dbo].[v_001_consultar_usuarios]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_001_consultar_usuarios]
AS
SELECT        dbo.Usuarios.id_usuario, dbo.Usuarios.nombre, dbo.Usuarios.ap_paterno, dbo.Usuarios.ap_materno, dbo.Usuarios.sexo, dbo.Usuarios.curp, dbo.Usuarios.telefono, dbo.Usuarios.direccion, dbo.Usuarios.correo, 
                         dbo.Usuarios.contrasena, dbo.Usuarios.fecha_registro, dbo.Usuarios.id_rol, r.rol_usuario
FROM            dbo.Usuarios INNER JOIN
                         dbo.Roles_Usuarios AS r ON r.id_rol = dbo.Usuarios.id_rol
GO
/****** Object:  Table [dbo].[Consultorios]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Consultorios](
	[id_consultorio] [int] NOT NULL,
	[piso_consultorio] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_consultorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Especialidades]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Especialidades](
	[id_especialidad] [int] NOT NULL,
	[nombre_especialidad] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_especialidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Consultas]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Consultas](
	[id_consulta] [int] NOT NULL,
	[estatus_consulta] [int] NOT NULL,
	[fecha_consulta] [date] NOT NULL,
	[hora_consulta] [time](7) NOT NULL,
	[cedula_prof] [varchar](8) NOT NULL,
	[id_paciente] [int] NOT NULL,
	[id_registra] [int] NULL,
 CONSTRAINT [PK_Consultas] PRIMARY KEY CLUSTERED 
(
	[id_consulta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_006_citas_paciente]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_006_citas_paciente]
AS
SELECT        c.id_consulta, c.fecha_consulta, c.hora_consulta, u.ap_materno, co.id_consultorio, co.piso_consultorio, p.id_paciente, u.nombre, u.ap_paterno, c.estatus_consulta, es.nombre_especialidad
FROM            dbo.Consultas AS c INNER JOIN
                         dbo.Medicos AS m ON m.cedula_prof = c.cedula_prof INNER JOIN
                         dbo.Especialidades AS es ON es.id_especialidad = m.id_especialiad INNER JOIN
                         dbo.Consultorios AS co ON co.id_consultorio = m.id_consultorio INNER JOIN
                         dbo.Empleados AS e ON e.id_empleado = m.id_empleado INNER JOIN
                         dbo.Pacientes AS p ON p.id_paciente = c.id_paciente INNER JOIN
                         dbo.Usuarios AS u ON u.id_usuario = e.id_usuario
GO
/****** Object:  View [dbo].[v_006_citas_usuario]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_006_citas_usuario]
AS
SELECT        c.id_consulta, c.fecha_consulta, c.hora_consulta, u.nombre + '  ' + u.ap_paterno + ' ' + u.ap_materno AS nombre_medico, co.id_consultorio, co.piso_consultorio, c.id_paciente, m.id_especialiad AS id_especialidad, 
                         es.nombre_especialidad, c.estatus_consulta, pu.nombre + ' ' + pu.ap_paterno + ' ' + pu.ap_materno AS nombre_paciente
FROM            dbo.Consultas AS c INNER JOIN
                         dbo.Medicos AS m ON m.cedula_prof = c.cedula_prof INNER JOIN
                         dbo.Consultorios AS co ON co.id_consultorio = m.id_consultorio INNER JOIN
                         dbo.Empleados AS e ON e.id_empleado = m.id_empleado INNER JOIN
                         dbo.Usuarios AS u ON u.id_usuario = e.id_usuario INNER JOIN
                         dbo.Especialidades AS es ON es.id_especialidad = m.id_especialiad INNER JOIN
                         dbo.Pacientes AS p ON p.id_paciente = c.id_paciente INNER JOIN
                         dbo.Usuarios AS pu ON pu.id_usuario = p.id_paciente
GO
/****** Object:  Table [dbo].[Inventario_Farmacia]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Inventario_Farmacia](
	[id_medicamento] [int] NOT NULL,
	[compuesto_medicamento] [nvarchar](255) NULL,
	[presentacion_medicamento] [nvarchar](255) NULL,
	[existencia_medicamento] [int] NULL,
	[precio_venta_medicamento] [money] NULL,
	[precio_compra_medicamento] [money] NULL,
	[tipo_medicamento] [int] NULL,
	[contenido_neto] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_medicamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Menus]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menus](
	[id_menu] [int] NOT NULL,
	[descripcion] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id_menu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Permisos]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permisos](
	[id_submenu] [int] NULL,
	[id_rol] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Precios_Consultas]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Precios_Consultas](
	[id_precio] [int] NOT NULL,
	[costo_consulta] [money] NULL,
	[id_especialidad] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_precio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Submenus]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Submenus](
	[id_submenu] [int] NOT NULL,
	[descripcion] [nvarchar](255) NULL,
	[id_menu] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_submenu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ventas_Farmacia]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ventas_Farmacia](
	[id_venta] [nvarchar](255) NOT NULL,
	[id_medicamento] [int] NOT NULL,
	[cantidad_medicamento] [int] NULL,
	[estatus_venta] [int] NULL,
	[id_farmaceutico] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_venta] ASC,
	[id_medicamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Consultas]  WITH CHECK ADD  CONSTRAINT [FK_Consultas_Medicos] FOREIGN KEY([cedula_prof])
REFERENCES [dbo].[Medicos] ([cedula_prof])
GO
ALTER TABLE [dbo].[Consultas] CHECK CONSTRAINT [FK_Consultas_Medicos]
GO
ALTER TABLE [dbo].[Consultas]  WITH CHECK ADD  CONSTRAINT [FK_Consultas_Pacientes] FOREIGN KEY([id_paciente])
REFERENCES [dbo].[Pacientes] ([id_paciente])
GO
ALTER TABLE [dbo].[Consultas] CHECK CONSTRAINT [FK_Consultas_Pacientes]
GO
ALTER TABLE [dbo].[Empleados]  WITH CHECK ADD FOREIGN KEY([id_usuario])
REFERENCES [dbo].[Usuarios] ([id_usuario])
GO
ALTER TABLE [dbo].[Empleados]  WITH CHECK ADD FOREIGN KEY([id_usuario])
REFERENCES [dbo].[Usuarios] ([id_usuario])
GO
ALTER TABLE [dbo].[Farmaceuticos]  WITH CHECK ADD FOREIGN KEY([id_empleado])
REFERENCES [dbo].[Empleados] ([id_empleado])
GO
ALTER TABLE [dbo].[Farmaceuticos]  WITH CHECK ADD FOREIGN KEY([id_empleado])
REFERENCES [dbo].[Empleados] ([id_empleado])
GO
ALTER TABLE [dbo].[Pacientes]  WITH CHECK ADD  CONSTRAINT [FK_Pacientes_Usuarios] FOREIGN KEY([id_usuario])
REFERENCES [dbo].[Usuarios] ([id_usuario])
GO
ALTER TABLE [dbo].[Pacientes] CHECK CONSTRAINT [FK_Pacientes_Usuarios]
GO
ALTER TABLE [dbo].[Precios_Consultas]  WITH CHECK ADD FOREIGN KEY([id_especialidad])
REFERENCES [dbo].[Especialidades] ([id_especialidad])
GO
ALTER TABLE [dbo].[Precios_Consultas]  WITH CHECK ADD FOREIGN KEY([id_especialidad])
REFERENCES [dbo].[Especialidades] ([id_especialidad])
GO
ALTER TABLE [dbo].[Recepcionistas]  WITH CHECK ADD FOREIGN KEY([id_empleado])
REFERENCES [dbo].[Empleados] ([id_empleado])
GO
ALTER TABLE [dbo].[Recepcionistas]  WITH CHECK ADD FOREIGN KEY([id_empleado])
REFERENCES [dbo].[Empleados] ([id_empleado])
GO
ALTER TABLE [dbo].[Submenus]  WITH CHECK ADD FOREIGN KEY([id_menu])
REFERENCES [dbo].[Menus] ([id_menu])
GO
ALTER TABLE [dbo].[Submenus]  WITH CHECK ADD FOREIGN KEY([id_menu])
REFERENCES [dbo].[Menus] ([id_menu])
GO
ALTER TABLE [dbo].[Usuarios]  WITH CHECK ADD FOREIGN KEY([id_rol])
REFERENCES [dbo].[Roles_Usuarios] ([id_rol])
GO
ALTER TABLE [dbo].[Usuarios]  WITH CHECK ADD FOREIGN KEY([id_rol])
REFERENCES [dbo].[Roles_Usuarios] ([id_rol])
GO
ALTER TABLE [dbo].[Ventas_Farmacia]  WITH CHECK ADD FOREIGN KEY([id_farmaceutico])
REFERENCES [dbo].[Farmaceuticos] ([id_farmaceutico])
GO
ALTER TABLE [dbo].[Ventas_Farmacia]  WITH CHECK ADD FOREIGN KEY([id_farmaceutico])
REFERENCES [dbo].[Farmaceuticos] ([id_farmaceutico])
GO
/****** Object:  StoredProcedure [dbo].[cursores]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[cursores]
AS
BEGIN
	SET NOCOUNT ON;
	declare @id_menu int, @desc_menu varchar(100), @id_submenu int, @des_submenu varchar(100);
	declare @json nvarchar(MAX);
	declare @anterior int = 0;
	declare @contador int = 0;
	set @json = '{"opcion_menu":[{ "id" : 1, "menu":['
	declare MenusCursor cursor for
		select 
			p.id_submenu,
			s.descripcion,
			m.id_menu,
			m.descripcion
		from
			Permisos p
			inner join Submenus s on s.id_submenu = p.id_submenu
			inner join Menus m on m.id_menu = s.id_menu
		where 
			p.id_rol = 1

	open MenusCursor;
	fetch next from MenusCursor into @id_submenu, @des_submenu, @id_menu, @desc_menu;

	while @@FETCH_STATUS = 0
	begin
		if @anterior <> @id_menu
		begin
			if @contador > 1
				set @json = @json + ']},';
			set @json = @json + 
				'{"id_menu":' + cast(@id_menu as varchar(10)) +
				',"descripcion":"' + @desc_menu + 
				'","submenus":[';

				if @id_submenu is not null
				begin
					set @json = @json + '{"id":'+ cast(@id_submenu as varchar(10)) + 
						',"descripcion":"'+@des_submenu+'"}';
				end
				else
					set @json = @json + ']';

			set @anterior = @id_menu;
		end
		else if @anterior = @id_menu
		begin
			set @json = @json + ',{"id":' + cast(@id_submenu as varchar(10)) + 
				',"descripcion":"' + @des_submenu + '"}';
		end
		set @contador = @contador + 1;
		fetch next from MenusCursor into @id_submenu, @des_submenu, @id_menu, @desc_menu;
	end

	set @json = @json + ']}]}]}';
	close MenusCursor;
	deallocate MenusCursor;
	select @json as json_menu;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_001_inserta_usuario]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_001_inserta_usuario]
	@nombre varchar(50),
	@ap_paterno varchar(20),
	@ap_materno varchar(20),
	@sexo int,
	@curp varchar(18),
	@telefono varchar(10),
	@direccion varchar(100),
	@correo varchar(100),
	@contrasena varchar(15),
	@id_rol int,
	@tipo_paciente int = 1,
	@id_horario int,
	@cedula varchar(50),
	@id_especialidad int,
	@id_consultorio int,
	@estatus int = 1

AS
BEGIN
	SET NOCOUNT ON;
	declare @id as int;

	select top 1 @id = id_usuario from Usuarios order by id_usuario desc;

	if( @id is not null )
		set @id = @id + 1
	else
		set @id = 1

	insert into Usuarios(
		id_usuario,
		nombre,
		ap_paterno,
		ap_materno,
		sexo,
		curp,
		telefono,
		direccion,
		correo,
		contrasena,
		fecha_registro,
		id_rol
	)values(
		@id,
		@nombre,
		@ap_paterno,
		@ap_materno,
		@sexo,
		@curp,
		@telefono,
		@direccion,
		@correo,
		@contrasena,
		getdate(),
		@id_rol
	)

	if(@id_rol = 4)
		exec dbo.sp_006_inserta_paciente 1,@id
	else 
		exec dbo.sp_002_inserta_empleado 
			@id_rol,
			@id_horario,
			@estatus, 
			@id, @cedula,
			@id_especialidad,
			@id_consultorio
END
GO
/****** Object:  StoredProcedure [dbo].[sp_002_inserta_empleado]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_002_inserta_empleado] 
	@tipo_empleado int,
	@id_horario int,
	@estatus int,
	@id_usuario int,
	@cedula varchar(50),
	@id_especialidad int,
	@id_consultorio int 
AS
BEGIN
	SET NOCOUNT ON;

	declare @id as int;

	select top 1 @id = id_empleado from Empleados order by id_empleado desc;

	if( @id is not null )
		set @id = @id + 1
	else
		set @id = 1

	insert into Empleados(
		id_empleado,
		tipo_empleado,
		id_horario,
		estatus,
		id_usuario
	)values(
		@id,
		@tipo_empleado,
		@id_horario,
		@estatus,
		@id_usuario
	)

	if( @tipo_empleado = 1 )
		exec dbo.sp_004_inserta_recepcionista @id
	else
	if( @tipo_empleado = 2 )
		exec dbo.sp_003_inserta_medico @cedula, 1, @id, @id_especialidad, @id_consultorio
	else
	if(@tipo_empleado = 3 )
		exec dbo.sp_005_inserta_farmaceutico @id
	
		
END
GO
/****** Object:  StoredProcedure [dbo].[sp_003_inserta_medico]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_003_inserta_medico]
	@cedula varchar(50),
	@estatus int,
	@id_empleado int,
	@id_especialidad int,
	@id_consultorio int
AS
BEGIN
	SET NOCOUNT ON;

    insert into Medicos(
		cedula_prof, 
		estatus, 
		id_empleado, 
		id_especialidad, 
		id_consultorio
	)values(
		@cedula, 
		@estatus, 
		@id_empleado,
		@id_especialidad,
		@id_consultorio
	);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_004_inserta_recepcionista]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_004_inserta_recepcionista]
	@id_empleado int 
AS
BEGIN
	SET NOCOUNT ON;
	declare @id_recepcioista as int;

	select top 1 @id_recepcioista = id_recepcionista from Recepcionistas order by id_recepcionista desc

	if @id_recepcioista is not null
		set @id_recepcioista = @id_recepcioista + 1
	else
		set @id_recepcioista = 1

    insert into Recepcionistas( id_recepcionista, id_empleado) values(@id_recepcioista, @id_empleado)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_005_inserta_farmaceutico]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_005_inserta_farmaceutico]
	@id_empleado int
AS
BEGIN
	SET NOCOUNT ON;
	declare @id_farmaceutico as int;
    
	select top 1 @id_farmaceutico = id_farmaceutico from Farmaceuticos order by id_farmaceutico desc;

	if @id_farmaceutico is not null
		set @id_farmaceutico = @id_farmaceutico + 1
	else 
		set @id_farmaceutico = 1

	insert into Farmaceuticos( id_farmaceutico, id_empleado ) values (@id_farmaceutico, @id_empleado )
END
GO
/****** Object:  StoredProcedure [dbo].[sp_006_inserta_paciente]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_006_inserta_paciente]
	@tipo_paciente int,
	@id_usuario int
AS
BEGIN
	SET NOCOUNT ON;
	declare @id as int;

	select top 1 @id = id_paciente from Pacientes order by id_paciente desc;

	if( @id is not null )
		set @id = @id + 1
	else
		set @id = 1
    
	insert into Pacientes(
		id_paciente,
		tipo_paciente,
		id_usuario
	)values(
		@id,
		@tipo_paciente,
		@id_usuario
	)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_007_detalles_recepcionista]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_007_detalles_recepcionista]
	@id_usuario int
AS
BEGIN
	SET NOCOUNT ON;
	
	select 
		e.id_empleado,
		e.estatus,
		r.id_recepcionista,
		m.json_menu,
		rol.rol_usuario,
		h.descripcion_horario
	from 
		Empleados e 
		inner join Roles_Usuarios rol on rol.id_rol= e.tipo_empleado
		inner join Recepcionistas r on r.id_empleado = e.id_empleado 
		inner join Horarios h on h.id_horario = e.id_horario
		cross apply fn_002_obtiene_menu_usuario(1) m
	where 
		id_usuario = @id_usuario

END
GO
/****** Object:  StoredProcedure [dbo].[sp_009_obtiene_menu_usuario]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_009_obtiene_menu_usuario] 
	@tipo_usuario int
AS
BEGIN
	SET NOCOUNT ON;
	declare @id_menu int, @desc_menu varchar(100), @id_submenu int, @des_submenu varchar(100);
	declare @json nvarchar(MAX);
	declare @anterior int = 0;
	declare @contador int = 0;
	set @json = '{"opcion_menu":[{ "id" :'+cast(@tipo_usuario as varchar(1))+', "menu":['
	declare MenusCursor cursor for
		select 
			p.id_submenu,
			s.descripcion,
			m.id_menu,
			m.descripcion
		from
			Permisos p
			inner join Submenus s on s.id_submenu = p.id_submenu
			inner join Menus m on m.id_menu = s.id_menu
		where 
			p.id_rol = @tipo_usuario
		order by m.id_menu

	open MenusCursor;
	fetch next from MenusCursor into @id_submenu, @des_submenu, @id_menu, @desc_menu;

	while @@FETCH_STATUS = 0
	begin
		if @anterior <> @id_menu
		begin
			print @id_menu;
			if @contador = 1
			begin
				print @contador;
				set @json = @json + ']},';
			end
			set @json = @json + 
				'{"id_menu":' + cast(@id_menu as varchar(10)) +
				',"descripcion":"' + @desc_menu + 
				'","submenus":[';

				if @id_submenu is not null
				begin
					set @json = @json + '{"id":'+ cast(@id_submenu as varchar(10)) + 
						',"descripcion":"'+@des_submenu+'"}';
					set @contador = @contador + 1;
				end
				else
					set @json = @json + ']';

			set @anterior = @id_menu;
		end
		else if @anterior = @id_menu
		begin
			set @json = @json + ',{"id":' + cast(@id_submenu as varchar(10)) + 
				',"descripcion":"' + @des_submenu + '"}';
		end
		--set @contador = @contador + 1
		fetch next from MenusCursor into @id_submenu, @des_submenu, @id_menu, @desc_menu;
	end

	set @json = @json + ']}]}]}';
	close MenusCursor;
	deallocate MenusCursor;
	select @json as json_menu;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_010_obtiene_datos_usuario]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_010_obtiene_datos_usuario] 
	@id_usuario int,
	@rol_usuario int
AS
BEGIN
	SET NOCOUNT ON;

	if @rol_usuario <> 4
		begin
			if @rol_usuario = 1
				select * from v_004_detalles_recepcionista where id_usuario = @id_usuario
			else if @rol_usuario = 2
				select * from v_002_detalles_medico where id_usuario = @id_usuario
			else if @id_usuario = 3
				select * from v_005_detalles_farmaceutico where id_usuario = @id_usuario
		end
	else if @rol_usuario = 4
		select * from v_003_detalles_paciente where id_usuario = @id_usuario

END
GO
/****** Object:  StoredProcedure [dbo].[sp_011_registra_cita]    Script Date: 29/06/2024 12:19:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_011_registra_cita] 
	@fecha varchar(10),
	@hora_consulta varchar(5),
	@cedula varchar(9),
	@id_paciente int,
	@id_registra int = null
AS
BEGIN
	SET NOCOUNT ON;
	declare @id as int;

	select top 1 @id = id_consulta from Consultas order by id_consulta desc;

	if( @id is not null )
		set @id = @id + 1
	else
		set @id = 1

	insert into Consultas(id_consulta, estatus_consulta, fecha_consulta, hora_consulta, cedula_prof, id_paciente, id_registra)
	values( @id, 1, @fecha, @hora_consulta, @cedula, @id_paciente, @id_registra)

    
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Usuarios"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "r"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 102
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_001_consultar_usuarios'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_001_consultar_usuarios'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "u"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "m"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 136
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "ro"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 102
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "h"
            Begin Extent = 
               Top = 102
               Left = 662
               Bottom = 232
               Right = 855
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_002_detalles_medico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_002_detalles_medico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "u"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ro"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_003_detalles_paciente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_003_detalles_paciente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "u"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "r"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 628
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ro"
            Begin Extent = 
               Top = 6
               Left = 666
               Bottom = 102
               Right = 836
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_004_detalles_recepcionista'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_004_detalles_recepcionista'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "u"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "f"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 628
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_005_detalles_farmaceutico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_005_detalles_farmaceutico'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[16] 2[36] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -192
         Left = 0
      End
      Begin Tables = 
         Begin Table = "c"
            Begin Extent = 
               Top = 8
               Left = 11
               Bottom = 138
               Right = 181
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "m"
            Begin Extent = 
               Top = 29
               Left = 222
               Bottom = 159
               Right = 392
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "co"
            Begin Extent = 
               Top = 156
               Left = 365
               Bottom = 252
               Right = 541
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 668
               Bottom = 136
               Right = 838
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 191
               Left = 104
               Bottom = 304
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "u"
            Begin Extent = 
               Top = 140
               Left = 566
               Bottom = 270
               Right = 736
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "es"
            Begin Extent = 
               Top = 8
               Left = 447
               Bottom = 104
               Right = 648
            End
            DisplayFlags = 280
            TopColumn = 0
         E' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_006_citas_paciente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'nd
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_006_citas_paciente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_006_citas_paciente'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[45] 4[7] 2[29] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "m"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "co"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 630
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 668
               Bottom = 136
               Right = 838
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "u"
            Begin Extent = 
               Top = 102
               Left = 454
               Bottom = 232
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "es"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 234
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 138
               Left = 277
               Bottom = 251
               Right = 447
            End
            DisplayFlags = 280
            TopColumn = 0
         End
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_006_citas_usuario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Begin Table = "pu"
            Begin Extent = 
               Top = 138
               Left = 662
               Bottom = 268
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_006_citas_usuario'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'v_006_citas_usuario'
GO
USE [master]
GO
ALTER DATABASE [ESCOMEDICS] SET  READ_WRITE 
GO
