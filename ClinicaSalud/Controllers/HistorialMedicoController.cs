using ClinicaSalud.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ClinicaSalud.Controllers
{
    public class HistorialMedicoController : Controller
    {
        private readonly IConfiguration configuration;

        public HistorialMedicoController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public IEnumerable<HistorialMedico> listarHistorial(int pacienteId)
        {
            List<HistorialMedico> historial = new List<HistorialMedico>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                SqlCommand cmd = new SqlCommand("sp_ListarHistorialPorPaciente", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PacienteId", pacienteId);

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    historial.Add(new HistorialMedico()
                    {
                        HistorialId = Convert.ToInt32(dr["HistorialId"]),
                        PacienteId = Convert.ToInt32(dr["PacienteId"]),
                        NombrePaciente = dr["NombrePaciente"].ToString(),
                        MedicoId = Convert.ToInt32(dr["MedicoId"]),
                        NombreMedico = dr["NombreMedico"].ToString(),
                        Fecha = Convert.ToDateTime(dr["Fecha"]),
                        Diagnostico = dr["Diagnostico"].ToString(),
                        Tratamiento = dr["Tratamiento"] == DBNull.Value ? "" : dr["Tratamiento"].ToString()
                    });
                }
            }
            return historial;
        }

        // Datos básicos del paciente para el encabezado de la ficha (nombre, DNI, teléfono)
        public Paciente buscarPaciente(int pacienteId)
        {
            Paciente objPaciente = new Paciente();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                SqlCommand cmd = new SqlCommand("sp_BuscarPaciente", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PacienteId", pacienteId);

                cn.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        objPaciente.PacienteId = Convert.ToInt32(dr["PacienteId"]);
                        objPaciente.DNI = dr["DNI"].ToString();
                        objPaciente.Nombres = dr["Nombres"].ToString();
                        objPaciente.Apellidos = dr["Apellidos"].ToString();
                        objPaciente.FechaNacimiento = Convert.ToDateTime(dr["FechaNacimiento"]);
                        objPaciente.Telefono = dr["Telefono"] == DBNull.Value ? "" : dr["Telefono"].ToString();
                    }
                }
            }
            return objPaciente;
        }

        // Combo de médicos para el <select> del formulario Nuevo()
        public IEnumerable<Medico> listarMedicosCombo()
        {
            List<Medico> medicos = new List<Medico>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand("sp_ListarMedicos", cn);
                cmd.CommandType = CommandType.StoredProcedure;

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    medicos.Add(new Medico()
                    {
                        MedicoId = Convert.ToInt32(dr["MedicoId"]),
                        Nombres = dr["Nombres"].ToString(),
                        Apellidos = dr["Apellidos"].ToString()
                    });
                }
            }
            return medicos;
        }

        [HttpGet]
        public IActionResult Listado(int pacienteId)
        {
            ViewBag.Paciente = buscarPaciente(pacienteId);
            return View(listarHistorial(pacienteId));
        }

        [HttpGet]
        public IActionResult Nuevo(int pacienteId)
        {
            ViewBag.Paciente = buscarPaciente(pacienteId);
            ViewBag.Medicos = listarMedicosCombo();
            return View(new HistorialMedico { PacienteId = pacienteId });
        }

        [HttpPost]
        public IActionResult Registrar(HistorialMedico objHistorial)
        {

            if (!ModelState.IsValid)
            {
                ViewBag.Medicos = listarMedicosCombo();           
                ViewBag.Paciente = buscarPaciente(objHistorial.PacienteId); 
                return View("nuevo", objHistorial);             
            }
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_InsertarHistorial", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@PacienteId", objHistorial.PacienteId);
                    cmd.Parameters.AddWithValue("@MedicoId", objHistorial.MedicoId);
                    cmd.Parameters.AddWithValue("@Diagnostico", objHistorial.Diagnostico);
                    cmd.Parameters.AddWithValue("@Tratamiento", objHistorial.Tratamiento);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Registro agregado correctamente" : "No se pudo registrar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("Listado", new { pacienteId = objHistorial.PacienteId });
        }

        [HttpGet]
        public IActionResult Detalle(int id)
        {
            HistorialMedico objHistorial = new HistorialMedico();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                SqlCommand cmd = new SqlCommand("sp_BuscarHistorial", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@HistorialId", id);

                cn.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        objHistorial.HistorialId = Convert.ToInt32(dr["HistorialId"]);
                        objHistorial.PacienteId = Convert.ToInt32(dr["PacienteId"]);
                        objHistorial.NombrePaciente = dr["NombrePaciente"].ToString();
                        objHistorial.MedicoId = Convert.ToInt32(dr["MedicoId"]);
                        objHistorial.NombreMedico = dr["NombreMedico"].ToString();
                        objHistorial.Fecha = Convert.ToDateTime(dr["Fecha"]);
                        objHistorial.Diagnostico = dr["Diagnostico"].ToString();
                        objHistorial.Tratamiento = dr["Tratamiento"] == DBNull.Value ? "" : dr["Tratamiento"].ToString();
                    }
                }
            }

            return View(objHistorial);
        }
    }
}