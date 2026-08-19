using System.ComponentModel.DataAnnotations;

namespace ClinicaSalud.Models
{
    public class Cita
    {
        
        public int CitaId { get; set; }
        public int PacienteId { get; set; }
        public string? NombrePaciente { get; set; }  
        public int MedicoId { get; set; }
       public string? NombreMedico { get; set; }    

        [Required(ErrorMessage = "La fecha es obligatoria")]
        public DateTime Fecha { get; set; }

        [Required(ErrorMessage = "La hora es obligatoria")]
        public TimeSpan Hora { get; set; }

        [Required(ErrorMessage = "El motivo es obligatorio")]
        public string Motivo { get; set; }

       
        public string Estado { get; set; }
    }
}
