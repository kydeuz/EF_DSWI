using ClinicaSalud.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ClinicaSalud.Controllers
{
    public class PacientesController : Controller
    {

        private readonly IConfiguration configuration;

        public PacientesController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public IEnumerable<Paciente> listarPacientes(string texto = "")
        {
            List<Paciente> pacientes = new List<Paciente>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                SqlCommand cmd;
                if (string.IsNullOrEmpty(texto))
                {
                    cmd = new SqlCommand("sp_ListarPacientes", cn);
                }
                else
                {
                    cmd = new SqlCommand("sp_BuscarPacientesPorTexto", cn);
                    cmd.Parameters.AddWithValue("@Texto", texto);
                }
                cmd.CommandType = CommandType.StoredProcedure;

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    pacientes.Add(new Paciente()
                    {
                        PacienteId = dr.GetInt32(0),
                        DNI = dr.GetString(1),
                        Nombres = dr.GetString(2),
                        Apellidos = dr.GetString(3),
                        FechaNacimiento = dr.GetDateTime(4),
                        Sexo = dr.GetString(5),
                        Telefono = dr["Telefono"] == DBNull.Value ? "" : dr["Telefono"].ToString(),
                        Correo = dr["Correo"] == DBNull.Value ? "" : dr["Correo"].ToString(),
                        Direccion = dr["Direccion"] == DBNull.Value ? "" : dr["Direccion"].ToString(),
                        FechaRegistro = dr.GetDateTime(9)
                    });
                }
            }
            return pacientes;
        }

        public async Task<IActionResult> listadopacientes(int p, string texto = "")
        {
            int nro = 5;
            var lista = listarPacientes(texto);

            int tr = lista.Count();
            int paginas = tr % nro > 0 ? tr / nro + 1 : tr / nro;

            ViewBag.paginas = paginas;
            ViewBag.texto = texto;

            return View(await Task.Run(() => lista.Skip(p * nro).Take(nro)));
        }
        [HttpGet]
        public IActionResult Nuevo()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Registrar(Paciente objPaciente)
        {
            if (objPaciente.FechaNacimiento > DateTime.Today)
            {
                ModelState.AddModelError("FechaNacimiento", "La fecha de nacimiento no puede ser futura.");
            }

            if (!ModelState.IsValid)
            {
                return View( "nuevo" , objPaciente);
            }
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_InsertarPaciente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DNI", objPaciente.DNI);
                    cmd.Parameters.AddWithValue("@Nombres", objPaciente.Nombres);
                    cmd.Parameters.AddWithValue("@Apellidos", objPaciente.Apellidos);
                    cmd.Parameters.AddWithValue("@FechaNacimiento", objPaciente.FechaNacimiento);
                    cmd.Parameters.AddWithValue("@Sexo", objPaciente.Sexo);
                    cmd.Parameters.AddWithValue("@Telefono", objPaciente.Telefono);
                    cmd.Parameters.AddWithValue("@Correo", objPaciente.Correo);
                    cmd.Parameters.AddWithValue("@Direccion", objPaciente.Direccion);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Paciente registrado correctamente" : "No se pudo registrar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("Listadopacientes");
        }



        [HttpGet]
        public IActionResult Edit(int id)
        {
            Paciente objPaciente = new Paciente();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                SqlCommand cmd = new SqlCommand("sp_BuscarPaciente", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PacienteId", id);

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
                        objPaciente.Sexo = dr["Sexo"].ToString();
                        objPaciente.Telefono = dr["Telefono"] == DBNull.Value ? "" : dr["Telefono"].ToString();
                        objPaciente.Correo = dr["Correo"] == DBNull.Value ? "" : dr["Correo"].ToString();
                        objPaciente.Direccion = dr["Direccion"] == DBNull.Value ? "" : dr["Direccion"].ToString();
                        objPaciente.FechaRegistro = Convert.ToDateTime(dr["FechaRegistro"]);
                    }
                }
            }

            return View(objPaciente);
        }

        [HttpPost, ActionName("Edit")]
        public IActionResult Edit_Post(Paciente objPaciente)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_ActualizarPaciente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@PacienteId", objPaciente.PacienteId);
                    cmd.Parameters.AddWithValue("@DNI", objPaciente.DNI);
                    cmd.Parameters.AddWithValue("@Nombres", objPaciente.Nombres);
                    cmd.Parameters.AddWithValue("@Apellidos", objPaciente.Apellidos);
                    cmd.Parameters.AddWithValue("@FechaNacimiento", objPaciente.FechaNacimiento);
                    cmd.Parameters.AddWithValue("@Sexo", objPaciente.Sexo);
                    cmd.Parameters.AddWithValue("@Telefono", objPaciente.Telefono);
                    cmd.Parameters.AddWithValue("@Correo", objPaciente.Correo);
                    cmd.Parameters.AddWithValue("@Direccion", objPaciente.Direccion);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Paciente actualizado correctamente" : "No se pudo actualizar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("Listadopacientes");
        }

        [HttpGet, ActionName("Delete")]
        public IActionResult Delete(int id)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("sp_EliminarPaciente", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cn.Open();
                    cmd.Parameters.AddWithValue("@PacienteId", id);

                    int c = cmd.ExecuteNonQuery();
                    mensaje = c > 0 ? "Paciente eliminado correctamente" : "No se pudo eliminar el paciente";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("Listadopacientes");
        }
    }
}
