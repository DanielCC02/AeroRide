using AeroRide.API.Models.DTOs.FlightAssignments;
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
    }
}
