USE [master]
GO
/****** Object:  Database [ClinicaSaludDB]    Script Date: 19/08/2026 10:37:20 ******/
-- Si la base de datos ya existe, la elimina
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'ClinicaSaludDB')
BEGIN
    ALTER DATABASE [ClinicaSaludDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ClinicaSaludDB];
END
GO

/****** Object:  Database [ClinicaSaludDB]    Script Date: 19/08/2026 10:37:20 ******/
CREATE DATABASE [ClinicaSaludDB]
GO

CREATE DATABASE [ClinicaSaludDB]
GO
ALTER DATABASE [ClinicaSaludDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ClinicaSaludDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ClinicaSaludDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [ClinicaSaludDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ClinicaSaludDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ClinicaSaludDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [ClinicaSaludDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ClinicaSaludDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [ClinicaSaludDB] SET  MULTI_USER 
GO
ALTER DATABASE [ClinicaSaludDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ClinicaSaludDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ClinicaSaludDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ClinicaSaludDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ClinicaSaludDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ClinicaSaludDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [ClinicaSaludDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [ClinicaSaludDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [ClinicaSaludDB]
GO
/****** Object:  Table [dbo].[Citas]    Script Date: 19/08/2026 10:37:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Citas](
	[CitaId] [int] IDENTITY(1,1) NOT NULL,
	[PacienteId] [int] NOT NULL,
	[MedicoId] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Hora] [time](7) NOT NULL,
	[Motivo] [varchar](255) NULL,
	[Estado] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CitaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Especialidades]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Especialidades](
	[EspecialidadId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Descripcion] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[EspecialidadId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HistorialMedico]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HistorialMedico](
	[HistorialId] [int] IDENTITY(1,1) NOT NULL,
	[PacienteId] [int] NOT NULL,
	[MedicoId] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Diagnostico] [varchar](255) NOT NULL,
	[Tratamiento] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[HistorialId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Medicos]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medicos](
	[MedicoId] [int] IDENTITY(1,1) NOT NULL,
	[Nombres] [varchar](100) NOT NULL,
	[Apellidos] [varchar](100) NOT NULL,
	[EspecialidadId] [int] NOT NULL,
	[Telefono] [varchar](20) NULL,
	[Correo] [varchar](100) NULL,
	[Estado] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MedicoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pacientes]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pacientes](
	[PacienteId] [int] IDENTITY(1,1) NOT NULL,
	[DNI] [varchar](15) NOT NULL,
	[Nombres] [varchar](100) NOT NULL,
	[Apellidos] [varchar](100) NOT NULL,
	[FechaNacimiento] [date] NOT NULL,
	[Sexo] [char](1) NOT NULL,
	[Telefono] [varchar](20) NULL,
	[Correo] [varchar](100) NULL,
	[Direccion] [varchar](200) NULL,
	[FechaRegistro] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PacienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RolId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RolId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuarios]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuarios](
	[UsuarioId] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Correo] [varchar](100) NOT NULL,
	[Contrasena] [varchar](255) NOT NULL,
	[RolId] [int] NOT NULL,
	[Estado] [bit] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UsuarioId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Citas] ON 

INSERT [dbo].[Citas] ([CitaId], [PacienteId], [MedicoId], [Fecha], [Hora], [Motivo], [Estado]) VALUES (1, 1, 1, CAST(N'2026-08-17' AS Date), CAST(N'17:24:00' AS Time), N'Revicion de prostata', N'Pendiente')
SET IDENTITY_INSERT [dbo].[Citas] OFF
GO
SET IDENTITY_INSERT [dbo].[Especialidades] ON 

INSERT [dbo].[Especialidades] ([EspecialidadId], [Nombre], [Descripcion]) VALUES (1, N'Cardiologia', N'Enfermedades del corazon')
INSERT [dbo].[Especialidades] ([EspecialidadId], [Nombre], [Descripcion]) VALUES (2, N'Pediatria', N'Atencion a ninos')
INSERT [dbo].[Especialidades] ([EspecialidadId], [Nombre], [Descripcion]) VALUES (3, N'Traumatologia', N'Lesiones y huesos')
SET IDENTITY_INSERT [dbo].[Especialidades] OFF
GO
SET IDENTITY_INSERT [dbo].[Medicos] ON 

INSERT [dbo].[Medicos] ([MedicoId], [Nombres], [Apellidos], [EspecialidadId], [Telefono], [Correo], [Estado]) VALUES (1, N'Chapatin', N'Chespirito', 2, N'888888888', N'Ch-8@gmail.com', 1)
SET IDENTITY_INSERT [dbo].[Medicos] OFF
GO
SET IDENTITY_INSERT [dbo].[Pacientes] ON 

INSERT [dbo].[Pacientes] ([PacienteId], [DNI], [Nombres], [Apellidos], [FechaNacimiento], [Sexo], [Telefono], [Correo], [Direccion], [FechaRegistro]) VALUES (1, N'12345655', N'Juan', N'Perez', CAST(N'1995-05-10' AS Date), N'M', N'987654321', N'juan@gmail.com', N'Av. Lima 123', CAST(N'2026-08-17T13:50:56.283' AS DateTime))
SET IDENTITY_INSERT [dbo].[Pacientes] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([RolId], [Nombre]) VALUES (1, N'Administrador')
INSERT [dbo].[Roles] ([RolId], [Nombre]) VALUES (2, N'Recepcionista')
INSERT [dbo].[Roles] ([RolId], [Nombre]) VALUES (3, N'Medico')
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO
SET IDENTITY_INSERT [dbo].[Usuarios] ON 

INSERT [dbo].[Usuarios] ([UsuarioId], [Nombre], [Correo], [Contrasena], [RolId], [Estado], [FechaCreacion]) VALUES (1, N'Admin', N'admin@clinica.com', N'12345', 1, 1, CAST(N'2026-08-17T22:23:48.473' AS DateTime))
INSERT [dbo].[Usuarios] ([UsuarioId], [Nombre], [Correo], [Contrasena], [RolId], [Estado], [FechaCreacion]) VALUES (2, N'Luca', N'luca@clinica.com', N'54321', 1, 1, CAST(N'2026-08-17T23:19:59.587' AS DateTime))
SET IDENTITY_INSERT [dbo].[Usuarios] OFF
GO
/****** Object:  Index [IX_Citas_Fecha]    Script Date: 19/08/2026 10:37:21 ******/
CREATE NONCLUSTERED INDEX [IX_Citas_Fecha] ON [dbo].[Citas]
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Historial_Paciente]    Script Date: 19/08/2026 10:37:21 ******/
CREATE NONCLUSTERED INDEX [IX_Historial_Paciente] ON [dbo].[HistorialMedico]
(
	[PacienteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Paciente__C035B8DD8987A228]    Script Date: 19/08/2026 10:37:21 ******/
ALTER TABLE [dbo].[Pacientes] ADD UNIQUE NONCLUSTERED 
(
	[DNI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Pacientes_DNI]    Script Date: 19/08/2026 10:37:21 ******/
CREATE NONCLUSTERED INDEX [IX_Pacientes_DNI] ON [dbo].[Pacientes]
(
	[DNI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Pacientes_Nombres]    Script Date: 19/08/2026 10:37:21 ******/
CREATE NONCLUSTERED INDEX [IX_Pacientes_Nombres] ON [dbo].[Pacientes]
(
	[Nombres] ASC,
	[Apellidos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Usuarios__60695A19A2BE33DF]    Script Date: 19/08/2026 10:37:21 ******/
ALTER TABLE [dbo].[Usuarios] ADD UNIQUE NONCLUSTERED 
(
	[Correo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Citas] ADD  DEFAULT ('Pendiente') FOR [Estado]
GO
ALTER TABLE [dbo].[HistorialMedico] ADD  DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [dbo].[Medicos] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [dbo].[Pacientes] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO
ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [dbo].[Citas]  WITH CHECK ADD  CONSTRAINT [FK_Citas_Medicos] FOREIGN KEY([MedicoId])
REFERENCES [dbo].[Medicos] ([MedicoId])
GO
ALTER TABLE [dbo].[Citas] CHECK CONSTRAINT [FK_Citas_Medicos]
GO
ALTER TABLE [dbo].[Citas]  WITH CHECK ADD  CONSTRAINT [FK_Citas_Pacientes] FOREIGN KEY([PacienteId])
REFERENCES [dbo].[Pacientes] ([PacienteId])
GO
ALTER TABLE [dbo].[Citas] CHECK CONSTRAINT [FK_Citas_Pacientes]
GO
ALTER TABLE [dbo].[HistorialMedico]  WITH CHECK ADD  CONSTRAINT [FK_Historial_Medicos] FOREIGN KEY([MedicoId])
REFERENCES [dbo].[Medicos] ([MedicoId])
GO
ALTER TABLE [dbo].[HistorialMedico] CHECK CONSTRAINT [FK_Historial_Medicos]
GO
ALTER TABLE [dbo].[HistorialMedico]  WITH CHECK ADD  CONSTRAINT [FK_Historial_Pacientes] FOREIGN KEY([PacienteId])
REFERENCES [dbo].[Pacientes] ([PacienteId])
GO
ALTER TABLE [dbo].[HistorialMedico] CHECK CONSTRAINT [FK_Historial_Pacientes]
GO
ALTER TABLE [dbo].[Medicos]  WITH CHECK ADD  CONSTRAINT [FK_Medicos_Especialidades] FOREIGN KEY([EspecialidadId])
REFERENCES [dbo].[Especialidades] ([EspecialidadId])
GO
ALTER TABLE [dbo].[Medicos] CHECK CONSTRAINT [FK_Medicos_Especialidades]
GO
ALTER TABLE [dbo].[Usuarios]  WITH CHECK ADD  CONSTRAINT [FK_Usuarios_Roles] FOREIGN KEY([RolId])
REFERENCES [dbo].[Roles] ([RolId])
GO
ALTER TABLE [dbo].[Usuarios] CHECK CONSTRAINT [FK_Usuarios_Roles]
GO
/****** Object:  StoredProcedure [dbo].[sp_ActualizarCita]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ActualizarCita]
    @CitaId INT,
    @PacienteId INT,
    @MedicoId INT,
    @Fecha DATE,
    @Hora TIME,
    @Motivo VARCHAR(255) = NULL,
    @Estado VARCHAR(20)
AS
BEGIN
    UPDATE Citas
    SET PacienteId = @PacienteId,
        MedicoId = @MedicoId,
        Fecha = @Fecha,
        Hora = @Hora,
        Motivo = @Motivo,
        Estado = @Estado
    WHERE CitaId = @CitaId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ActualizarEspecialidad]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ActualizarEspecialidad]
    @EspecialidadId INT,
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(255) = NULL
AS
BEGIN
    UPDATE Especialidades
    SET Nombre = @Nombre, Descripcion = @Descripcion
    WHERE EspecialidadId = @EspecialidadId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ActualizarMedico]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ActualizarMedico]
    @MedicoId INT,
    @Nombres VARCHAR(100),
    @Apellidos VARCHAR(100),
    @EspecialidadId INT,
    @Telefono VARCHAR(20) = NULL,
    @Correo VARCHAR(100) = NULL,
    @Estado BIT = 1
AS
BEGIN
    UPDATE Medicos
    SET Nombres = @Nombres,
        Apellidos = @Apellidos,
        EspecialidadId = @EspecialidadId,
        Telefono = @Telefono,
        Correo = @Correo,
        Estado = @Estado
    WHERE MedicoId = @MedicoId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ActualizarPaciente]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ActualizarPaciente]
    @PacienteId INT,
    @DNI VARCHAR(15),
    @Nombres VARCHAR(100),
    @Apellidos VARCHAR(100),
    @FechaNacimiento DATE,
    @Sexo CHAR(1),
    @Telefono VARCHAR(20) = NULL,
    @Correo VARCHAR(100) = NULL,
    @Direccion VARCHAR(200) = NULL
AS
BEGIN
    UPDATE Pacientes
    SET DNI = @DNI, Nombres = @Nombres, Apellidos = @Apellidos, FechaNacimiento = @FechaNacimiento, Sexo = @Sexo, Telefono = @Telefono, Correo = @Correo, Direccion = @Direccion
    WHERE PacienteId = @PacienteId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ActualizarUsuario]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 4. Actualizar Usuario
CREATE   PROCEDURE [dbo].[sp_ActualizarUsuario]
    @UsuarioId INT,
    @Nombre VARCHAR(100),
    @Correo VARCHAR(100),
    @Contrasena VARCHAR(255) = NULL,
    @RolId INT,
    @Estado BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Contrasena IS NOT NULL AND @Contrasena <> ''
    BEGIN
        UPDATE Usuarios
        SET Nombre = @Nombre,
            Correo = @Correo,
            Contrasena = @Contrasena,
            RolId = @RolId,
            Estado = @Estado
        WHERE UsuarioId = @UsuarioId;
    END
    ELSE
    BEGIN
        UPDATE Usuarios
        SET Nombre = @Nombre,
            Correo = @Correo,
            RolId = @RolId,
            Estado = @Estado
        WHERE UsuarioId = @UsuarioId;
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarCita]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarCita]
    @CitaId INT
AS
BEGIN
    SELECT
        c.CitaId,
        c.PacienteId,
        p.Nombres + ' ' + p.Apellidos AS NombrePaciente,
        c.MedicoId,
        m.Nombres + ' ' + m.Apellidos AS NombreMedico,
        c.Fecha,
        c.Hora,
        c.Motivo,
        c.Estado
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    WHERE c.CitaId = @CitaId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarCitasPorTexto]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarCitasPorTexto]
    @Texto VARCHAR(100)
AS
BEGIN
    SELECT
        c.CitaId,
        c.PacienteId,
        p.Nombres + ' ' + p.Apellidos AS NombrePaciente,
        c.MedicoId,
        m.Nombres + ' ' + m.Apellidos AS NombreMedico,
        c.Fecha,
        c.Hora,
        c.Motivo,
        c.Estado
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    WHERE p.Nombres    LIKE '%' + @Texto + '%'
       OR p.Apellidos  LIKE '%' + @Texto + '%'
       OR m.Nombres    LIKE '%' + @Texto + '%'
       OR m.Apellidos  LIKE '%' + @Texto + '%'
       OR c.Motivo     LIKE '%' + @Texto + '%'
    ORDER BY c.Fecha DESC, c.Hora;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarEspecialidad]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarEspecialidad]
    @EspecialidadId INT
AS
BEGIN
    SELECT * FROM Especialidades
    WHERE EspecialidadId = @EspecialidadId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarEspecialidadesPorTexto]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarEspecialidadesPorTexto]
    @Texto VARCHAR(100)
AS
BEGIN
    SELECT * FROM Especialidades
    WHERE Nombre LIKE '%' + @Texto + '%';
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarHistorial]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarHistorial]
    @HistorialId INT
AS
BEGIN
    SELECT
        h.HistorialId,
        h.PacienteId,
        p.Nombres + ' ' + p.Apellidos AS NombrePaciente,
        h.MedicoId,
        m.Nombres + ' ' + m.Apellidos AS NombreMedico,
        h.Fecha,
        h.Diagnostico,
        h.Tratamiento
    FROM HistorialMedico h
    INNER JOIN Pacientes p ON h.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON h.MedicoId = m.MedicoId
    WHERE h.HistorialId = @HistorialId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarMedico]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarMedico]
    @MedicoId INT
AS
BEGIN
    SELECT
        m.MedicoId,
        m.Nombres,
        m.Apellidos,
        m.EspecialidadId,
        e.Nombre AS NombreEspecialidad,
        m.Telefono,
        m.Correo,
        m.Estado
    FROM Medicos m
    INNER JOIN Especialidades e ON m.EspecialidadId = e.EspecialidadId
    WHERE m.MedicoId = @MedicoId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarMedicosPorTexto]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarMedicosPorTexto]
    @Texto VARCHAR(100)
AS
BEGIN
    SELECT
        m.MedicoId,
        m.Nombres,
        m.Apellidos,
        m.EspecialidadId,
        e.Nombre AS NombreEspecialidad,
        m.Telefono,
        m.Correo,
        m.Estado
    FROM Medicos m
    INNER JOIN Especialidades e ON m.EspecialidadId = e.EspecialidadId
    WHERE m.Nombres    LIKE '%' + @Texto + '%'
       OR m.Apellidos  LIKE '%' + @Texto + '%'
       OR m.Telefono   LIKE '%' + @Texto + '%'
       OR e.Nombre     LIKE '%' + @Texto + '%'
    ORDER BY m.MedicoId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarPaciente]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarPaciente]
    @PacienteId INT
AS
BEGIN
    SELECT * FROM Pacientes
    WHERE PacienteId = @PacienteId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarPacientesPorTexto]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_BuscarPacientesPorTexto]
    @Texto VARCHAR(100)
AS
BEGIN
    SELECT * FROM Pacientes
    WHERE Nombres   LIKE '%' + @Texto + '%'
       OR Apellidos LIKE '%' + @Texto + '%'
       OR DNI       LIKE '%' + @Texto + '%'
       OR Telefono  LIKE '%' + @Texto + '%';
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_BuscarUsuario]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Buscar Usuario por ID
CREATE   PROCEDURE [dbo].[sp_BuscarUsuario]
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.UsuarioId,
        u.Nombre,
        u.Correo,
        u.Contrasena,
        u.RolId,
        r.Nombre AS NombreRol,
        u.Estado,
        u.FechaCreacion
    FROM Usuarios u
    INNER JOIN Roles r ON u.RolId = r.RolId
    WHERE u.UsuarioId = @UsuarioId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CambiarEstadoCita]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_CambiarEstadoCita]
    @CitaId INT,
    @Estado VARCHAR(20)
AS
BEGIN
    UPDATE Citas
    SET Estado = @Estado
    WHERE CitaId = @CitaId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_CitasDeHoy]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_CitasDeHoy]
AS
BEGIN
    SELECT
        c.Hora,
        p.Nombres + ' ' + p.Apellidos AS Paciente,
        m.Nombres + ' ' + m.Apellidos AS Medico,
        e.Nombre AS Especialidad,
        c.Estado
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    INNER JOIN Especialidades e ON m.EspecialidadId = e.EspecialidadId
    WHERE c.Fecha = CAST(GETDATE() AS DATE)
    ORDER BY c.Hora;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ContarCitas]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 3. SP PARA CONTAR CITAS (Para calcular total de páginas)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_ContarCitas]
    @Texto VARCHAR(100) = NULL
AS
BEGIN
    SELECT COUNT(*) AS Total
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    WHERE (@Texto IS NULL OR @Texto = '')
       OR p.Nombres LIKE '%' + @Texto + '%'
       OR p.Apellidos LIKE '%' + @Texto + '%'
       OR m.Nombres LIKE '%' + @Texto + '%'
       OR m.Apellidos LIKE '%' + @Texto + '%'
       OR c.Motivo LIKE '%' + @Texto + '%';
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_DashboardTotales]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- STORED PROCEDURES: Dashboard
-- =========================================================

CREATE   PROCEDURE [dbo].[sp_DashboardTotales]
AS
BEGIN
    SELECT
        (SELECT COUNT(*) FROM Pacientes) AS TotalPacientes,
        (SELECT COUNT(*) FROM Medicos WHERE Estado = 1) AS TotalMedicos,
        (SELECT COUNT(*) FROM Citas WHERE Fecha = CAST(GETDATE() AS DATE)) AS CitasHoy,
        (SELECT COUNT(*) FROM Citas WHERE Estado = 'Pendiente') AS CitasPendientes;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_EliminarCita]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_EliminarCita]
    @CitaId INT
AS
BEGIN
    DELETE FROM Citas
    WHERE CitaId = @CitaId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_EliminarEspecialidad]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_EliminarEspecialidad]
    @EspecialidadId INT
AS
BEGIN
    DELETE FROM Especialidades
    WHERE EspecialidadId = @EspecialidadId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_EliminarMedico]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_EliminarMedico]
    @MedicoId INT
AS
BEGIN
    DELETE FROM Medicos
    WHERE MedicoId = @MedicoId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_EliminarPaciente]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_EliminarPaciente]
    @PacienteId INT
AS
BEGIN
    DELETE FROM Pacientes
    WHERE PacienteId = @PacienteId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_EliminarUsuario]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 5. Eliminar Usuario
CREATE   PROCEDURE [dbo].[sp_EliminarUsuario]
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Usuarios
    WHERE UsuarioId = @UsuarioId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarCita]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- 1. SP PARA INSERTAR CITA CON VALIDACIÓN Y TRANSACCIÓN
-- =============================================
CREATE   PROCEDURE [dbo].[sp_InsertarCita]
    @PacienteId INT,
    @MedicoId INT,
    @Fecha DATE,
    @Hora TIME,
    @Motivo VARCHAR(250)
AS
BEGIN
    BEGIN TRANSACTION;
    
    -- Validación: ¿Médico ocupado?
    IF EXISTS (SELECT 1 FROM Citas WHERE MedicoId = @MedicoId AND Fecha = @Fecha AND Hora = @Hora)
    BEGIN
        RAISERROR('El médico ya tiene una cita agendada en ese horario.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Inserción de la cita
    INSERT INTO Citas (PacienteId, MedicoId, Fecha, Hora, Motivo)
    VALUES (@PacienteId, @MedicoId, @Fecha, @Hora, @Motivo);
    
    COMMIT TRANSACTION;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarEspecialidad]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_InsertarEspecialidad]
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO Especialidades (Nombre, Descripcion)
    VALUES (@Nombre, @Descripcion);
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarHistorial]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_InsertarHistorial]
    @PacienteId INT,
    @MedicoId INT,
    @Diagnostico VARCHAR(255),
    @Tratamiento VARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO HistorialMedico (PacienteId, MedicoId, Fecha, Diagnostico, Tratamiento)
    VALUES (@PacienteId, @MedicoId, GETDATE(), @Diagnostico, @Tratamiento);
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarMedico]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_InsertarMedico]
    @Nombres VARCHAR(100),
    @Apellidos VARCHAR(100),
    @EspecialidadId INT,
    @Telefono VARCHAR(20) = NULL,
    @Correo VARCHAR(100) = NULL
AS
BEGIN
    INSERT INTO Medicos (Nombres, Apellidos, EspecialidadId, Telefono, Correo, Estado)
    VALUES (@Nombres, @Apellidos, @EspecialidadId, @Telefono, @Correo, 1);
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarPaciente]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- STORED PROCEDURES: Pacientes
-- =========================================================

CREATE   PROCEDURE [dbo].[sp_InsertarPaciente]
    @DNI VARCHAR(15),
    @Nombres VARCHAR(100),
    @Apellidos VARCHAR(100),
    @FechaNacimiento DATE,
    @Sexo CHAR(1),
    @Telefono VARCHAR(20) = NULL,
    @Correo VARCHAR(100) = NULL,
    @Direccion VARCHAR(200) = NULL
AS
BEGIN
    INSERT INTO Pacientes (DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Correo, Direccion)
    VALUES (@DNI, @Nombres, @Apellidos, @FechaNacimiento, @Sexo, @Telefono, @Correo, @Direccion);
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertarUsuario]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 3. Insertar Usuario
CREATE   PROCEDURE [dbo].[sp_InsertarUsuario]
    @Nombre VARCHAR(100),
    @Correo VARCHAR(100),
    @Contrasena VARCHAR(255),
    @RolId INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Usuarios (Nombre, Correo, Contrasena, RolId, Estado, FechaCreacion)
    VALUES (@Nombre, @Correo, @Contrasena, @RolId, 1, GETDATE());
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarCitas]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_ListarCitas]
    @pageNumber INT = 1,
    @pageSize INT = 10,
    @Texto VARCHAR(100) = ''
AS
BEGIN
    IF @pageNumber < 1 SET @pageNumber = 1;

    SELECT 
        c.CitaId,
        c.PacienteId,
        (p.Nombres + ' ' + p.Apellidos) AS NombrePaciente,
        c.MedicoId,
        (m.Nombres + ' ' + m.Apellidos) AS NombreMedico,
        c.Fecha,
        c.Hora,
        c.Motivo,
        c.Estado -- <--- AGREGA ESTA COLUMNA
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    WHERE (@Texto = '' OR @Texto IS NULL)
       OR p.Nombres LIKE '%' + @Texto + '%'
       OR p.Apellidos LIKE '%' + @Texto + '%'
       OR m.Nombres LIKE '%' + @Texto + '%'
       OR m.Apellidos LIKE '%' + @Texto + '%'
       OR c.Motivo LIKE '%' + @Texto + '%'
    ORDER BY c.Fecha DESC, c.Hora ASC
    OFFSET ((@pageNumber - 1) * @pageSize) ROWS
    FETCH NEXT @pageSize ROWS ONLY;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarEspecialidades]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- STORED PROCEDURES: Especialidades
-- =========================================================

CREATE   PROCEDURE [dbo].[sp_ListarEspecialidades]
AS
BEGIN
    SELECT * FROM Especialidades;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarHistorialPorPaciente]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- STORED PROCEDURES: HistorialMedico
-- =========================================================

CREATE   PROCEDURE [dbo].[sp_ListarHistorialPorPaciente]
    @PacienteId INT
AS
BEGIN
    SELECT
        h.HistorialId,
        h.PacienteId,
        p.Nombres + ' ' + p.Apellidos AS NombrePaciente,
        h.MedicoId,
        m.Nombres + ' ' + m.Apellidos AS NombreMedico,
        h.Fecha,
        h.Diagnostico,
        h.Tratamiento
    FROM HistorialMedico h
    INNER JOIN Pacientes p ON h.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON h.MedicoId = m.MedicoId
    WHERE h.PacienteId = @PacienteId
    ORDER BY h.Fecha DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarMedicos]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- STORED PROCEDURES: Medicos
-- =========================================================

CREATE   PROCEDURE [dbo].[sp_ListarMedicos]
AS
BEGIN
    SELECT
        m.MedicoId,
        m.Nombres,
        m.Apellidos,
        m.EspecialidadId,
        e.Nombre AS NombreEspecialidad,
        m.Telefono,
        m.Correo,
        m.Estado
    FROM Medicos m
    INNER JOIN Especialidades e ON m.EspecialidadId = e.EspecialidadId
    ORDER BY m.MedicoId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarPacientes]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ListarPacientes]
AS
BEGIN
    SELECT * FROM Pacientes;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarRoles]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 6. Listar Roles (para cargar el combo box de Roles)
CREATE   PROCEDURE [dbo].[sp_ListarRoles]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RolId, Nombre FROM Roles ORDER BY RolId;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarUsuarios]    Script Date: 19/08/2026 10:37:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================
-- STORED PROCEDURES: Usuarios
-- =========================================================

-- 1. Listar Usuarios (soporta búsqueda opcional por texto)
CREATE   PROCEDURE [dbo].[sp_ListarUsuarios]
    @texto VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        u.UsuarioId,
        u.Nombre,
        u.Correo,
        u.Contrasena,
        u.RolId,
        r.Nombre AS NombreRol,
        u.Estado,
        u.FechaCreacion
    FROM Usuarios u
    INNER JOIN Roles r ON u.RolId = r.RolId
    WHERE (@texto IS NULL OR @texto = '' 
           OR u.Nombre LIKE '%' + @texto + '%' 
           OR u.Correo LIKE '%' + @texto + '%'
           OR r.Nombre LIKE '%' + @texto + '%')
    ORDER BY u.UsuarioId DESC;
END;
GO

------------------ REPORTES


CREATE OR ALTER PROCEDURE sp_ReporteCitas_PorFecha
    @FechaDesde DATE,
    @FechaHasta DATE,
    @pageNumber INT = 1,
    @pageSize INT = 10
AS
BEGIN
    IF @pageNumber < 1 SET @pageNumber = 1;
    SELECT 
        c.CitaId,
        c.Fecha,
        c.Hora,
        p.Nombres + ' ' + p.Apellidos AS Paciente,
        m.Nombres + ' ' + m.Apellidos AS Medico,
        e.Nombre AS Especialidad,
        c.Motivo,
        c.Estado
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    INNER JOIN Especialidades e ON m.EspecialidadId = e.EspecialidadId
    WHERE c.Fecha BETWEEN @FechaDesde AND @FechaHasta
    ORDER BY c.Fecha DESC, c.Hora ASC
    OFFSET ((@pageNumber - 1) * @pageSize) ROWS
    FETCH NEXT @pageSize ROWS ONLY;
END;
GO
 
CREATE OR ALTER PROCEDURE sp_ContarReporteCitas_PorFecha
    @FechaDesde DATE,
    @FechaHasta DATE
AS
BEGIN
    SELECT COUNT(*) AS Total
    FROM Citas c
    WHERE c.Fecha BETWEEN @FechaDesde AND @FechaHasta;
END;
GO




USE [master]
GO
ALTER DATABASE [ClinicaSaludDB] SET  READ_WRITE 
GO





