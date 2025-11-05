using AeroRide.API.Helpers;
using AeroRide.API.Interfaces;
using AeroRide.API.Models.DTOs.Aircrafts;
using AeroRide.API.Models.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador encargado de manejar las operaciones relacionadas con las aeronaves (avionetas),
    /// incluyendo creación, lectura, actualización, desactivación y filtrado agrupado por modelo.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Requiere autenticación por defecto
    public class AircraftsController : ControllerBase
    {
        private readonly IAircraftService _aircraftService;

        public AircraftsController(IAircraftService aircraftService)
        {
            _aircraftService = aircraftService;
        }

        // ============================================================
        // CREATE
        // ============================================================
        [HttpPost]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(AircraftResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateAircraft([FromBody] AircraftCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _aircraftService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetAircraftById), new { id = created.Id }, created);
        }

        // ============================================================
        // READ: LISTAR ACTIVAS
        // ============================================================
        [HttpGet]
        [Authorize(Roles = "Admin,CompanyAdmin,Pilot,User")]
        [ProducesResponseType(typeof(IEnumerable<AircraftResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllAircrafts()
        {
            var aircrafts = await _aircraftService.GetAllAsync();

            if (!aircrafts.Any())
                return NoContent();

            return Ok(aircrafts);
        }

        // ============================================================
        // READ: LISTAR TODAS (ACTIVAS + INACTIVAS)
        // ============================================================
        [HttpGet("all")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<AircraftResponseDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllIncludingInactive()
        {
            var aircrafts = await _aircraftService.GetAllIncludingInactiveAsync();

            if (!aircrafts.Any())
                return NoContent();

            return Ok(aircrafts);
        }

        // ============================================================
        // READ BY ID
        // ============================================================
        [HttpGet("{id:int}")]
        [Authorize(Roles = "Admin,CompanyAdmin,Pilot,User")]
        [ProducesResponseType(typeof(AircraftResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAircraftById(int id)
        {
            var aircraft = await _aircraftService.GetByIdAsync(id);
            if (aircraft == null)
                return NotFound($"No se encontró ninguna aeronave con el ID {id}.");

            return Ok(aircraft);
        }

        // ============================================================
        // UPDATE
        // ============================================================
        [HttpPut("{id:int}")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(AircraftResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateAircraft(int id, [FromBody] AircraftUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _aircraftService.UpdateAsync(id, dto);
            if (updated == null)
                return NotFound($"No se encontró ninguna aeronave con el ID {id}.");

            return Ok(updated);
        }

        // ============================================================
        // DELETE (SOFT DELETE)
        // ============================================================
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteAircraft(int id)
        {
            var result = await _aircraftService.DeleteAsync(id);
            if (!result)
                return NotFound(new { message = $"No se encontró ninguna aeronave activa con el ID {id}." });

            return Ok(new { message = $"Aeronave con ID {id} desactivada correctamente." });
        }

        // ============================================================
        // REACTIVATE
        // ============================================================
        [HttpPut("reactivate/{id:int}")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ReactivateAircraft(int id)
        {
            var success = await _aircraftService.ReactivateAsync(id);
            if (!success)
                return NotFound($"No se encontró ninguna aeronave inactiva con el ID {id}.");

            return Ok(new { message = "Aeronave reactivada exitosamente." });
        }

        // ============================================================
        // UPDATE STATE
        // ============================================================
        [HttpPatch("{id}/state")]
        [Authorize(Roles = "Admin,CompanyAdmin,Pilot")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateState(int id, [FromQuery] AircraftState state)
        {
            var result = await _aircraftService.UpdateStateAsync(id, state);
            return result.Success ? Ok(result.Message) : BadRequest(result.Message);
        }

        // ============================================================
        // 🆕 AGRUPACIÓN + FILTRO POR ASIENTOS (PARA RESERVAS)
        // ============================================================
        /// <summary>
        /// Obtiene todas las aeronaves disponibles agrupadas por modelo y compañía.
        /// Aplica filtros opcionales por número de asientos.
        /// </summary>
        /// <param name="minSeats">Cantidad mínima de asientos (opcional).</param>
        /// <param name="maxSeats">Cantidad máxima de asientos (opcional).</param>
        /// <returns>Lista agrupada de aeronaves disponibles por modelo y compañía.</returns>
        [HttpGet("grouped")]
        [Authorize(Roles = "Admin,CompanyAdmin,Pilot,User")]
        [ProducesResponseType(typeof(IEnumerable<AircraftCategoryDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> GetAvailableGroupedBySeats([FromQuery] int? minSeats, [FromQuery] int? maxSeats)
        {
            var grouped = await _aircraftService.GetAvailableGroupedBySeatsAsync(minSeats, maxSeats);

            if (!grouped.Any())
                return NoContent();

            return Ok(grouped);
        }

        // ============================================================
        // 🖼️ IMAGE UPLOAD
        // ============================================================

        /// <summary>
        /// Sube una imagen al contenedor de Azure Blob Storage y devuelve la URL pública.
        /// Solo los administradores o administradores de compañía pueden realizar esta acción.
        /// </summary>
        /// <param name="file">Archivo de imagen seleccionado por el usuario.</param>
        /// <param name="imageService">Servicio de imágenes inyectado mediante dependencia.</param>
        /// <returns>
        /// La URL pública de la imagen almacenada, o un mensaje de error si el archivo no es válido.
        /// </returns>
        [HttpPost("upload-image")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UploadImage(IFormFile file, [FromServices] IImageService imageService)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest(new { error = "Debe seleccionar una imagen válida para subir." });

                var imageUrl = await imageService.UploadImageAsync(file, "aircraft-images");
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ============================================================
        // GET: TODAS LAS AERONAVES (ACTIVAS + INACTIVAS) DE UNA EMPRESA
        // ============================================================
        [HttpGet("company/{companyId}/all")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<AircraftResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> GetAllByCompany(int companyId)
        {
            var aircrafts = await _aircraftService.GetAllByCompanyAsync(companyId);

            if (!aircrafts.Any())
                return NoContent();

            return Ok(aircrafts);
        }

        // ============================================================
        // GET: SOLO AERONAVES ACTIVAS DE UNA EMPRESA
        // ============================================================
        [HttpGet("company/{companyId}/active")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<AircraftResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> GetActiveByCompany(int companyId)
        {
            var aircrafts = await _aircraftService.GetActiveByCompanyAsync(companyId);

            if (!aircrafts.Any())
                return NoContent();

            return Ok(aircrafts);
        }


    }
}
