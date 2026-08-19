using ClinicaSalud.Models;

namespace ClinicaSalud.Repository
{
    public interface IReporteRepository
    {
        IEnumerable<ReporteCita> ObtenerCitasPorFecha(DateTime fechaDesde, DateTime fechaHasta, int pageNumber, int pageSize);
        int ContarCitasPorFecha(DateTime fechaDesde, DateTime fechaHasta);
    }
}