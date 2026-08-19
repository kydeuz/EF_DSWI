namespace ClinicaSalud.Models
{
    public class Rol
    {
        public int RolId { get; set; }
        public string Nombre { get; set; } = string.Empty;

        public ICollection<Usuario>? Usuarios { get; set; }
    }
}
