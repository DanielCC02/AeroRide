using AeroRide.API.Models.DTOs.EmptyLegs;
using AeroRide.API.Models.DTOs.Reservations;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador responsable de la gestión de reservas de vuelos.
    /// Permite crear nuevas reservas, obtener detalles, listar y cancelar.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "User,Admin,CompanyAdmin")]
    public class ReservationsController : ControllerBase
    {
        private readonly IReservationService _reservationService;

        public ReservationsController(IReservationService reservationService)
        {
            _reservationService = reservationService;
        }

        // ======================================================
        // 🟢 POST: api/reservations
        // ======================================================
        /// <summary>
        /// Crea una nueva reserva con pasajeros y vuelos asociados.
        /// </summary>
        /// <param name="dto">Datos de la reserva a crear.</param>
        /// <returns>Información completa de la reserva creada.</returns>
        [HttpPost]
        public async Task<ActionResult<ReservationResponseDto>> CreateReservation([FromBody] ReservationCreateDto dto)
        {
            try
            {
                // 🔹 Obtener el ID del usuario autenticado
                int userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

                var result = await _reservationService.CreateAsync(userId, dto);
                return CreatedAtAction(nameof(GetReservationById), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = $"Error al crear la reserva: {ex.Message}" });
            }
        }

        // ======================================================
        // 🔍 GET: api/reservations/{id}
        // ======================================================
        /// <summary>
        /// Obtiene el detalle completo de una reserva.
        /// </summary>
        /// <param name="id">Identificador único de la reserva.</param>
        [HttpGet("{id:int}")]
        public async Task<ActionResult<ReservationResponseDto>> GetReservationById(int id)
        {
            var reservation = await _reservationService.GetByIdAsync(id);
            if (reservation == null)
                return NotFound(new { message = "Reserva no encontrada." });

            return Ok(reservation);
        }

        // ======================================================
        // 📋 GET: api/reservations/my
        // ======================================================
        /// <summary>
        /// Obtiene todas las reservas realizadas por el usuario autenticado.
        /// </summary>
        [HttpGet("my")]
        public async Task<ActionResult<IEnumerable<ReservationResponseDto>>> GetMyReservations()
        {
            int userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var reservations = await _reservationService.GetByUserAsync(userId);

            if (!reservations.Any())
                return NotFound(new { message = "No tiene reservas registradas." });

            return Ok(reservations);
        }

        // ======================================================
        // ❌ PUT: api/reservations/{id}/cancel
        // ======================================================
        /// <summary>
        /// Cancela una reserva existente (y libera las aeronaves asociadas).
        /// </summary>
        /// <param name="id">Identificador único de la reserva a cancelar.</param>
        [HttpPut("{id:int}/cancel")]
        public async Task<IActionResult> CancelReservation(int id)
        {
            bool success = await _reservationService.CancelAsync(id);

            if (!success)
                return NotFound(new { message = "No se encontró la reserva a cancelar." });

            return Ok(new { message = "Reserva cancelada correctamente." });
        }

        [HttpPost("estimate")]
        [Authorize(Roles = "User,Admin,CompanyAdmin")]
        public async Task<ActionResult<ReservationEstimateResponseDto>> EstimateReservation([FromBody] ReservationEstimateDto dto)
        {
            try
            {
                var result = await _reservationService.EstimatePriceAsync(dto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ===================================================
        // POST: api/reservations/emptyleg
        // Crear una reserva basada en una empty leg
        // ===================================================
        [HttpPost("emptyleg")]
        [Authorize(Roles = "User,Admin,CompanyAdmin")]
        public async Task<IActionResult> ReserveEmptyLeg([FromBody] EmptyLegReservationCreateDto dto)
        {
            var result = await _reservationService.ReserveEmptyLegAsync(dto);
            return Ok(result);
        }

        [HttpGet("my/upcoming")]
        [Authorize]
        public async Task<IActionResult> GetUpcomingTrips()
        {
            int userId = int.Parse(User.FindFirst("id")!.Value);
            var trips = await _reservationService.GetUpcomingTripsAsync(userId);
            return Ok(trips);
        }

        [HttpGet("my/past")]
        [Authorize]
        public async Task<IActionResult> GetPastTrips()
        {
            int userId = int.Parse(User.FindFirst("id")!.Value);
            var trips = await _reservationService.GetPastTripsAsync(userId);
            return Ok(trips);
        }


    }
}
