using System.Data;
using ClinicaSalud.Models;
using Microsoft.Data.SqlClient;

namespace ClinicaSalud.Repository {

    public class MedicoRepository : IMedicoRepository
    {
        private string con;

        public MedicoRepository(IConfiguration configuration)
        {
            con = configuration.GetConnectionString("cn");
        }

         public IEnumerable<Medico> ListarMedicosCombo()
        {
            List<Medico> medicos = new List<Medico>();

            using (SqlConnection cn = new SqlConnection(con))
            {
                cn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_ListarMedicos", cn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
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
                }
            }
            return medicos;
        }

    }

}