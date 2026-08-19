using ClinicaSalud.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ClinicaSalud.Controllers
{
    public class UsuarioController : Controller
    {
        private readonly IConfiguration configuration;

        public UsuarioController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IEnumerable<Usuario> listarUsuarios(string texto = "")
        {
            List<Usuario> usuarios = new List<Usuario>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                SqlCommand cmd;
                if (string.IsNullOrEmpty(texto))
                {
                    cmd = new SqlCommand("sp_ListarUsuarios", cn);
                }
                else
                {
                    cmd = new SqlCommand("sp_BuscarUsuariosPorTexto", cn);
                    cmd.Parameters.AddWithValue("@Texto", texto);
                }
                cmd.CommandType = CommandType.StoredProcedure;

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    usuarios.Add(new Usuario()
                    {
                        UsuarioId = Convert.ToInt32(dr["UsuarioId"]),
                        Nombre = dr["Nombre"].ToString() ?? "",
                        Correo = dr["Correo"] == DBNull.Value ? "" : dr["Correo"].ToString()!,
                        RolId = Convert.ToInt32(dr["RolId"]),
                        Estado = Convert.ToBoolean(dr["Estado"]),
                        FechaCreacion = Convert.ToDateTime(dr["FechaCreacion"]),
                        Rol = new Rol()
                        {
                            RolId = Convert.ToInt32(dr["RolId"]),
                            Nombre = dr["NombreRol"].ToString() ?? ""
                        }
                    });
                }
            }
            return usuarios;
        }

        public IEnumerable<Rol> listarRoles()
        {
            List<Rol> roles = new List<Rol>();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                SqlCommand cmd = new SqlCommand("sp_ListarRoles", cn);
                cmd.CommandType = CommandType.StoredProcedure;

                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    roles.Add(new Rol()
                    {
                        RolId = Convert.ToInt32(dr["RolId"]),
                        Nombre = dr["Nombre"].ToString() ?? ""
                    });
                }
            }
            return roles;
        }

        public async Task<IActionResult> listadousuarios(int p = 0, string texto = "")
        {
            int nro = 5;
            var lista = listarUsuarios(texto);

            int tr = lista.Count();
            int paginas = tr % nro > 0 ? tr / nro + 1 : tr / nro;

            ViewBag.paginas = paginas;
            ViewBag.texto = texto;

            return View(await Task.Run(() => lista.Skip(p * nro).Take(nro)));
        }

        [HttpGet]
        public IActionResult Nuevo()
        {
            ViewBag.Roles = listarRoles();
            return View();
        }

        [HttpPost]
        public IActionResult Registrar(Usuario objUsuario)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_InsertarUsuario", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Nombre", objUsuario.Nombre);
                    cmd.Parameters.AddWithValue("@Correo", objUsuario.Correo);
                    cmd.Parameters.AddWithValue("@Contrasena", objUsuario.Contrasena);
                    cmd.Parameters.AddWithValue("@RolId", objUsuario.RolId);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Usuario registrado correctamente" : "No se pudo registrar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadousuarios");
        }

        [HttpGet]
        public IActionResult Edit(int id)
        {
            Usuario objUsuario = new Usuario();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                SqlCommand cmd = new SqlCommand("sp_BuscarUsuario", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UsuarioId", id);

                cn.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        objUsuario.UsuarioId = Convert.ToInt32(dr["UsuarioId"]);
                        objUsuario.Nombre = dr["Nombre"].ToString() ?? "";
                        objUsuario.Correo = dr["Correo"] == DBNull.Value ? "" : dr["Correo"].ToString()!;
                        objUsuario.RolId = Convert.ToInt32(dr["RolId"]);
                        objUsuario.Estado = Convert.ToBoolean(dr["Estado"]);
                        objUsuario.FechaCreacion = Convert.ToDateTime(dr["FechaCreacion"]);
                    }
                }
            }

            ViewBag.Roles = listarRoles();
            return View(objUsuario);
        }

        [HttpPost, ActionName("Edit")]
        public IActionResult Edit_Post(Usuario objUsuario)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_ActualizarUsuario", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UsuarioId", objUsuario.UsuarioId);
                    cmd.Parameters.AddWithValue("@Nombre", objUsuario.Nombre);
                    cmd.Parameters.AddWithValue("@Correo", objUsuario.Correo);
                    cmd.Parameters.AddWithValue("@RolId", objUsuario.RolId);
                    cmd.Parameters.AddWithValue("@Estado", objUsuario.Estado);
                    cmd.Parameters.AddWithValue("@Contrasena", string.IsNullOrEmpty(objUsuario.Contrasena) ? (object)DBNull.Value : objUsuario.Contrasena);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Usuario actualizado correctamente" : "No se pudo actualizar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadousuarios");
        }

        [HttpGet, ActionName("Delete")]
        public IActionResult Delete(int id)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                try
                {
                    SqlCommand cmd = new SqlCommand("sp_EliminarUsuario", cn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cn.Open();
                    cmd.Parameters.AddWithValue("@UsuarioId", id);

                    int c = cmd.ExecuteNonQuery();
                    mensaje = c > 0 ? "Usuario eliminado correctamente" : "No se pudo eliminar";
                }
                catch (Exception ex)
                {
                    mensaje = ex.Message;
                }
            }

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadousuarios");
        }
    }
}