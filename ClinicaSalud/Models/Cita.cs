using System.ComponentModel.DataAnnotations;

namespace ClinicaSalud.Models
{
    public class Cita
    {
        
        public int CitaId { get; set; }
        public int PacienteId { get; set; }
        public string NombrePaciente { get; set; }   
        public int MedicoId { get; set; }
        public string NombreMedico { get; set; }    

        [StringLength(200, ErrorMessage = "La dirección no puede exceder los 200 caracteres")]
        public DateTime Fecha { get; set; }

        [Required(ErrorMessage = "La hora es obligatoria")]
        public TimeSpan Hora { get; set; }

        [Required(ErrorMessage = "El motivo es obligatorio")]
        public string Motivo { get; set; }

        [Required(ErrorMessage = "El estado es obligatorio")]
        public string Estado { get; set; }
    }
}
