using ClinicaSalud.Models;
using ClinicaSalud.Repository;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace ClinicaSalud.Controllers
{
    public class CitasController : Controller
    {
        private readonly ICitaRepository _citaRepo;
        private readonly IPacienteRepository _pacienteRepo;
        private readonly IMedicoRepository _medicoRepo;

        public CitasController(ICitaRepository citaRepo, IPacienteRepository pacienteRepo, IMedicoRepository medicoRepo)
        {
            _citaRepo = citaRepo;
            _pacienteRepo = pacienteRepo;
            _medicoRepo = medicoRepo;
        }


      

        private readonly IConfiguration configuration;
        
       
        [HttpGet]
        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public IActionResult ListadoCitas(string texto = "", int pageNumber = 0)
        {
            int pageSize = 3;

            ViewBag.texto = texto;
            ViewBag.pageNumber = pageNumber;

            IEnumerable<Cita> citas = _citaRepo.ListarCitas(pageNumber, pageSize, texto);

            int total = _citaRepo.ContarCitas(texto);
            ViewBag.paginas = (int)Math.Ceiling((double)total / pageSize);

            return View(citas);
        }


        [HttpGet]
        public IActionResult Nuevo()
        {
            ViewBag.Pacientes = _pacienteRepo.ListarPacientesCombo();
            ViewBag.Medicos = _medicoRepo.ListarMedicosCombo();
            return View();
        }


        [HttpPost]
        public IActionResult Registrar(Cita objCita)
        {
            objCita.Estado = "Pendiente";
            ModelState.Remove(nameof(objCita.Estado)); 
            if (objCita.Fecha < DateTime.Today)
            {
             ModelState.AddModelError("Fecha", "No se pueden agendar citas en fechas pasadas.");
            }   

            if (!ModelState.IsValid)
            {
                ViewBag.Pacientes = _pacienteRepo.ListarPacientesCombo();
                ViewBag.Medicos = _medicoRepo.ListarMedicosCombo();
                return View("Nuevo", objCita);  
            }
            
            string mensaje = _citaRepo.Registrar(objCita);

            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadocitas");
        }

       [HttpGet]
        public IActionResult Edit(int id)
        {
            Cita objCita = _citaRepo.Buscar(id);
            ViewBag.Pacientes = _pacienteRepo.ListarPacientesCombo();
            ViewBag.Medicos = _medicoRepo.ListarMedicosCombo();
            return View(objCita);
        }

        [HttpPost]
        public IActionResult Edit(Cita objCita)
        {
            if (objCita.Fecha < DateTime.Today)
            {
                ModelState.AddModelError("Fecha", "No se pueden agendar citas en fechas pasadas.");
            }

            // Vista con los datos y los mensajes
            if (!ModelState.IsValid)
            {
                ViewBag.Pacientes = _pacienteRepo.ListarPacientesCombo();
                ViewBag.Medicos = _medicoRepo.ListarMedicosCombo();
                return View(objCita);
            }
            string mensaje = _citaRepo.Actualizar(objCita);
            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadocitas");
        }

        [HttpGet]
        public IActionResult Delete(int id)
        {

            string mensaje = _citaRepo.Delete(id);


            TempData["mensaje"] = mensaje;
            return RedirectToAction("listadocitas");
        }
    }
}