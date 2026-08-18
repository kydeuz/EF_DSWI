
using ClinicaSalud.Models;

namespace ClinicaSalud.Repository
{
    public interface ICitaRepository
    {
        IEnumerable<Cita> ListarCitas(int pageNumber, int pagesize, string texto = "");
        int ContarCitas(string texto = "");

        string Registrar(Cita objCita);

        Cita Buscar(int id);         
        string Actualizar(Cita objCita); 
       
        string Delete(int id);
       
    }
}