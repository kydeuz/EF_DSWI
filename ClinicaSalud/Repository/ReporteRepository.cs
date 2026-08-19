using ClinicaSalud.Models;
using Microsoft.Extensions.Configuration;
using System.Data;
using Microsoft.Data.SqlClient;

namespace ClinicaSalud.Repository
{
    public class ReporteRepository : IReporteRepository
    {
        private readonly string _connectionString;

        public ReporteRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("cn");
        }

        public IEnumerable<ReporteCita> ObtenerCitasPorFecha(DateTime fechaDesde, DateTime fechaHasta, int pageNumber, int pageSize)
        {
            List<ReporteCita> lista = new List<ReporteCita>();

            using (SqlConnection cn = new SqlConnection(_connectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand("sp_ReporteCitas_PorFecha", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@FechaDesde", fechaDesde);
                cmd.Parameters.AddWithValue("@FechaHasta", fechaHasta);
                cmd.Parameters.AddWithValue("@pageNumber", pageNumber);
                cmd.Parameters.AddWithValue("@pageSize", pageSize);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new ReporteCita()
                        {
                            CitaId = Convert.ToInt32(dr["CitaId"]),
                            Fecha = Convert.ToDateTime(dr["Fecha"]),
                            Hora = (TimeSpan)dr["Hora"],
                            Paciente = dr["Paciente"].ToString(),
                            Medico = dr["Medico"].ToString(),
                            Especialidad = dr["Especialidad"].ToString(),
                            Motivo = dr["Motivo"].ToString(),
                            Estado = dr["Estado"].ToString()
                        });
                    }
                }
            }
            return lista;
        }

        public int ContarCitasPorFecha(DateTime fechaDesde, DateTime fechaHasta)
        {
            using (SqlConnection cn = new SqlConnection(_connectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand("sp_ContarReporteCitas_PorFecha", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@FechaDesde", fechaDesde);
                cmd.Parameters.AddWithValue("@FechaHasta", fechaHasta);

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }
}