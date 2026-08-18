namespace ClinicaSalud.Models
{
    public class Dashboard
    {
        public int TotalPacientes { get; set; }
        public int TotalMedicos { get; set; }
        public int CitasHoy { get; set; }
        public int CitasPendientes { get; set; }
        public List<CitaHoy> CitasDeHoy { get; set; } = new List<CitaHoy>();
    }

    public class CitaHoy
    {
        public TimeSpan Hora { get; set; }
        public string Paciente { get; set; }
        public string Medico { get; set; }
        public string Especialidad { get; set; }
        public string Estado { get; set; }
    }
}
