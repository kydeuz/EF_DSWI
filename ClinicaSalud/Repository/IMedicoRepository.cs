using ClinicaSalud.Models;

namespace ClinicaSalud.Repository
{
    public interface IMedicoRepository {
      IEnumerable<Medico> ListarMedicosCombo();
    }

}