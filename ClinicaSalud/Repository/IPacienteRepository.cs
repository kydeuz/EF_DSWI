using ClinicaSalud.Models;

namespace ClinicaSalud.Repository
{
    public interface IPacienteRepository
    {
        IEnumerable<Paciente> ListarPacientesCombo();
        
    }
}