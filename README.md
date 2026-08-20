# 📋 README - Módulo de Citas (ClinicaSalud)

## 🏥 Sistema de Gestión de Citas Médicas

### 📌 Resumen de Cambios y Mejoras Realizadas

Este documento detalla todas las mejoras implementadas en el módulo de **Citas** del sistema ClínicaSalud, como parte del proyecto de investigación aplicada para el curso de Desarrollo de Servicios Web I.

---

## 🎯 Objetivos del Módulo

- Implementar un CRUD completo de citas médicas con arquitectura limpia (MVC)
- Aplicar principios de separación de responsabilidades (Repository Pattern)
- Demostrar el uso de transacciones tanto en SQL Server como en C#
- Implementar paginación eficiente con OFFSET/FETCH
- Cumplir con los criterios de la rúbrica de evaluación del proyecto

---

## 🔧 Mejoras Implementadas

### 1. Arquitectura y Patrones de Diseño

#### 🏗️ Repository Pattern

- **Antes**: Lógica de negocio y acceso a datos en el controlador.
- **Ahora**: Separación clara con interfaces y repositorios.

```csharp
// Interfaz
public interface ICitaRepository
{
    IEnumerable<Cita> ListarCitas(int pageNumber, int pagesize, string texto = "");
    int ContarCitas(string texto = "");
    string Registrar(Cita objCita);
    Cita Buscar(int id);
    string Actualizar(Cita objCita);
    string Delete(int id);
}
```

#### 💉 Inyección de Dependencias

- **Agregado**: Inyección de dependencias en el controlador.
- **Beneficio**: Código más testeable y desacoplado.

```csharp
public CitasController(ICitaRepository citaRepo, IPacienteRepository pacienteRepo, IMedicoRepository medicoRepo)
{
    _citaRepo = citaRepo;
    _pacienteRepo = pacienteRepo;
    _medicoRepo = medicoRepo;
}
```

---

### 2. Transacciones y Lógica de Negocio

#### 🔄 Transacciones en C# (Repository)

- **Agregado**: Uso de `SqlTransaction` en los métodos `Actualizar` y `Delete`.

```csharp
public string Actualizar(Cita objCita)
{
    using (SqlConnection cn = new SqlConnection(con))
    {
        cn.Open();
        using (SqlTransaction tx = cn.BeginTransaction())
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("sp_ActualizarCita", cn, tx))
                {
                    // Ejecutar comando
                }
                tx.Commit();
            }
            catch
            {
                tx.Rollback();
            }
        }
    }
}
```

#### 🗄️ Transacciones en SQL Server

- **Agregado**: Validación de disponibilidad y `BEGIN TRANSACTION` en el SP.

```sql
CREATE OR ALTER PROCEDURE sp_InsertarCita
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
    
    INSERT INTO Citas (...);
    COMMIT TRANSACTION;
END
```

---

### 3. Paginación Eficiente

#### 📄 OFFSET / FETCH en SQL

- **Agregado**: Paginación a nivel de base de datos con `OFFSET` y `FETCH NEXT`.

```sql
CREATE OR ALTER PROCEDURE sp_ListarCitas
    @pageNumber INT = 0,
    @pagesize INT = 10
AS
BEGIN
    SELECT ...
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    ORDER BY c.Fecha DESC, c.Hora
    OFFSET (@pageNumber * @pagesize) ROWS
    FETCH NEXT @pagesize ROWS ONLY;
END
```

#### 🔢 Método para Contar Registros

- **Agregado**: `sp_ContarCitas` para calcular total de páginas.

```sql
CREATE OR ALTER PROCEDURE sp_ContarCitas
    @Texto VARCHAR(100) = NULL
AS
BEGIN
    SELECT COUNT(*) AS Total
    FROM Citas c
    INNER JOIN Pacientes p ON c.PacienteId = p.PacienteId
    INNER JOIN Medicos m ON c.MedicoId = m.MedicoId
    WHERE @Texto IS NULL
       OR p.Nombres LIKE '%' + @Texto + '%'
       OR p.Apellidos LIKE '%' + @Texto + '%'
       OR m.Nombres LIKE '%' + @Texto + '%'
       OR m.Apellidos LIKE '%' + @Texto + '%'
       OR c.Motivo LIKE '%' + @Texto + '%';
END
```

#### 🎨 Vista con Paginación

- **Agregado**: Visualización correcta de páginas con `ViewBag.paginas`.

```html
<ul class="pagination justify-content-center mb-0">
    @for (int i = 0; i < (int)ViewBag.paginas; i++)
    {
        <li class="page-item @(i == (int)ViewBag.pageNumber ? "active" : "")">
            <a class="page-link" asp-action="ListadoCitas" 
               asp-route-pageNumber="@i" 
               asp-route-texto="@ViewBag.texto">@(i + 1)</a>
        </li>
    }
</ul>
```

# **Mejoras implementadas version 3**

### ✅ **Módulo Reportes (nuevo)**

- **SPs:** `sp_ReporteCitas_PorFecha` y `sp_ContarReporteCitas_PorFecha`
    
