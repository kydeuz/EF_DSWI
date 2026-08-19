using ClinicaSalud.Models;
using ClinicaSalud.Repository;
using Microsoft.AspNetCore.Mvc;

namespace ClinicaSalud.Controllers
{
    public class ReportesController : Controller
    {
        private readonly IReporteRepository _reporteRepo;

        public ReportesController(IReporteRepository reporteRepo)
        {
            _reporteRepo = reporteRepo;
        }

        [HttpGet]
        public IActionResult Index(DateTime? fechaDesde, DateTime? fechaHasta, int pageNumber = 1)
        {
            // Valores por defecto si no se envían
            if (!fechaDesde.HasValue)
                fechaDesde = DateTime.Today.AddDays(-30); // Últimos 30 días
            if (!fechaHasta.HasValue)
                fechaHasta = DateTime.Today;

            int pageSize = 5;

            // VALIDACIÓN: Fechas incoherentes 
            if (fechaDesde > fechaHasta)
            {
                TempData["error"] = "¡Fechas incoherentes! La fecha 'Desde' no puede ser mayor a la fecha 'Hasta'.";
                return RedirectToAction("Index"); 
            }

            ViewBag.fechaDesde = fechaDesde.Value.ToString("yyyy-MM-dd");
            ViewBag.fechaHasta = fechaHasta.Value.ToString("yyyy-MM-dd");
            ViewBag.pageNumber = pageNumber;

            // Obtener datos del repositorio
            var lista = _reporteRepo.ObtenerCitasPorFecha(fechaDesde.Value, fechaHasta.Value, pageNumber, pageSize);
            int total = _reporteRepo.ContarCitasPorFecha(fechaDesde.Value, fechaHasta.Value);

            ViewBag.paginas = (int)Math.Ceiling((double)total / pageSize);
            ViewBag.totalRegistros = total;

            return View(lista);
        }

        [HttpPost]
        public IActionResult Index(DateTime fechaDesde, DateTime fechaHasta, int pageNumber = 1)
        {
            // VALIDACIÓN: Fechas incoherentes
            if (fechaDesde > fechaHasta)
            {
                TempData["error"] = "¡Fechas incoherentes! La fecha 'Desde' no puede ser mayor a la fecha 'Hasta'.";
                return RedirectToAction("Index");
            }

            return RedirectToAction("Index", new { fechaDesde, fechaHasta, pageNumber });
        }
    }
}