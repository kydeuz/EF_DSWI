-- =========================================================
-- BASE DE DATOS: Sistema Clinico
-- =========================================================

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

CREATE OR ALTER PROCEDURE sp_InsertarPaciente
    @DNI VARCHAR(15),
    @Nombres VARCHAR(100),
    @Apellidos VARCHAR(100),
    @FechaNacimiento DATE,
    @Sexo CHAR(1),
    @Telefono VARCHAR(20),
    @Correo VARCHAR(100) ,
    @Direccion VARCHAR(200) 
AS
BEGIN
    INSERT INTO Pacientes (DNI, Nombres, Apellidos, FechaNacimiento, Sexo, Telefono, Correo, Direccion)
    VALUES (@DNI, @Nombres, @Apellidos, @FechaNacimiento, @Sexo, @Telefono, @Correo, @Direccion);
END;
GO

EXEC sp_InsertarPaciente
    @DNI = '12345678',
    @Nombres = 'Juan',
    @Apellidos = 'Perez',
    @FechaNacimiento = '1995-05-10',
    @Sexo = 'M',
    @Telefono = '987654321',
    @Correo = 'juan@gmail.com',
    @Direccion = 'Av. Lima 123';
GO

CREATE OR ALTER PROCEDURE sp_ListarPacientes
AS
BEGIN
    SELECT * FROM Pacientes
    ORDER BY PacienteId
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

EXEC sp_ActualizarPaciente
    @PacienteId = 1,
    @DNI = '12345655',
    @Nombres = 'Juan',
    @Apellidos = 'Perez',
    @FechaNacimiento = '1995-05-10',
    @Sexo = 'M',
    @Telefono = '987654321',
    @Correo = 'juan@gmail.com',
    @Direccion = 'Av. Lima 123';
GO

EXEC sp_ListarPacientes;
GO

SELECT * FROM Pacientes;
GO

CREATE OR ALTER PROCEDURE sp_BuscarPacientesPorTexto
    @Texto VARCHAR(100)
AS
BEGIN
    SELECT * FROM Pacientes
    WHERE Nombres  LIKE '%' + @Texto + '%'
       OR Apellidos LIKE '%' + @Texto + '%'
       OR DNI       LIKE '%' + @Texto + '%'
       OR Telefono  LIKE '%' + @Texto + '%';
END;
GO

EXEC sp_BuscarPacientesPorTexto @Texto = 'fernando';
GO

CREATE OR ALTER PROCEDURE sp_EliminarPaciente
    @PacienteId INT
AS
BEGIN
    DELETE FROM Pacientes
    WHERE PacienteId = @PacienteId;
END;
GO

EXEC sp_EliminarPaciente
    @PacienteId = 1;
GO

CREATE OR ALTER PROCEDURE sp_BuscarPaciente
    @PacienteId INT
AS
BEGIN
    SELECT * FROM Pacientes
    WHERE PacienteId = @PacienteId;
END;
GO

EXEC sp_BuscarPaciente
    @PacienteId = 1;
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
-- INDICES DE APOYO (para las busquedas del mockup)
-- =========================================================
CREATE INDEX IX_Pacientes_Nombres ON Pacientes(Nombres, Apellidos);
CREATE INDEX IX_Pacientes_DNI ON Pacientes(DNI);
CREATE INDEX IX_Citas_Fecha ON Citas(Fecha);
CREATE INDEX IX_Historial_Paciente ON HistorialMedico(PacienteId);
GO

-- =========================================================
-- DATOS BASE (opcional, para poder probar el sistema)
-- =========================================================
INSERT INTO Roles (Nombre) VALUES ('Administrador'), ('Recepcionista'), ('Medico');
GO

INSERT INTO Especialidades (Nombre, Descripcion) VALUES
('Cardiologia', 'Enfermedades del corazon'),
('Pediatria', 'Atencion a ninos'),
('Traumatologia', 'Lesiones y huesos');
GO

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
    @pageNumber INT = 0,
    @pagesize INT = 10
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
    ORDER BY c.Fecha DESC, c.Hora
    OFFSET (@pageNumber * @pagesize) ROWS
    FETCH NEXT @pagesize ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE sp_BuscarCitasPorTexto
    @Texto VARCHAR(100),
    @pageNumber INT = 0,
    @pagesize INT = 10
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
    ORDER BY c.Fecha DESC, c.Hora
    OFFSET (@pageNumber * @pagesize) ROWS
    FETCH NEXT @pagesize ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE sp_ContarCitas
    @Texto VARCHAR(100) = NULL
AS
BEGIN
    SELECT COUNT(*) AS Total
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    WHERE @Texto IS NULL
       OR p.Nombres    LIKE '%' + @Texto + '%'
       OR p.Apellidos  LIKE '%' + @Texto + '%'
       OR m.Nombres    LIKE '%' + @Texto + '%'
       OR m.Apellidos  LIKE '%' + @Texto + '%'
       OR c.Motivo     LIKE '%' + @Texto + '%';
END;
GO

CREATE OR ALTER PROCEDURE sp_InsertarCita
    @PacienteId INT,
    @MedicoId INT,
    @Fecha DATE,
    @Hora TIME,
    @Motivo VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;  -- <--- PUNTO 1: Transacción explícita 

    BEGIN TRY
        -- PUNTO 2: Validación de negocio (¿Médico ocupado a esa hora?)
        IF EXISTS (
            SELECT 1 FROM Citas 
            WHERE MedicoId = @MedicoId 
              AND Fecha = @Fecha 
              AND Hora = @Hora
        )
        BEGIN
            -- Lanzamos un error personalizado
            RAISERROR('El médico ya tiene una cita agendada en ese horario.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Si pasa la validación, INSERTAMOS
        INSERT INTO Citas (PacienteId, MedicoId, Fecha, Hora, Motivo, Estado)
        VALUES (@PacienteId, @MedicoId, @Fecha, @Hora, @Motivo, 'Pendiente');

        COMMIT TRANSACTION;  -- <--- Confirmamos el cambio

        -- Retornamos 1 fila afectada para que el ExecuteNonQuery lo detecte
        SELECT 1 AS Resultado;

    END TRY
    BEGIN CATCH
        -- Si algo sale mal, deshacemos todo
        ROLLBACK TRANSACTION;
        -- Relanzamos el error para que llegue al C# (o lo capturamos)
        THROW;
    END CATCH
END
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

-- Detalle de un solo registro (ej. al hacer click en el icono "ver" del mockup)
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
