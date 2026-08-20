-- =========================================================
-- BASE DE DATOS: Sistema Clinico (ClinicaSaludDB)
-- Version ultima
-- =========================================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'ClinicaSaludDB')
BEGIN
    ALTER DATABASE ClinicaSaludDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ClinicaSaludDB;
END
GO

CREATE DATABASE ClinicaSaludDB;
GO

USE ClinicaSaludDB;
GO

-- =========================================================
-- TABLA: Roles
-- =========================================================
CREATE TABLE Roles (
    RolId       INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(50) NOT NULL   -- Admin, Recepcionista, Medico
);
GO

-- =========================================================
-- TABLA: Usuarios
-- =========================================================
CREATE TABLE Usuarios (
    UsuarioId       INT IDENTITY(1,1) PRIMARY KEY,
    Nombre          VARCHAR(100) NOT NULL,
    Correo          VARCHAR(100) NOT NULL UNIQUE,
    Contrasena      VARCHAR(255) NOT NULL,   -- guardar hash, nunca texto plano
    RolId           INT NOT NULL,
    Estado          BIT NOT NULL DEFAULT 1,
    FechaCreacion   DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (RolId) REFERENCES Roles(RolId)
);
GO

-- =========================================================
-- TABLA: Especialidades
-- =========================================================
CREATE TABLE Especialidades (
    EspecialidadId  INT IDENTITY(1,1) PRIMARY KEY,
    Nombre          VARCHAR(100) NOT NULL,
    Descripcion     VARCHAR(255) NULL
);
GO

-- =========================================================
-- TABLA: Medicos
-- =========================================================
CREATE TABLE Medicos (
    MedicoId        INT IDENTITY(1,1) PRIMARY KEY,
    Nombres         VARCHAR(100) NOT NULL,
    Apellidos       VARCHAR(100) NOT NULL,
    EspecialidadId  INT NOT NULL,
    Telefono        VARCHAR(20) NULL,
    Correo          VARCHAR(100) NULL,
    Estado          BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Medicos_Especialidades FOREIGN KEY (EspecialidadId) REFERENCES Especialidades(EspecialidadId)
);
GO

