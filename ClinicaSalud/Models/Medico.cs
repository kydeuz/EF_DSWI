using ClinicaSalud.Models;

namespace ClinicaSalud.Models
{
    public class Medico
    {
        public int MedicoId { get; set; }
        public string Nombres { get; set; }
        public string Apellidos { get; set; }
        public int EspecialidadId { get; set; }
        public string NombreEspecialidad { get; set; }   // viene del JOIN, no se inserta/actualiza
        public string Telefono { get; set; }
        public string Correo { get; set; }
        public bool Estado { get; set; }
    }
}
