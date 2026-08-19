namespace ClinicaSalud.Models
{
    public class HistorialMedico
    {
        public int HistorialId { get; set; }
        public int PacienteId { get; set; }
        public string NombrePaciente { get; set; }   // viene del JOIN, no se inserta/actualiza
        public int MedicoId { get; set; }
        public string NombreMedico { get; set; }     // viene del JOIN, no se inserta/actualiza
        public DateTime Fecha { get; set; }
        public string Diagnostico { get; set; }
        public string Tratamiento { get; set; }
    }
}
