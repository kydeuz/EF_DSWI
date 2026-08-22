using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Security.Claims;
using ClinicaSalud.Models;

namespace ClinicaSalud.Controllers
{
    public class AccountController : Controller
    {
        private readonly IConfiguration configuration;

        public AccountController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

   
        [AllowAnonymous]
        [HttpGet]
        public IActionResult Login()
        {
            if (User.Identity != null && User.Identity.IsAuthenticated)
            {
                return RedirectToAction("Index", "Home");
            }
            return View();
        }

        
        [AllowAnonymous]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            Usuario objUsuario = null;

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
            
                string query = @"
                    SELECT u.UsuarioId, u.Nombre, u.Correo, u.Estado, u.RolId, r.Nombre AS NombreRol
                    FROM Usuarios u
                    INNER JOIN Roles r ON u.RolId = r.RolId
                    WHERE u.Correo = @Correo AND u.Contrasena = @Contrasena AND u.Estado = 1";

                SqlCommand cmd = new SqlCommand(query, cn);
                cmd.Parameters.AddWithValue("@Correo", model.Correo);
                cmd.Parameters.AddWithValue("@Contrasena", model.Contrasena);

                cn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        objUsuario = new Usuario()
                        {
                            UsuarioId = Convert.ToInt32(dr["UsuarioId"]),
                            Nombre = dr["Nombre"].ToString(),
                            Correo = dr["Correo"].ToString(),
                            Estado = Convert.ToBoolean(dr["Estado"]),
                            RolId = Convert.ToInt32(dr["RolId"]),
                            Rol = new Rol()
                            {
                                RolId = Convert.ToInt32(dr["RolId"]),
                                Nombre = dr["NombreRol"].ToString()
                            }
                        };
                    }
                }
            }

     
            if (objUsuario == null)
            {
                ViewBag.Error = "Correo o contraseña incorrectos";
                return View(model);
            }

     
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, objUsuario.UsuarioId.ToString()),
                new Claim(ClaimTypes.Name, objUsuario.Nombre),
                new Claim(ClaimTypes.Email, objUsuario.Correo),
                new Claim(ClaimTypes.Role, objUsuario.Rol.Nombre)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity)
            );

            return RedirectToAction("Index", "Home");
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account");
        }
    }
}