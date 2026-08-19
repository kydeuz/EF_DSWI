namespace ClinicaSalud.Models
{
    public class Cita
    {
        public int CitaId { get; set; }
        public int PacienteId { get; set; }
        public string NombrePaciente { get; set; }   
        public int MedicoId { get; set; }
        public string NombreMedico { get; set; }    
        public DateTime Fecha { get; set; }
        public TimeSpan Hora { get; set; }
        public string Motivo { get; set; }
        public string Estado { get; set; }
    }
}
