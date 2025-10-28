using AeroRide.API.Interfaces;
using AeroRide.API.Models.DTOs.Passengers;
using AeroRide.API.Models.DTOs.Reservations;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador encargado de gestionar las operaciones relacionadas con las reservas de vuelo.
    /// Incluye la creación, consulta, cancelación, confirmación y gestión de pasajeros y vuelos.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ReservationsController : ControllerBase
    {
        private readonly IReservationService _reservationService;
        private readonly IMapper _mapper;

        /// <summary>
        /// Inicializa una nueva instancia del controlador de reservas.
        /// </summary>
        /// <param name="reservationService">Servicio de reservas inyectado.</param>
        /// <param name="mapper">Instancia de AutoMapper para conversiones de DTOs.</param>
        public ReservationsController(IReservationService reservationService, IMapper mapper)
        {
            _reservationService = reservationService;
            _mapper = mapper;
        }

        // ======================================================
        // 🔹 CRUD PRINCIPAL
        // ======================================================

        /// <summary>
        /// Obtiene el listado completo de reservas registradas en el sistema.
        /// Solo disponible para administradores o brokers.
        /// </summary>
        [HttpGet]
        [Authorize(Roles = "Admin, Broker")]
        public async Task<IActionResult> GetAll()
        {
            var result = await _reservationService.GetAllAsync();
            return Ok(result);
        }

        /// <summary>
        /// Obtiene los detalles completos de una reserva específica por su identificador.
        /// </summary>
        /// <param name="id">Identificador único de la reserva.</param>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _reservationService.GetByIdAsync(id);
            if (result == null)
                return NotFound("Reserva no encontrada.");

            return Ok(result);
        }

        /// <summary>
        /// Obtiene todas las reservas realizadas por un usuario específico.
        /// </summary>
        /// <param name="userId">Identificador del usuario.</param>
        [HttpGet("by-user/{userId}")]
        [Authorize(Roles = "Admin, Broker, User")]
        public async Task<IActionResult> GetByUser(int userId)
        {
            var result = await _reservationService.GetByUserAsync(userId);
            return Ok(result);
        }

        /// <summary>
        /// Crea una nueva reserva en el sistema.
        /// </summary>
        /// <param name="dto">Datos necesarios para registrar la reserva.</param>
        [HttpPost]
        [Authorize(Roles = "Admin, Broker, User")]
        public async Task<IActionResult> Create([FromBody] ReservationCreateDto dto)
        {
            var created = await _reservationService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        /// <summary>
        /// Elimina una reserva existente del sistema.
        /// Solo los administradores pueden realizar esta acción.
        /// </summary>
        /// <param name="id">Identificador único de la reserva a eliminar.</param>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Delete(int id)
        {
            var deleted = await _reservationService.DeleteAsync(id);
            if (!deleted)
                return NotFound("Reserva no encontrada.");

            return NoContent();
        }

        // ======================================================
        // 🧭 ACCIONES DE NEGOCIO (cancelar, confirmar, etc.)
        // ======================================================

        /// <summary>
        /// Cancela una reserva existente cambiando su estado a "Cancelada".
        /// </summary>
        /// <param name="id">Identificador único de la reserva.</param>
        [HttpPatch("{id}/cancel")]
        [Authorize(Roles = "Admin, Broker, User")]
        public async Task<IActionResult> Cancel(int id)
        {
            var success = await _reservationService.CancelAsync(id);
            return success
                ? Ok(new { Message = "Reserva cancelada correctamente." })
                : NotFound(new { Message = "Reserva no encontrada o ya cancelada." });
        }

        /// <summary>
        /// Confirma una reserva cambiando su estado a "Confirmada".
        /// </summary>
        /// <param name="id">Identificador único de la reserva.</param>
        [HttpPatch("{id}/confirm")]
        [Authorize(Roles = "Admin, Broker")]
        public async Task<IActionResult> Confirm(int id)
        {
            var success = await _reservationService.ConfirmAsync(id);
            return success
                ? Ok(new { Message = "Reserva confirmada correctamente." })
                : NotFound(new { Message = "Reserva no encontrada o ya confirmada." });
        }

        // ======================================================
        // 🧳 GESTIÓN DE PASAJEROS
        // ======================================================

        /// <summary>
        /// Agrega un nuevo pasajero a una reserva existente.
        /// </summary>
        /// <param name="id">Identificador de la reserva.</param>
        /// <param name="dto">Datos personales del pasajero a agregar.</param>
        [HttpPost("{id}/add-passenger")]
        [Authorize(Roles = "Admin, Broker, User")]
        public async Task<IActionResult> AddPassenger(int id, [FromBody] PassengerCreateDto dto)
        {
            var updated = await _reservationService.AddPassengerAsync(id, dto);
            return updated == null
                ? NotFound(new { Message = "Reserva no encontrada." })
                : Ok(updated);
        }

        // ======================================================
        // ✈️ ASIGNACIÓN DE VUELOS
        // ======================================================

        /// <summary>
        /// Asigna un vuelo existente a una reserva específica.
        /// </summary>
        /// <param name="id">Identificador de la reserva.</param>
        /// <param name="flightId">Identificador del vuelo a asociar.</param>
        [HttpPatch("{id}/assign-flight/{flightId}")]
        [Authorize(Roles = "Admin, Broker")]
        public async Task<IActionResult> AssignFlight(int id, int flightId)
        {
            var updated = await _reservationService.AssignFlightAsync(id, flightId);
            return updated == null
                ? NotFound(new { Message = "Reserva o vuelo no encontrado." })
                : Ok(updated);
        }
    }
}
