using AeroRide.API.Models.DTOs.FlightAssignments;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador para consultar los vuelos de una compañía.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class FlightsController : ControllerBase
    {
        private readonly IFlightService _flightService;

        public FlightsController(IFlightService flightService)
        {
            _flightService = flightService;
        }

        /// <summary>
        /// Devuelve todos los vuelos asociados a una compañía específica.
        /// Incluye los vuelos comerciales y los Empty Legs.
        /// </summary>
        [HttpGet("company/{companyId}")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        public async Task<IActionResult> GetByCompany(int companyId)
        {
            var result = await _flightService.GetFlightsByCompanyAsync(companyId);
            return Ok(result);
        }

        // ======================================================
        // POST: ASIGNAR PILOTO Y COPILOTO A UN VUELO
        // ======================================================
        [HttpPost("{flightId}/assign")]
        public async Task<IActionResult> AssignPilots(int flightId, [FromBody] FlightAssignmentCreateDto dto)
        {
            await _flightService.AssignPilotsToFlightAsync(flightId, dto);
            return Ok(new { message = "Pilotos asignados correctamente." });
        }


        // ======================================================
        // GET: OBTENER VUELOS ASIGNADOS A UN PILOTO
        // ======================================================
        [HttpGet("pilot/{pilotId}")]
        public async Task<IActionResult> GetFlightsByPilot(int pilotId)
        {
            var flights = await _flightService.GetFlightsByPilotAsync(pilotId);
            return Ok(flights);
        }

        [HttpGet("{flightId}/pilots")]
        public async Task<IActionResult> GetPilotsByFlight(int flightId)
        {
            var pilots = await _flightService.GetPilotsByFlightAsync(flightId);
            return Ok(pilots);
        }

        // ===================================================
        // GET: api/flights/emptylegs
        // Lista todas las empty legs futuras, ordenadas por fecha
        // ===================================================
        [HttpGet("emptylegs")]
        public async Task<IActionResult> GetEmptyLegs()
        {
            var result = await _flightService.GetEmptyLegsAsync();
            return Ok(result);
        }

        // ===================================================
        // GET: api/flights/emptylegs/{id}
        // Trae todos los detalles de una Empty Leg específica
        // ===================================================
        [HttpGet("emptylegs/{id}")]
        public async Task<IActionResult> GetEmptyLegDetail(int id)
        {
            var result = await _flightService.GetEmptyLegDetailAsync(id);

            if (result == null)
                return NotFound(new { message = "Empty leg not found." });

            return Ok(result);
        }

        [HttpPut("{id}/status")]
        [Authorize(Roles = "Admin,CompanyAdmin, Pilot")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateFlightStatusDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _flightService.UpdateFlightStatusAsync(id, dto.Status);
                return Ok(new { message = "Flight status updated successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
