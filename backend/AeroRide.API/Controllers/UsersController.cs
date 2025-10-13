using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador responsable de la gestión de usuarios.
    /// Incluye operaciones para administración, consulta y perfil del usuario autenticado.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // 🔒 Todos los métodos requieren autenticación por defecto
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        /// <summary>
        /// Inicializa una nueva instancia del controlador de usuarios.
        /// </summary>
        /// <param name="userService">Servicio de negocio encargado de las operaciones sobre usuarios.</param>
        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        // ======================================================
        // 1️⃣ GET /api/users
        // ======================================================
        /// <summary>
        /// Obtiene la lista de todos los usuarios registrados.
        /// Solo accesible para administradores.
        /// </summary>
        /// <returns>Lista de usuarios con su información básica.</returns>
        /// <response code="200">Lista de usuarios devuelta correctamente.</response>
        [Authorize(Roles = "Admin")]
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var users = await _userService.GetAllUsersAsync();
            return Ok(users);
        }

        // ======================================================
        // 2️⃣ GET /api/users/{id}
        // ======================================================
        /// <summary>
        /// Obtiene la información detallada de un usuario específico por su ID.
        /// </summary>
        /// <param name="id">Identificador único del usuario.</param>
        /// <returns>Objeto con los datos del usuario o 404 si no existe.</returns>
        [Authorize(Roles = "Admin")]
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var user = await _userService.GetUserByIdAsync(id);

            if (user == null)
                return NotFound(new { message = "Usuario no encontrado." });

            return Ok(user);
        }

        // ======================================================
        // 3️⃣ GET /api/users/me
        // ======================================================
        /// <summary>
        /// Obtiene el perfil del usuario autenticado según el token JWT.
        /// </summary>
        /// <returns>Perfil del usuario autenticado.</returns>
        [HttpGet("me")]
        public async Task<IActionResult> GetMyProfile()
        {
            var userIdClaim = User.FindFirstValue("sub") ??
                              User.FindFirstValue(ClaimTypes.NameIdentifier) ??
                              User.FindFirstValue(ClaimTypes.Name);

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return Unauthorized(new { message = "Token inválido o sin información del usuario." });

            var user = await _userService.GetProfileAsync(userId);

            if (user == null)
                return NotFound(new { message = "Usuario no encontrado." });

            return Ok(user);
        }

        // ======================================================
        // 4️⃣ POST /api/users
        // ======================================================
        /// <summary>
        /// Crea un nuevo usuario manualmente (solo para administradores).
        /// </summary>
        /// <param name="dto">Datos del usuario a crear.</param>
        /// <returns>Usuario creado con su información básica.</returns>
        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var user = await _userService.CreateUserAsync(dto);
                return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ======================================================
        // 5️⃣ PUT /api/users/me
        // ======================================================
        /// <summary>
        /// Actualiza los datos personales del usuario autenticado.
        /// </summary>
        /// <param name="dto">Datos actualizados del perfil.</param>
        /// <returns>Perfil actualizado o mensaje de error.</returns>
        [HttpPut("me")]
        public async Task<IActionResult> UpdateMyProfile([FromBody] UserUpdateDto dto)
        {
            var userIdClaim = User.FindFirstValue("sub") ??
                              User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return Unauthorized(new { message = "Token inválido o no contiene información del usuario." });

            try
            {
                var updatedUser = await _userService.UpdateProfileAsync(userId, dto);
                if (updatedUser == null)
                    return NotFound(new { message = "Usuario no encontrado." });

                return Ok(updatedUser);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ======================================================
        // 6️⃣ DELETE /api/users/{id}
        // ======================================================
        /// <summary>
        /// Desactiva un usuario (soft delete). Solo administradores pueden hacerlo.
        /// </summary>
        /// <param name="id">ID del usuario a desactivar.</param>
        /// <returns>Mensaje de confirmación o error.</returns>
        [Authorize(Roles = "Admin")]
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            try
            {
                var result = await _userService.DeleteUserAsync(id);
                if (!result)
                    return NotFound(new { message = "Usuario no encontrado." });

                return Ok(new { message = $"Usuario con ID {id} desactivado correctamente." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ======================================================
        // 7️⃣ PUT /api/users/{id}/reactivate
        // ======================================================
        /// <summary>
        /// Reactiva un usuario previamente desactivado.
        /// Solo administradores pueden realizar esta acción.
        /// </summary>
        /// <param name="id">Identificador del usuario a reactivar.</param>
        /// <returns>Mensaje de éxito o error.</returns>
        [Authorize(Roles = "Admin")]
        [HttpPut("{id:int}/reactivate")]
        public async Task<IActionResult> ReactivateUser(int id)
        {
            try
            {
                var result = await _userService.ReactivateUserAsync(id);
                if (!result)
                    return NotFound(new { message = "Usuario no encontrado." });

                return Ok(new { message = $"Usuario con ID {id} reactivado correctamente." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ======================================================
        // 8️⃣ PUT /api/users/{id}
        // ======================================================
        /// <summary>
        /// Permite a un administrador actualizar los datos de cualquier usuario.
        /// </summary>
        /// <param name="id">ID del usuario a actualizar.</param>
        /// <param name="dto">Datos nuevos del usuario.</param>
        /// <returns>Usuario actualizado o mensaje de error.</returns>
        [Authorize(Roles = "Admin")]
        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdateUserByAdmin(int id, [FromBody] UserUpdateAdminDto dto)
        {
            try
            {
                var updatedUser = await _userService.UpdateUserByAdminAsync(id, dto);
                if (updatedUser == null)
                    return NotFound(new { message = "Usuario no encontrado." });

                return Ok(updatedUser);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ============================================================
        // GET /api/users/pilots
        // ============================================================

        /// <summary>
        /// Obtiene la lista de todos los usuarios con el rol de piloto.
        /// Solo los administradores pueden acceder a este listado.
        /// </summary>
        [HttpGet("pilots")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> GetAllPilots()
        {
            var pilots = await _userService.GetAllPilotsAsync();

            if (!pilots.Any())
                return NoContent();

            return Ok(pilots);
        }

    }
}
