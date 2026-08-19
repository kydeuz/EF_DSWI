using ClinicaSalud.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ClinicaSalud.Controllers
{
    public class MedicosController : Controller
    {
        private readonly IConfiguration configuration;

        public MedicosController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IEnumerable<Medico> listarMedicos(string texto = "")
        {
            List<Medico> medicos = new List<Medico>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                SqlCommand cmd;
                if (string.IsNullOrEmpty(texto))
                {
                    cmd = new SqlCommand("sp_ListarMedicos", cn);
                }
                else
                {
                    cmd = new SqlCommand("sp_BuscarMedicosPorTexto", cn);
                    cmd.Parameters.AddWithValue("@Texto", texto);
                }
                cmd.CommandType = CommandType.StoredProcedure;

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    medicos.Add(new Medico()
                    {
                        MedicoId = Convert.ToInt32(dr["MedicoId"]),
                        Nombres = dr["Nombres"].ToString(),
                        Apellidos = dr["Apellidos"].ToString(),
                        EspecialidadId = Convert.ToInt32(dr["EspecialidadId"]),
                        NombreEspecialidad = dr["NombreEspecialidad"].ToString(),
                        Telefono = dr["Telefono"] == DBNull.Value ? "" : dr["Telefono"].ToString(),
                        Correo = dr["Correo"] == DBNull.Value ? "" : dr["Correo"].ToString(),
                        Estado = Convert.ToBoolean(dr["Estado"])
                    });
                }
            }
            return medicos;
        }

      
        public IEnumerable<Especialidad> listarEspecialidades()
        {
            List<Especialidad> especialidades = new List<Especialidad>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                SqlCommand cmd = new SqlCommand("sp_ListarEspecialidades", cn);
                cmd.CommandType = CommandType.StoredProcedure;

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    especialidades.Add(new Especialidad()
                    {
                        EspecialidadId = Convert.ToInt32(dr["EspecialidadId"]),
                        Nombre = dr["Nombre"].ToString()
                    });
                }
            }
            return especialidades;
        }

        public async Task<IActionResult> listadomedicos(int p = 0, string texto = "")
        {
            int nro = 5;
            var lista = listarMedicos(texto);

            int tr = lista.Count();
            int paginas = tr % nro > 0 ? tr / nro + 1 : tr / nro;

            ViewBag.paginas = paginas;
            ViewBag.texto = texto;

            return View(await Task.Run(() => lista.Skip(p * nro).Take(nro)));
        }

        [HttpGet]
        public IActionResult Nuevo()
        {
            ViewBag.Especialidades = listarEspecialidades();
            return View();
        }

        [HttpPost]
        public IActionResult Registrar(Medico objMedico)
        {

            if (!ModelState.IsValid)
            {
                ViewBag.Especialidades = listarEspecialidades(); 
                return View(objMedico);
            }
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_InsertarMedico", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Nombres", objMedico.Nombres);
                    cmd.Parameters.AddWithValue("@Apellidos", objMedico.Apellidos);
                    cmd.Parameters.AddWithValue("@EspecialidadId", objMedico.EspecialidadId);
                    cmd.Parameters.AddWithValue("@Telefono", objMedico.Telefono);
                    cmd.Parameters.AddWithValue("@Correo", objMedico.Correo);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Médico registrado correctamente" : "No se pudo registrar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadomedicos");
        }

        [HttpGet]
        public IActionResult Edit(int id)
        {
            
            Medico objMedico = new Medico();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                SqlCommand cmd = new SqlCommand("sp_BuscarMedico", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@MedicoId", id);

                cn.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        objMedico.MedicoId = Convert.ToInt32(dr["MedicoId"]);
                        objMedico.Nombres = dr["Nombres"].ToString();
                        objMedico.Apellidos = dr["Apellidos"].ToString();
                        objMedico.EspecialidadId = Convert.ToInt32(dr["EspecialidadId"]);
                        objMedico.Telefono = dr["Telefono"] == DBNull.Value ? "" : dr["Telefono"].ToString();
                        objMedico.Correo = dr["Correo"] == DBNull.Value ? "" : dr["Correo"].ToString();
                        objMedico.Estado = Convert.ToBoolean(dr["Estado"]);
                    }
                }
            }

            ViewBag.Especialidades = listarEspecialidades();
            return View(objMedico);
        }

        [HttpPost, ActionName("Edit")]
        public IActionResult Edit_Post(Medico objMedico)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.Especialidades = listarEspecialidades();
                return View(objMedico);
            }
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_ActualizarMedico", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@MedicoId", objMedico.MedicoId);
                    cmd.Parameters.AddWithValue("@Nombres", objMedico.Nombres);
                    cmd.Parameters.AddWithValue("@Apellidos", objMedico.Apellidos);
                    cmd.Parameters.AddWithValue("@EspecialidadId", objMedico.EspecialidadId);
                    cmd.Parameters.AddWithValue("@Telefono", objMedico.Telefono);
                    cmd.Parameters.AddWithValue("@Correo", objMedico.Correo);
                    cmd.Parameters.AddWithValue("@Estado", objMedico.Estado);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Médico actualizado correctamente" : "No se pudo actualizar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadomedicos");
        }

        [HttpGet, ActionName("Delete")]
        public IActionResult Delete(int id)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("sp_EliminarMedico", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cn.Open();
                    cmd.Parameters.AddWithValue("@MedicoId", id);

                    int c = cmd.ExecuteNonQuery();
                    mensaje = c > 0 ? "Médico eliminado correctamente" : "No se pudo eliminar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadomedicos");
        }
    }
}