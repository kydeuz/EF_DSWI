using System.Data;
using ClinicaSalud.Models;
using Microsoft.Data.SqlClient;


namespace ClinicaSalud.Repository
{
    public class PacienteRepository : IPacienteRepository
    {
        private string con;

        public PacienteRepository(IConfiguration configuration)
        {
            con = configuration.GetConnectionString("cn");
        }

        public IEnumerable<Paciente> ListarPacientesCombo()
        {
            List<Paciente> pacientes = new List<Paciente>();

            using (SqlConnection cn = new SqlConnection(con))
            {
                cn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_ListarPacientes", cn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            pacientes.Add(new Paciente()
                            {
                                PacienteId = Convert.ToInt32(dr["PacienteId"]),
                                Nombres = dr["Nombres"].ToString(),
                                Apellidos = dr["Apellidos"].ToString()
                            });
                        }
                    }
                }
            }
            return pacientes;
        }
    }
}