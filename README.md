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

- Diseño e implementación del **Repository Pattern** completo en el módulo de **Citas** .
- Aplicación del mismo patrón desde cero en el **módulo de Reportes** (interfaz, repositorio, modelo DTO).
- Inyección de dependencias configurada para ambos módulos, integrándolos al esquema de DI ya existente en el proyecto.

#### 2. Transacciones (C# + SQL)

- Implementación de **`SqlTransaction`** en C# dentro del repositorio de Citas, en las operaciones de `Actualizar` y `Delete`, con manejo de `Commit`/`Rollback` ante excepciones.
- Implementación de **transacción a nivel SQL** (`BEGIN TRANSACTION` / `ROLLBACK` / `RAISERROR`) en el stored procedure `sp_InsertarCita`, para garantizar atomicidad entre la validación de conflicto de horario y la inserción.

#### 3. Paginación eficiente

- Introducción del patrón **`OFFSET`/`FETCH NEXT`** a nivel de SQL Server (en lugar de paginar en memoria desde C#) en el módulo de **Citas**.
- Replicación del mismo patrón en los SPs nuevos del módulo de Reportes (`sp_ReporteCitas_PorFecha`, `sp_ContarReporteCitas_PorFecha`).

#### 4. Validaciones de servidor y depuración

- Corrección de un bug de validación en el módulo de Citas relacionado con el binding de propiedades no enviadas por el formulario (`NombrePaciente`, `NombreMedico`, `Estado`), usando nullable reference types y manejo explícito de `ModelState`.
- Validación de fecha de nacimiento futura en Pacientes.
- Validación de fecha de cita pasada en Citas.
- Validación de coherencia de rango de fechas (Desde > Hasta) en Reportes, con mensajes vía `TempData`.

#### 5. Módulo de Reportes (completo)

- Modelo, interfaz, repositorio, controlador y vista implementados de punta a punta, incluyendo filtros por rango de fechas y paginación.

---

## 📋 Aportes Técnicos — Versión Final

Esta sección documenta tres mejoras adicionales incorporadas en la etapa final del proyecto, orientadas a cerrar brechas de integridad de datos y de experiencia de usuario que no estaban cubiertas en versiones anteriores del módulo.

---

### 1. Manejo de Errores de Integridad Referencial en Operaciones DELETE

**Contexto del hallazgo**

Durante una auditoría del código se identificó que los stored procedures `sp_EliminarPaciente`, `sp_EliminarMedico` y `sp_EliminarEspecialidad` ejecutaban un `DELETE` directo sin validar previamente si la fila estaba referenciada por llave foránea en `Citas` o `HistorialMedico`.

La restricción de integridad referencial (FK) ya cumplía su función a nivel de motor — SQL Server rechazaba correctamente el borrado —, pero la excepción se propagaba sin transformar hasta la capa de presentación, exponiendo al usuario final el mensaje crudo del motor de base de datos (`The DELETE statement conflicted with the REFERENCE constraint...`).

**Solución implementada**

Se aplicó el mismo patrón de validación ya establecido en `sp_InsertarCita`: verificación de la regla de negocio mediante `EXISTS` antes de ejecutar la operación, y emisión de un error controlado con `RAISERROR` de severidad 16 para producir un mensaje legible en lenguaje de negocio.

```sql
CREATE OR ALTER PROCEDURE sp_EliminarPaciente
    @PacienteId INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Citas WHERE PacienteId = @PacienteId)
       OR EXISTS (SELECT 1 FROM HistorialMedico WHERE PacienteId = @PacienteId)
    BEGIN
        RAISERROR('No se puede eliminar el paciente: tiene citas o historial médico asociado.', 16, 1);
        RETURN;
    END

    DELETE FROM Pacientes WHERE PacienteId = @PacienteId;
END
```

El mismo patrón se replicó en `sp_EliminarMedico` y `sp_EliminarEspecialidad`, ajustando las tablas dependientes según corresponda a cada entidad.

**Impacto en la capa de acceso a datos**

Al existir ya un bloque `try/catch` capturando `SqlException` en los métodos `Delete` del repositorio, no fue necesario modificar código C#. El mensaje generado por `RAISERROR` se propaga como `SqlException.Message`, es capturado por el `catch` existente y mostrado al usuario vía `TempData`, sin cambios adicionales en la capa de aplicación.

**Justificación técnica del aporte**

| Criterio | Detalle |
|---|---|
| Origen del hallazgo | Detectado mediante auditoría propia del código heredado, no asignado explícitamente. |
| Consistencia de diseño | Reutiliza un patrón ya presente en el proyecto (`sp_InsertarCita`), en lugar de introducir uno nuevo. |
| Riesgo de regresión | Nulo — no se modificó la capa C#; el cambio queda contenido en la capa de datos. |
| Cobertura | Aplica de forma uniforme a las tres entidades con relaciones dependientes (`Paciente`, `Medico`, `Especialidad`). |

---

### 2. Prevención de Condiciones de Carrera en el Agendamiento de Citas

**Problema identificado**

La validación de disponibilidad en `sp_InsertarCita` se basa en `IF EXISTS (...)` seguido de un `INSERT`. Al ser dos operaciones separadas en el tiempo, existe una ventana entre la lectura y la escritura durante la cual dos transacciones concurrentes pueden evaluar `EXISTS` como falso antes de que cualquiera de las dos haya confirmado su `INSERT`. En un escenario de dos usuarios agendando al mismo médico, misma fecha y misma hora de forma casi simultánea, ambas validaciones pueden pasar sin detectar conflicto entre sí, resultando en una fila duplicada real en la tabla `Citas`.

**Solución: defensa en profundidad**

Se agregó una restricción `UNIQUE` a nivel de motor sobre la combinación `(MedicoId, Fecha, Hora)`, que actúa como garantía de integridad independiente del timing de las transacciones:

```sql
ALTER TABLE Citas
ADD CONSTRAINT UQ_Citas_Medico_Fecha_Hora UNIQUE (MedicoId, Fecha, Hora);
```

Esta restricción **no reemplaza** la validación `EXISTS` existente, sino que la complementa: el `EXISTS` sigue resolviendo el caso normal (99% de los casos) con un mensaje de negocio claro; el `UNIQUE constraint` cubre el caso límite de concurrencia que el `EXISTS` no puede resolver estructuralmente, al operar de forma atómica en el motor en el momento exacto del `INSERT`.

**Manejo de la excepción en la capa de datos**

Ante un choque contra la restricción `UNIQUE`, SQL Server devuelve un mensaje de sistema poco amigable (`Violation of UNIQUE KEY constraint 'UQ_Citas_Medico_Fecha_Hora'...`). Se agregó manejo específico en `CitaRepositorio.Registrar` para traducir ese caso a un mensaje de negocio consistente con el resto de la aplicación:

```csharp
catch (Exception ex)
{
    if (ex.Message.Contains("UQ_Citas_Medico_Fecha_Hora"))
        mensaje = "El médico ya tiene una cita agendada en ese horario.";
    else
        mensaje = "Error en BD: " + ex.Message;

    return mensaje;
}
```

**Justificación técnica del aporte**

- **Cierra un gap real de concurrencia**: el `EXISTS` y el `INSERT` son dos pasos separados en el tiempo; el `UNIQUE constraint` actúa de forma atómica en el motor, por lo que es la única garantía que no depende del orden de ejecución de transacciones concurrentes.
- **Defensa en profundidad, no redundancia**: ambos mecanismos cumplen roles distintos — uno optimiza la experiencia de usuario en el caso normal, el otro protege la integridad del dato en el caso límite.
- **Protege el dato, no solo la interfaz**: sin la restricción, la peor consecuencia posible es una fila duplicada persistida en la base — un médico con dos citas en el mismo horario —, un dato corrupto que eventualmente afecta reportes, facturación y dashboards. Con la restricción, ese estado es físicamente imposible a nivel de motor, independientemente de qué capa de la aplicación falle.
- **Mensaje de negocio uniforme**: sea cual sea el camino que detecte el conflicto (validación previa o choque real contra el constraint), el usuario recibe siempre el mismo tipo de mensaje entendible, nunca el detalle técnico del motor.

---

### 3. Contraseña Opcional en la Edición de Usuario

**Problema identificado**

En el formulario de edición de `Usuario`, dejar el campo `Contraseña` en blanco — comportamiento esperado para conservar la contraseña actual — provocaba que `ModelState.IsValid` retornara `false`, bloqueando el `POST` incluso cuando el resto del formulario era válido.

**Causa raíz**

La regla de negocio real es asimétrica: la contraseña es obligatoria en el registro de un nuevo usuario, pero opcional en la edición. Esa regla estaba implementada incorrectamente como una validación de tipo (requerida siempre a nivel de modelo), en lugar de una regla de negocio contextual.

**Solución implementada**

1. Se cambió el tipo de `Contrasena` en el modelo `Usuario` de `string` a `string?` (nullable), permitiendo que el model binder de ASP.NET Core acepte el campo vacío sin activar la validación automática de campo requerido.

2. Se trasladó la regla de negocio real al procedimiento correspondiente a cada operación:

```sql
-- sp_InsertarUsuario: la contraseña es obligatoria solo en el registro
IF @Contrasena IS NULL OR LEN(@Contrasena) = 0
BEGIN
    RAISERROR('La contrasena no puede estar vacia', 16, 1);
    RETURN;
END
```

`sp_ActualizarUsuario` mantiene su lógica original sin modificaciones: si llega una contraseña vacía, conserva la existente; si llega con valor, la actualiza.

**Justificación técnica del aporte**

La corrección mueve la validación desde una capa incorrecta (anotación de tipo a nivel de modelo, aplicada de forma global) hacia la capa correcta (regla de negocio a nivel de stored procedure, aplicada de forma contextual según la operación). Esto resuelve el bug sin introducir lógica condicional adicional en el controlador ni duplicar validaciones entre capas.

---

### Resumen de Aportes 

| # | Aporte | Capa afectada | Patrón aplicado |
|---|---|---|---|
| 1 | Validación de integridad referencial en DELETE (Paciente, Médico, Especialidad) | SQL (stored procedures) | `EXISTS` + `RAISERROR(16,1)` |
| 2 | Prevención de condición de carrera en agendamiento de citas | SQL (constraint) + C# (repositorio) | `UNIQUE constraint` + manejo de excepción específico |
| 3 | Contraseña opcional en edición de usuario | Modelo (C#) + SQL (stored procedure) | Tipo nullable + regla de negocio contextual |

