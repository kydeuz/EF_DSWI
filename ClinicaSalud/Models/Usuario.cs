using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;

namespace ClinicaSalud.Models
{
    public class Usuario
    {
        public int UsuarioId { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Correo { get; set; } = string.Empty;

        [ValidateNever]
        public string? Contrasena { get; set; }
        public int RolId { get; set; }
        public bool Estado { get; set; } = true;
        public DateTime FechaCreacion { get; set; } = DateTime.Now;
 
        public Rol? Rol { get; set; }
    }
}