-- =========================================================
-- TABLA: Pacientes
-- =========================================================
CREATE TABLE Pacientes (
    PacienteId       INT IDENTITY(1,1) PRIMARY KEY,
    DNI              VARCHAR(15) NOT NULL UNIQUE,
    Nombres          VARCHAR(100) NOT NULL,
    Apellidos        VARCHAR(100) NOT NULL,
    FechaNacimiento  DATE NOT NULL,
    Sexo             CHAR(1) NOT NULL,        -- 'M' o 'F'
    Telefono         VARCHAR(20) NULL,
    Correo           VARCHAR(100) NULL,
    Direccion        VARCHAR(200) NULL,
    FechaRegistro    DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- =========================================================
-- TABLA: Citas
-- =========================================================
CREATE TABLE Citas (
    CitaId      INT IDENTITY(1,1) PRIMARY KEY,
    PacienteId  INT NOT NULL,
    MedicoId    INT NOT NULL,
    Fecha       DATE NOT NULL,
    Hora        TIME NOT NULL,
    Motivo      VARCHAR(255) NULL,
    Estado      VARCHAR(20) NOT NULL DEFAULT 'Pendiente',  -- Pendiente / Atendida / Cancelada
    CONSTRAINT FK_Citas_Pacientes FOREIGN KEY (PacienteId) REFERENCES Pacientes(PacienteId),
    CONSTRAINT FK_Citas_Medicos   FOREIGN KEY (MedicoId)   REFERENCES Medicos(MedicoId)
);
GO

-- =========================================================
-- TABLA: HistorialMedico
-- =========================================================
CREATE TABLE HistorialMedico (
    HistorialId  INT IDENTITY(1,1) PRIMARY KEY,
    PacienteId   INT NOT NULL,
    MedicoId     INT NOT NULL,
    Fecha        DATE NOT NULL DEFAULT GETDATE(),
    Diagnostico  VARCHAR(255) NOT NULL,
    Tratamiento  VARCHAR(255) NULL,
    CONSTRAINT FK_Historial_Pacientes FOREIGN KEY (PacienteId) REFERENCES Pacientes(PacienteId),
    CONSTRAINT FK_Historial_Medicos   FOREIGN KEY (MedicoId)   REFERENCES Medicos(MedicoId)
);
GO

-- =========================================================
-- INDICES DE APOYO (para las busquedas)
-- =========================================================
CREATE INDEX IX_Pacientes_Nombres ON Pacientes(Nombres, Apellidos);
CREATE INDEX IX_Pacientes_DNI ON Pacientes(DNI);
CREATE INDEX IX_Citas_Fecha ON Citas(Fecha);
CREATE INDEX IX_Historial_Paciente ON HistorialMedico(PacienteId);
GO

-- =========================================================
-- DATOS DE PRUEBA (los mismos de final.sql, mismos IDs)
-- Orden ajustado por las FK: Roles/Especialidades -> Medicos/Usuarios
-- -> Pacientes -> Citas
-- =========================================================

SET IDENTITY_INSERT Roles ON;
INSERT INTO Roles (RolId, Nombre) VALUES (1, N'Administrador');
INSERT INTO Roles (RolId, Nombre) VALUES (2, N'Recepcionista');
INSERT INTO Roles (RolId, Nombre) VALUES (3, N'Medico');
SET IDENTITY_INSERT Roles OFF;
GO

SET IDENTITY_INSERT Especialidades ON;
INSERT INTO Especialidades (EspecialidadId, Nombre, Descripcion) VALUES (1, N'Cardiologia', N'Enfermedades del corazon');
INSERT INTO Especialidades (EspecialidadId, Nombre, Descripcion) VALUES (2, N'Pediatria', N'Atencion a ninos');
INSERT INTO Especialidades (EspecialidadId, Nombre, Descripcion) VALUES (3, N'Traumatologia', N'Lesiones y huesos');
SET IDENTITY_INSERT Especialidades OFF;
GO

SET IDENTITY_INSERT Medicos ON;
INSERT INTO Medicos (MedicoId, Nombres, Apellidos, EspecialidadId, Telefono, Correo, Estado) VALUES (1, N'Chapatin', N'Chespirito', 2, N'888888888', N'Ch-8@gmail.com', 1);
SET IDENTITY_INSERT Medicos OFF;
GO

SET IDENTITY_INSERT Usuarios ON;
INSERT INTO Usuarios (UsuarioId, Nombre, Correo, Contrasena, RolId, Estado, FechaCreacion) VALUES (1, N'Admin', N'admin@clinica.com', N'12345', 1, 1, CAST(N'2026-08-17T22:23:48.473' AS DateTime));
INSERT INTO Usuarios (UsuarioId, Nombre, Correo, Contrasena, RolId, Estado, FechaCreacion) VALUES (2, N'Luca', N'luca@clinica.com', N'54321', 1, 1, CAST(N'2026-08-17T23:19:59.587' AS DateTime));
SET IDENTITY_INSERT Usuarios OFF;
GO

SET IDENTITY_INSERT Pacientes ON;
INSERT INTO Pacientes (PacienteId, DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Correo, Direccion, FechaRegistro) VALUES (1, N'12345655', N'Juan', N'Perez', CAST(N'1995-05-10' AS Date), N'M', N'987654321', N'juan@gmail.com', N'Av. Lima 123', CAST(N'2026-08-17T13:50:56.283' AS DateTime));
SET IDENTITY_INSERT Pacientes OFF;
GO

SET IDENTITY_INSERT Citas ON;
INSERT INTO Citas (CitaId, PacienteId, MedicoId, Fecha, Hora, Motivo, Estado) VALUES (1, 1, 1, CAST(N'2026-08-17' AS Date), CAST(N'17:24:00' AS Time), N'Revicion de prostata', N'Pendiente');
SET IDENTITY_INSERT Citas OFF;
GO

-- =========================================================
-- STORED PROCEDURES: Pacientes
-- =========================================================

CREATE OR ALTER PROCEDURE sp_InsertarPaciente
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

CREATE OR ALTER PROCEDURE sp_ListarPacientes
AS
BEGIN
    SELECT * FROM Pacientes;
END;
GO

CREATE OR ALTER PROCEDURE sp_ActualizarPaciente
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

CREATE OR ALTER PROCEDURE sp_BuscarPacientesPorTexto
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

CREATE OR ALTER PROCEDURE sp_EliminarPaciente
    @PacienteId INT
AS
BEGIN
    DELETE FROM Pacientes
    WHERE PacienteId = @PacienteId;
END;
GO

CREATE OR ALTER PROCEDURE sp_BuscarPaciente
    @PacienteId INT
AS
BEGIN
    SELECT * FROM Pacientes
    WHERE PacienteId = @PacienteId;
END;
GO

-- =========================================================
-- STORED PROCEDURES: Especialidades
-- =========================================================

CREATE OR ALTER PROCEDURE sp_ListarEspecialidades
AS
BEGIN
    SELECT * FROM Especialidades;
END;
GO

CREATE OR ALTER PROCEDURE sp_BuscarEspecialidadesPorTexto
    @Texto VARCHAR(100)
AS
BEGIN
    SELECT * FROM Especialidades
    WHERE Nombre LIKE '%' + @Texto + '%';
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarEspecialidad
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(255) = NULL
AS
BEGIN
    INSERT INTO Especialidades (Nombre, Descripcion)
    VALUES (@Nombre, @Descripcion);
END;
GO

CREATE OR ALTER PROCEDURE sp_ActualizarEspecialidad
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

CREATE OR ALTER PROCEDURE sp_EliminarEspecialidad
    @EspecialidadId INT
AS
BEGIN
    DELETE FROM Especialidades
    WHERE EspecialidadId = @EspecialidadId;
END;
GO

CREATE OR ALTER PROCEDURE sp_BuscarEspecialidad
    @EspecialidadId INT
AS
BEGIN
    SELECT * FROM Especialidades
    WHERE EspecialidadId = @EspecialidadId;
END;
GO

-- =========================================================
-- STORED PROCEDURES: Medicos
-- =========================================================

CREATE OR ALTER PROCEDURE sp_ListarMedicos
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

CREATE OR ALTER PROCEDURE sp_BuscarMedicosPorTexto
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

CREATE OR ALTER PROCEDURE sp_InsertarMedico
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

CREATE OR ALTER PROCEDURE sp_ActualizarMedico
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

CREATE OR ALTER PROCEDURE sp_EliminarMedico
    @MedicoId INT
AS
BEGIN
    DELETE FROM Medicos
    WHERE MedicoId = @MedicoId;
END;
GO

CREATE OR ALTER PROCEDURE sp_BuscarMedico
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

-- =========================================================
-- STORED PROCEDURES: Citas
-- =========================================================

CREATE OR ALTER PROCEDURE sp_ListarCitas
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
        c.Estado 
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

CREATE OR ALTER PROCEDURE sp_BuscarCitasPorTexto
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

-- =============================================
-- SP PARA CONTAR CITAS (Para calcular total de paginas)
-- =============================================
CREATE OR ALTER PROCEDURE sp_ContarCitas
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

-- =============================================
-- SP PARA INSERTAR CITA CON VALIDACION Y TRANSACCION
-- =============================================
CREATE OR ALTER PROCEDURE sp_InsertarCita
    @PacienteId INT,
    @MedicoId INT,
    @Fecha DATE,
    @Hora TIME,
    @Motivo VARCHAR(250)
AS
BEGIN
    BEGIN TRANSACTION;
    
    -- Validacion: ¿Medico ocupado?
    IF EXISTS (SELECT 1 FROM Citas WHERE MedicoId = @MedicoId AND Fecha = @Fecha AND Hora = @Hora)
    BEGIN
        RAISERROR('El médico ya tiene una cita agendada en ese horario.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Insercion de la cita
    INSERT INTO Citas (PacienteId, MedicoId, Fecha, Hora, Motivo)
    VALUES (@PacienteId, @MedicoId, @Fecha, @Hora, @Motivo);
    
    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE sp_ActualizarCita
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

CREATE OR ALTER PROCEDURE sp_EliminarCita
    @CitaId INT
AS
BEGIN
    DELETE FROM Citas
    WHERE CitaId = @CitaId;
END;
GO

CREATE OR ALTER PROCEDURE sp_BuscarCita
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

-- Opcional: cambiar solo el estado sin editar toda la cita
CREATE OR ALTER PROCEDURE sp_CambiarEstadoCita
    @CitaId INT,
    @Estado VARCHAR(20)
AS
BEGIN
    UPDATE Citas
    SET Estado = @Estado
    WHERE CitaId = @CitaId;
END;
GO

-- =========================================================
-- STORED PROCEDURES: HistorialMedico
-- =========================================================

-- Trae todo el historial de UN paciente (para la ficha del paciente)
CREATE OR ALTER PROCEDURE sp_ListarHistorialPorPaciente
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

CREATE OR ALTER PROCEDURE sp_InsertarHistorial
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

-- Detalle de un solo registro (ej. al hacer click en el icono "ver")
CREATE OR ALTER PROCEDURE sp_BuscarHistorial
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

-- =========================================================
-- STORED PROCEDURES: Usuarios
-- =========================================================

-- 1. Listar Usuarios (soporta busqueda opcional por texto)
CREATE OR ALTER PROCEDURE sp_ListarUsuarios
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

-- 2. Buscar Usuario por ID
CREATE OR ALTER PROCEDURE sp_BuscarUsuario
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

-- 3. Insertar Usuario
CREATE OR ALTER PROCEDURE sp_InsertarUsuario
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

-- 4. Actualizar Usuario
CREATE OR ALTER PROCEDURE sp_ActualizarUsuario
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

-- 5. Eliminar Usuario
CREATE OR ALTER PROCEDURE sp_EliminarUsuario
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Usuarios
    WHERE UsuarioId = @UsuarioId;
END;
GO

-- 6. Listar Roles (para cargar el combo box de Roles)
CREATE OR ALTER PROCEDURE sp_ListarRoles
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RolId, Nombre FROM Roles ORDER BY RolId;
END;
GO

-- =========================================================
-- STORED PROCEDURES: Dashboard
-- =========================================================

-- Devuelve una sola fila con los 4 totales de las tarjetas
CREATE OR ALTER PROCEDURE sp_DashboardTotales
AS
BEGIN
    SELECT
        (SELECT COUNT(*) FROM Pacientes) AS TotalPacientes,
        (SELECT COUNT(*) FROM Medicos WHERE Estado = 1) AS TotalMedicos,
        (SELECT COUNT(*) FROM Citas WHERE Fecha = CAST(GETDATE() AS DATE)) AS CitasHoy,
        (SELECT COUNT(*) FROM Citas WHERE Estado = 'Pendiente') AS CitasPendientes;
END;
GO

-- Lista de citas agendadas para hoy, para la tabla "Citas de hoy"
CREATE OR ALTER PROCEDURE sp_CitasDeHoy
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

-- =========================================================
-- STORED PROCEDURES: Reportes
-- =========================================================

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
