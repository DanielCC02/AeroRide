using AeroRide.API.Interfaces;
using AeroRide.API.Models.DTOs.Airports;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador encargado de manejar las operaciones relacionadas con los aeropuertos.
    /// Incluye creación, consulta, actualización, eliminación y carga de imágenes.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Requiere autenticación para todos los métodos
    public class AirportsController : ControllerBase
    {
        private readonly IAirportService _airportService;

        public AirportsController(IAirportService airportService)
        {
            _airportService = airportService;
        }

        // ======================================================
        // 🔹 GET: /api/airports
        // ======================================================

        /// <summary>
        /// Obtiene la lista de aeropuertos activos, ordenados por Id.
        /// </summary>
        [HttpGet]
        [Authorize(Roles = "Admin, Broker, Pilot, User")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> GetActiveAirports()
        {
            var airports = await _airportService.GetAllActiveAsync();
            return Ok(airports);
        }

        // ======================================================
        // 🔹 GET: /api/airports/all
        // ======================================================

        /// <summary>
        /// Obtiene todos los aeropuertos registrados (activos e inactivos), ordenados por Id.
        /// Solo visible para administradores.
        /// </summary>
        [HttpGet("all")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllAirports()
        {
            var airports = await _airportService.GetAllAsync();
            return Ok(airports);
        }

        // ======================================================
        // 🔹 GET: /api/airports/{id}
        // ======================================================

        /// <summary>
        /// Obtiene la información detallada de un aeropuerto específico por su Id.
        /// </summary>
        [HttpGet("{id:int}")]
        [Authorize(Roles = "Admin, Broker, Pilot, User")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAirportById(int id)
        {
            var airport = await _airportService.GetByIdAsync(id);
            if (airport == null)
                return NotFound(new { message = $"No se encontró el aeropuerto con Id {id}." });

            return Ok(airport);
        }

        // ======================================================
        // 🔹 POST: /api/airports
        // ======================================================

        /// <summary>
        /// Crea un nuevo aeropuerto en el sistema.
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateAirport([FromBody] AirportCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _airportService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetAirportById), new { id = created.Id }, created);
        }

        // ======================================================
        // 🔹 PUT: /api/airports/{id}
        // ======================================================

        /// <summary>
        /// Actualiza los datos de un aeropuerto existente.
        /// </summary>
        [HttpPut("{id:int}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateAirport(int id, [FromBody] AirportUpdateDto dto)
        {
            var updated = await _airportService.UpdateAsync(id, dto);
            if (updated == null)
                return NotFound(new { message = $"No se encontró el aeropuerto con Id {id}." });

            return Ok(updated);
        }

        // ======================================================
        // 🔹 DELETE: /api/airports/{id}
        // ======================================================

        /// <summary>
        /// Desactiva (elimina lógicamente) un aeropuerto.
        /// </summary>
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeactivateAirport(int id)
        {
            var result = await _airportService.DeactivateAsync(id);
            if (!result)
                return NotFound(new { message = $"No se encontró el aeropuerto con Id {id}." });

            return Ok(new { message = $"El aeropuerto con Id {id} fue desactivado correctamente." });
        }

        // ======================================================
        // 🔹 PUT: /api/airports/reactivate/{id}
        // ======================================================

        /// <summary>
        /// Reactiva un aeropuerto previamente desactivado.
        /// </summary>
        [HttpPut("reactivate/{id:int}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ReactivateAirport(int id)
        {
            var result = await _airportService.ReactivateAsync(id);
            if (!result)
                return NotFound(new { message = $"No se encontró el aeropuerto con Id {id}." });

            return Ok(new { message = $"El aeropuerto con Id {id} fue reactivado correctamente." });
        }

        // ======================================================
        // 🔹 POST: /api/airports/ImageUpload
        // ======================================================

        /// <summary>
        /// Sube una imagen al contenedor de Azure Blob Storage y devuelve la URL pública.
        /// Solo los administradores pueden realizar esta acción.
        /// </summary>
        [HttpPost("ImageUpload")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UploadImage(IFormFile file, [FromServices] IImageService imageService)
        {
            try
            {
                var imageUrl = await imageService.UploadImageAsync(file, "airport-images");
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
