using System.ComponentModel.DataAnnotations;

namespace ClinicaSalud.Models
{
    public class Paciente
    {
        public int PacienteId { get; set; }

        [Required(ErrorMessage = "El DNI es obligatorio")]
        public string DNI { get; set; }
        [Required(ErrorMessage = "Los nombres son obligatorios")]
        public string Nombres { get; set; }
        [Required(ErrorMessage = "Los apellidos son obligatorios")]
        public string Apellidos { get; set; }
        [Required(ErrorMessage = "La fecha de nacimiento es obligatoria")]
        public DateTime FechaNacimiento { get; set; }
        [Required(ErrorMessage = "El sexo es obligatorio")]
        public string Sexo { get; set; }
        [Required(ErrorMessage = "El teléfono es obligatorio")]
        public string Telefono { get; set; }
        [EmailAddress(ErrorMessage = "Formato de correo electrónico no válido")]
        public string Correo { get; set; }
        [StringLength(200, ErrorMessage = "La dirección no puede exceder los 200 caracteres")]
        public string Direccion { get; set; }
        public DateTime FechaRegistro { get; set; }
    }
}
