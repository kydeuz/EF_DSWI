using System.Data;
using ClinicaSalud.Models;
using Microsoft.Data.SqlClient;


namespace ClinicaSalud.Repository
{
    public class CitaRepository : ICitaRepository
    {
        private string con;

        public CitaRepository(IConfiguration configuration)
        {
            con = configuration.GetConnectionString("cn");
        }

        public IEnumerable<Cita> ListarCitas(int pageNumber, int pagesize, string texto = "")
        {
            List<Cita> citas = new List<Cita>();

            using (SqlConnection cn = new SqlConnection(con))
            {
                try
                {
                    cn.Open();

                    using (SqlCommand cmd = string.IsNullOrEmpty(texto)
                        ? new SqlCommand("sp_ListarCitas", cn)
                        : new SqlCommand("sp_BuscarCitasPorTexto", cn))
                    {
                        if (!string.IsNullOrEmpty(texto))
                            cmd.Parameters.Add("@Texto", SqlDbType.VarChar, 100).Value = texto;

                        cmd.Parameters.Add("@pageNumber", SqlDbType.Int).Value = pageNumber;
                        cmd.Parameters.Add("@pagesize", SqlDbType.Int).Value = pagesize;
                        cmd.CommandType = CommandType.StoredProcedure;

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                citas.Add(new Cita()
                                {
                                    CitaId = Convert.ToInt32(dr["CitaId"]),
                                    PacienteId = Convert.ToInt32(dr["PacienteId"]),
                                    NombrePaciente = dr["NombrePaciente"].ToString(),
                                    MedicoId = Convert.ToInt32(dr["MedicoId"]),
                                    NombreMedico = dr["NombreMedico"].ToString(),
                                    Fecha = Convert.ToDateTime(dr["Fecha"]),
                                    Hora = (TimeSpan)dr["Hora"],
                                    Motivo = dr["Motivo"] == DBNull.Value ? "" : dr["Motivo"].ToString(),
                                    Estado = dr["Estado"].ToString()
                                });
                            }
                        }
                    }
                }
                catch (SqlException e)
                {
                    Console.WriteLine("Error de BD en ListarCitas: " + e.Message);
                    throw; 
                }
                finally
                {
                    if (cn.State == ConnectionState.Open)
                        cn.Close();
                }
            }
            return citas;
        }

        public int ContarCitas(string texto = "")
        {
            int total = 0;
            using (SqlConnection cn = new SqlConnection(con))
            {
                cn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_ContarCitas", cn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@Texto", SqlDbType.VarChar, 100).Value =
                        string.IsNullOrEmpty(texto) ? (object)DBNull.Value : texto;

                    total = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return total;
        }

        public string Registrar(Cita objCita)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(con))
            {
                try
                {
                    cn.Open();

                    SqlCommand cmd = new SqlCommand("sp_InsertarCita", cn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@PacienteId", objCita.PacienteId);
                    cmd.Parameters.AddWithValue("@MedicoId", objCita.MedicoId);
                    cmd.Parameters.AddWithValue("@Fecha", objCita.Fecha);
                    cmd.Parameters.AddWithValue("@Hora", objCita.Hora);
                    cmd.Parameters.AddWithValue("@Motivo", objCita.Motivo);

                    int c = cmd.ExecuteNonQuery();

                    mensaje = c > 0 ? "Cita registrada correctamente" : "No se pudo registrar";
                    return mensaje;
                }
                catch (Exception ex)
                {
                    if (ex.Message.Contains("UQ_Citas_Medico_Fecha_Hora"))
                        mensaje = "El médico ya tiene una cita agendada en ese horario.";
                    else
                        mensaje = "Error en BD: " + ex.Message;

                    return mensaje;
                }
                finally
                {
                    if (cn.State == ConnectionState.Open)
                        cn.Close();
                    
                }
            }
        }

        public Cita Buscar(int id)
        {
            Cita objCita = null;
            using (SqlConnection cn = new SqlConnection(con))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand("sp_BuscarCita", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CitaId", id);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        objCita = new Cita()
                        {
                            CitaId = Convert.ToInt32(dr["CitaId"]),
                            PacienteId = Convert.ToInt32(dr["PacienteId"]),
                            MedicoId = Convert.ToInt32(dr["MedicoId"]),
                            Fecha = Convert.ToDateTime(dr["Fecha"]),
                            Hora = (TimeSpan)dr["Hora"],
                            Motivo = dr["Motivo"] == DBNull.Value ? "" : dr["Motivo"].ToString(),
                            Estado = dr["Estado"].ToString()
                        };
                    }
                }
            }
            return objCita;
        }

        public string Actualizar(Cita objCita)
        {
            string mensaje = "";
            using (SqlConnection cn = new SqlConnection(con))
            {
             cn.Open();
               
                using (SqlTransaction tx = cn.BeginTransaction()) {
                 
                 try
                    {

                    using( SqlCommand cmd = new SqlCommand("sp_ActualizarCita", cn , tx) ){
                    
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@CitaId", objCita.CitaId);
                    cmd.Parameters.AddWithValue("@PacienteId", objCita.PacienteId);
                    cmd.Parameters.AddWithValue("@MedicoId", objCita.MedicoId);
                    cmd.Parameters.AddWithValue("@Fecha", objCita.Fecha);
                    cmd.Parameters.AddWithValue("@Hora", objCita.Hora);
                    cmd.Parameters.AddWithValue("@Motivo", objCita.Motivo);
                    cmd.Parameters.AddWithValue("@Estado", objCita.Estado);

                    int c = cmd.ExecuteNonQuery();
                    mensaje = c > 0 ? "Cita actualizada correctamente" : "No se pudo actualizar";
                    }
                    tx.Commit();

                    }
                   catch (Exception ex)
                    {
                        tx.Rollback();   
                        
                        if (ex.Message.Contains("UQ_Citas_Medico_Fecha_Hora"))
                            mensaje = "El médico ya tiene una cita agendada en ese horario.";
                        else
                            mensaje = "Error en BD: " + ex.Message;
                    }
                                    
                }
            }
            return mensaje;
        }

        public string Delete ( int id)
        {
            string mensaje = "";

            using (SqlConnection cn = new SqlConnection(con))
            {
                cn.Open();
                using ( SqlTransaction tx = cn.BeginTransaction()) {

                    try
                    {
                        using( SqlCommand cmd = new SqlCommand("sp_EliminarCita", cn , tx) ) {
                        
                        cmd.CommandType = CommandType.StoredProcedure;
                       
                        cmd.Parameters.AddWithValue("@CitaId", id);

                        int c = cmd.ExecuteNonQuery();
                        mensaje = c > 0 ? "Cita eliminada correctamente" : "No se pudo eliminar";

                        tx.Commit();
                        }
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        mensaje = ex.Message;

                    }

                }
            }
            return mensaje;

            
        }
        
    }
}