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