- **Modelo:** `ReporteCita.cs`
    
- **Interfaz:** `IReporteRepository`
    
- **Repositorio:** `ReporteRepository`
    
- **Controlador:** `ReportesController` con validación de fechas incoherentes
    
- **Vista:** `Views/Reportes/Index.cshtml` con filtros, tabla y paginación
    

---

### 2. 🗄️ **BASE DE DATOS (Nuevos SPs)**

|SP|Función|
|---|---|
|`sp_ReporteCitas_PorFecha`|Lista citas en un rango de fechas con paginación (`OFFSET FETCH`).|
|`sp_ContarReporteCitas_PorFecha`|Cuenta el total de citas en el rango para la paginación.|

**Mejora:** Ambos SPs usan `OFFSET FETCH` (paginación eficiente en el servidor).

---

### 3. 📁 **NUEVOS ARCHIVOS CREADOS**

| Archivo                 | Ubicación         | Propósito                                          |
| ----------------------- | ----------------- | -------------------------------------------------- |
| `ReporteCita.cs`        | `Models/`         | Modelo DTO para mostrar datos en el reporte.       |
| `IReporteRepository.cs` | `Repository/`     | Interfaz con los métodos del repositorio.          |
| `ReporteRepository.cs`  | `Repository/`     | Implementación de acceso a datos.                  |
| `ReportesController.cs` | `Controllers/`    | Controlador con validación de fechas incoherentes. |
| `Index.cshtml`          | `Views/Reportes/` | Vista con filtros, tabla y paginación.             |

---

### 4. ✅ **VALIDACIONES IMPLEMENTADAS**

| Módulo        | Validación                                              | Tipo     | ¿Dónde?                              |
| ------------- | ------------------------------------------------------- | -------- | ------------------------------------ |
| **Pacientes** | Fecha de nacimiento futura                              | Servidor | Controlador                          |
| **Citas**     | Fecha de cita pasada                                    | Servidor | Controlador                          |
| **Citas**     | Conflicto de horario (mismo médico, misma fecha y hora) | Servidor | SP `sp_InsertarCita` con `RAISERROR` |
| **Reportes**  | Fecha Desde > Fecha Hasta                               | Servidor | Controlador (con `TempData`)         |

**Mensajes al usuario:** Uso de `TempData["mensaje"]` para éxito y `TempData["error"]` para errores.

---

### 5. 🔧 **MEJORAS EN CONTROLADORES EXISTENTES**

| Controlador           | Mejora                                                                          |
| --------------------- | ------------------------------------------------------------------------------- |
| `PacientesController` | Validación de fecha futura + `ModelState.IsValid` + `return View("Nuevo", obj)` |
| `CitasController`     | Validación de fecha pasada + `ViewBag` recargado cuando hay error               |
| `ReportesController`  | Validación de fechas incoherentes + mensaje en `TempData`                       |

---


### 📋 Aporte técnico 

#### 1. Arquitectura y separación de capas

- Diseño e implementación del **Repository Pattern** completo en el módulo de **Pacientes/Clientes**: interfaz (`IPacienteRepository`) + implementación (`PacienteRepository`), desacoplando el acceso a datos del controlador.
- Aplicación del mismo patrón desde cero en el **módulo de Reportes** (interfaz, repositorio, modelo DTO).
- Inyección de dependencias configurada para ambos módulos, integrándolos al esquema de DI ya existente en el proyecto.

#### 2. Transacciones (C# + SQL)

- Implementación de **`SqlTransaction`** en C# dentro del repositorio de Citas, en las operaciones de `Actualizar` y `Delete`, con manejo de `Commit`/`Rollback` ante excepciones.
- Implementación de **transacción a nivel SQL** (`BEGIN TRANSACTION` / `ROLLBACK` / `RAISERROR`) en el stored procedure `sp_InsertarCita`, para garantizar atomicidad entre la validación de conflicto de horario y la inserción.

#### 3. Paginación eficiente

- Introducción del patrón **`OFFSET`/`FETCH NEXT`** a nivel de SQL Server (en lugar de paginar en memoria desde C#) en el módulo de **Pacientes/Clientes**.
- Replicación del mismo patrón en los SPs nuevos del módulo de Reportes (`sp_ReporteCitas_PorFecha`, `sp_ContarReporteCitas_PorFecha`).

#### 4. Validaciones de servidor y depuración

- Corrección de un bug de validación en el módulo de Citas relacionado con el binding de propiedades no enviadas por el formulario (`NombrePaciente`, `NombreMedico`, `Estado`), usando nullable reference types y manejo explícito de `ModelState`.
- Validación de fecha de nacimiento futura en Pacientes.
- Validación de fecha de cita pasada en Citas.
- Validación de coherencia de rango de fechas (Desde > Hasta) en Reportes, con mensajes vía `TempData`.

#### 5. Módulo de Reportes (completo)

- Modelo, interfaz, repositorio, controlador y vista implementados de punta a punta, incluyendo filtros por rango de fechas y paginación.

---

