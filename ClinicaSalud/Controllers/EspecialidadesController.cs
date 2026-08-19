using ClinicaSalud.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ClinicaSalud.Controllers
{
    public class EspecialidadesController : Controller
    {
        private readonly IConfiguration configuration;

        public EspecialidadesController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IEnumerable<Especialidad> listarEspecialidades(string texto = "")
        {
            List<Especialidad> especialidades = new List<Especialidad>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                SqlCommand cmd;
                if (string.IsNullOrEmpty(texto))
                {
                    cmd = new SqlCommand("sp_ListarEspecialidades", cn);
                }
                else
                {
                    cmd = new SqlCommand("sp_BuscarEspecialidadesPorTexto", cn);
                    cmd.Parameters.AddWithValue("@Texto", texto);
                }
                cmd.CommandType = CommandType.StoredProcedure;

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    especialidades.Add(new Especialidad()
                    {
                        EspecialidadId = dr.GetInt32(0),
                        Nombre = dr.GetString(1),
                        Descripcion = dr["Descripcion"] == DBNull.Value ? "" : dr["Descripcion"].ToString()
                    });
                }
            }
            return especialidades;
        }

        public async Task<IActionResult> listadoespecialidades(int p = 0, string texto = "")
        {
            int nro = 5;
            var lista = listarEspecialidades(texto);

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
        public IActionResult Registrar(Especialidad objEspecialidad)
        {
            if (!ModelState.IsValid)
            {
                return View(objEspecialidad);
            }
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_InsertarEspecialidad", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Nombre", objEspecialidad.Nombre);
                    cmd.Parameters.AddWithValue("@Descripcion", objEspecialidad.Descripcion);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Especialidad registrada correctamente" : "No se pudo registrar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadoespecialidades");
        }

        [HttpGet]
        public IActionResult Edit(int id)
        {
            Especialidad objEspecialidad = new Especialidad();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                SqlCommand cmd = new SqlCommand("sp_BuscarEspecialidad", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@EspecialidadId", id);

                cn.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        objEspecialidad.EspecialidadId = Convert.ToInt32(dr["EspecialidadId"]);
                        objEspecialidad.Nombre = dr["Nombre"].ToString();
                        objEspecialidad.Descripcion = dr["Descripcion"] == DBNull.Value ? "" : dr["Descripcion"].ToString();
                    }
                }
            }

            return View(objEspecialidad);
        }

        [HttpPost, ActionName("Edit")]
        public IActionResult Edit_Post(Especialidad objEspecialidad)
        {
            if (!ModelState.IsValid)
            {
                return View(objEspecialidad);
            }
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_ActualizarEspecialidad", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@EspecialidadId", objEspecialidad.EspecialidadId);
                    cmd.Parameters.AddWithValue("@Nombre", objEspecialidad.Nombre);
                    cmd.Parameters.AddWithValue("@Descripcion", objEspecialidad.Descripcion);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Especialidad actualizada correctamente" : "No se pudo actualizar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadoespecialidades");
        }

        [HttpGet, ActionName("Delete")]
        public IActionResult Delete(int id)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("sp_EliminarEspecialidad", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cn.Open();
                    cmd.Parameters.AddWithValue("@EspecialidadId", id);

                    int c = cmd.ExecuteNonQuery();
                    mensaje = c > 0 ? "Especialidad eliminada correctamente" : "No se pudo eliminar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadoespecialidades");
        }
    }
}