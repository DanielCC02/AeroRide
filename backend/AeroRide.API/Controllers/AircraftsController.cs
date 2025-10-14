using AeroRide.API.Helpers;
using AeroRide.API.Interfaces;
using AeroRide.API.Models.DTOs.Aircrafts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador encargado de manejar las operaciones relacionadas con las aeronaves (avionetas),
    /// incluyendo creación, lectura, actualización y carga de imágenes.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Requiere autenticación por defecto para todos los métodos
    public class AircraftsController : ControllerBase
    {
        private readonly IAircraftService _aircraftService;

        /// <summary>
        /// Inicializa una nueva instancia del controlador <see cref="AircraftsController"/>.
        /// </summary>
        /// <param name="aircraftService">Servicio encargado de la lógica de negocio de aeronaves.</param>
        public AircraftsController(IAircraftService aircraftService)
        {
            _aircraftService = aircraftService;
        }

        // ============================================================
        // CREATE
        // ============================================================

        /// <summary>
        /// Crea una nueva aeronave en el sistema.
        /// Solo los usuarios con rol de administrador pueden ejecutar esta acción.
        /// </summary>
        /// <param name="dto">Datos de la aeronave a crear.</param>
        /// <returns>Información de la aeronave creada.</returns>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateAircraft([FromBody] AircraftCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var createdAircraft = await _aircraftService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetAircraftById), new { id = createdAircraft.Id }, createdAircraft);
        }

        // ============================================================
        // READ
        // ============================================================

        /// <summary>
        /// Obtiene la lista de todas las aeronaves registradas en el sistema.
        /// Accesible para usuarios autenticados de cualquier rol.
        /// </summary>
        [HttpGet]
        [Authorize(Roles = "Admin,Broker,Pilot,User")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAllAircrafts()
        {
            var aircrafts = await _aircraftService.GetAllAsync();

            if (!aircrafts.Any())
                return NoContent();

            return Ok(aircrafts);
        }

        /// <summary>
        /// Obtiene todas las aeronaves registradas, tanto activas como inactivas.
        /// Solo los administradores pueden acceder a esta información.
        /// </summary>
        [HttpGet("all")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAllIncludingInactive()
        {
            var aircrafts = await _aircraftService.GetAllIncludingInactiveAsync();

            if (!aircrafts.Any())
                return NoContent();

            return Ok(aircrafts);
        }

        /// <summary>
        /// Obtiene los datos de una aeronave específica por su ID.
        /// Accesible para todos los roles autenticados.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,Broker,Pilot,User")]
        [ProducesResponseType(StatusCodes.Status200OK)]
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

        /// <summary>
        /// Actualiza los datos de una aeronave existente.
        /// Solo los administradores pueden ejecutar esta acción.
        /// </summary>
        /// <param name="id">Identificador de la aeronave a modificar.</param>
        /// <param name="dto">Datos actualizados de la aeronave.</param>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
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
        // IMAGE UPLOAD
        // ============================================================

        /// <summary>
        /// Sube una imagen al contenedor de Azure Blob Storage y devuelve la URL pública.
        /// Solo los administradores pueden realizar esta acción.
        /// </summary>
        /// <param name="file">Archivo de imagen seleccionado por el usuario.</param>
        /// <param name="imageService">Servicio de imágenes inyectado.</param>
        /// <returns>La URL pública de la imagen almacenada o un mensaje de error si el archivo no es válido.</returns>
        [HttpPost("ImageUpload")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> UploadImage(IFormFile file, [FromServices] IImageService imageService)
        {
            try
            {
                var imageUrl = await imageService.UploadImageAsync(file, "aircraft-images");
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }


        // ======================================================
        // 6️⃣ DELETE /api/aircrafts/{id}
        // ======================================================

        /// <summary>
        /// Desactiva (elimina lógicamente) una aeronave del sistema.
        /// Solo los administradores pueden ejecutar esta acción.
        /// </summary>
        /// <param name="id">ID de la aeronave a desactivar.</param>
        /// <returns>
        /// Un mensaje de confirmación si se desactivó correctamente, 
        /// o un mensaje de error si no se encontró o ocurrió un problema.
        /// </returns>
        [Authorize(Roles = "Admin")]
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteAircraft(int id)
        {
            try
            {
                var result = await _aircraftService.DeleteAsync(id);

                if (!result)
                    return NotFound(new { message = $"No se encontró ninguna aeronave activa con el ID {id}." });

                return Ok(new { message = $"Aeronave con ID {id} desactivada correctamente." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }


        // ============================================================
        // REACTIVATE
        // ============================================================

        /// <summary>
        /// Reactiva una aeronave previamente desactivada (soft delete).
        /// Solo los administradores pueden realizar esta acción.
        /// </summary>
        /// <param name="id">Identificador de la aeronave a reactivar.</param>
        [HttpPut("reactivate/{id}")]
        [Authorize(Roles = "Admin")]
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
        // UPDATE STATE /api/aircrafts/{id}/state
        // ============================================================

        /// <summary>
        /// Actualiza únicamente el estado operativo de una aeronave.
        /// Puede ser utilizado por administradores, pilotos o brokers autorizados.
        /// </summary>
        /// <param name="id">Identificador único de la aeronave.</param>
        /// <param name="request">Objeto que contiene el nuevo estado.</param>
        /// <returns>
        /// Mensaje de confirmación si la actualización fue exitosa,
        /// o un mensaje de error si la aeronave no existe o el estado es inválido.
        /// </returns>
        [HttpPut("{id}/state")]
        [Authorize(Roles = "Admin,Pilot,Broker")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateAircraftState(int id, [FromBody] UpdateAircraftStateDto request)
        {
            var result = await _aircraftService.UpdateStateAsync(id, request.State);

            if (!result.Success)
            {
                if (result.Message.Contains("no encontrada", StringComparison.OrdinalIgnoreCase))
                    return NotFound(new { message = result.Message });

                return BadRequest(new { message = result.Message });
            }

            return Ok(new { message = result.Message });
        }

        // ======================================================
        // 🔍 FILTER BY SEATS
        // ======================================================

        /// <summary>
        /// Filtra las aeronaves según el número mínimo o máximo de asientos.
        /// Ideal para mostrar solo avionetas disponibles según la selección del usuario.
        /// </summary>
        /// <param name="minSeats">Cantidad mínima de asientos requeridos.</param>
        /// <param name="maxSeats">Cantidad máxima de asientos (opcional).</param>
        /// <returns>Lista de aeronaves que cumplen con el filtro.</returns>
        [HttpGet("filter")]
        [Authorize(Roles = "Admin,Broker,Pilot,User")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public async Task<IActionResult> FilterAircrafts([FromQuery] int minSeats, [FromQuery] int? maxSeats)
        {
            var results = await _aircraftService.FilterBySeatsAsync(minSeats, maxSeats);
            return Ok(results);
        }


    }
}
