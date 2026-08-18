using ClinicaSalud.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ClinicaSalud.Controllers
{
    public class DashboardController : Controller
    {
        private readonly IConfiguration configuration;

        public DashboardController(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public IActionResult Index()
        {
            Dashboard modelo = new Dashboard();

            using (SqlConnection cn = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn.Open();

                // 1. Totales de las 4 tarjetas
                SqlCommand cmdTotales = new SqlCommand("sp_DashboardTotales", cn);
                cmdTotales.CommandType = CommandType.StoredProcedure;

                using (SqlDataReader dr = cmdTotales.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        modelo.TotalPacientes = Convert.ToInt32(dr["TotalPacientes"]);
                        modelo.TotalMedicos = Convert.ToInt32(dr["TotalMedicos"]);
                        modelo.CitasHoy = Convert.ToInt32(dr["CitasHoy"]);
                        modelo.CitasPendientes = Convert.ToInt32(dr["CitasPendientes"]);
                    }
                }
            }

            using (SqlConnection cn2 = new SqlConnection(configuration["ConnectionStrings:cn"]))
            {
                cn2.Open();

                // 2. Tabla "Citas de hoy"
                SqlCommand cmdCitas = new SqlCommand("sp_CitasDeHoy", cn2);
                cmdCitas.CommandType = CommandType.StoredProcedure;

                using (SqlDataReader dr = cmdCitas.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        modelo.CitasDeHoy.Add(new CitaHoy()
                        {
                            Hora = (TimeSpan)dr["Hora"],
                            Paciente = dr["Paciente"].ToString(),
                            Medico = dr["Medico"].ToString(),
                            Especialidad = dr["Especialidad"].ToString(),
                            Estado = dr["Estado"].ToString()
                        });
                    }
                }
            }

            return View(modelo);
        }
    }
}
