using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador encargado de la gestión de usuarios dentro del sistema AeroRide.
    /// Permite realizar operaciones administrativas y de perfil.
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
        /// <param name="userService">Servicio que gestiona la lógica de negocio de usuarios.</param>
        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        // ======================================================
        // 1️⃣ LISTAR TODOS LOS USUARIOS
        // ======================================================

        /// <summary>
        /// Obtiene la lista completa de usuarios registrados en el sistema.
        /// </summary>
        /// <returns>Colección de usuarios con información básica.</returns>
        [HttpGet]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<UserListDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _userService.GetAllUsersAsync();
            return Ok(users);
        }

        // ======================================================
        // 2️⃣ OBTENER USUARIO POR ID
        // ======================================================

        /// <summary>
        /// Obtiene los detalles completos de un usuario específico.
        /// </summary>
        /// <param name="id">Identificador único del usuario.</param>
        /// <returns>Información detallada del usuario.</returns>
        [HttpGet("{id:int}")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(UserDetailDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetUserById(int id)
        {
            var user = await _userService.GetUserByIdAsync(id);
            if (user == null)
                return NotFound(new { message = "Usuario no encontrado." });

            return Ok(user);
        }

        // ======================================================
        // 3️⃣ OBTENER PERFIL DEL USUARIO AUTENTICADO
        // ======================================================

        /// <summary>
        /// Obtiene el perfil del usuario autenticado actualmente.
        /// </summary>
        /// <returns>Datos del perfil del usuario autenticado.</returns>
        [HttpGet("profile")]
        [ProducesResponseType(typeof(UserProfileDto), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProfile()
        {
            // Buscar el ID del usuario en distintos claim types posibles
            var userIdClaim = User.FindFirstValue("sub") ??
                              User.FindFirstValue(ClaimTypes.NameIdentifier) ??
                              User.FindFirstValue(ClaimTypes.Name);

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return Unauthorized(new { message = "Token inválido o sin información del usuario." });

            var profile = await _userService.GetProfileAsync(userId);

            if (profile == null)
                return NotFound(new { message = "Perfil no encontrado." });

            return Ok(profile);
        }

        // ======================================================
        // 4️⃣ CREAR USUARIO (ADMIN)
        // ======================================================

        /// <summary>
        /// Crea un nuevo usuario de forma manual (solo administradores).
        /// </summary>
        /// <param name="dto">Datos del nuevo usuario.</param>
        /// <returns>Usuario creado.</returns>
        [HttpPost]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateUser([FromBody] CreateUserDto dto)
        {
            try
            {
                var createdUser = await _userService.CreateUserAsync(dto);
                return CreatedAtAction(nameof(GetUserById), new { id = createdUser.Id }, createdUser);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 5️⃣ ACTUALIZAR PERFIL PERSONAL
        // ======================================================

        /// <summary>
        /// Permite al usuario autenticado actualizar su propio perfil.
        /// </summary>
        /// <param name="dto">Datos actualizados del perfil.</param>
        /// <returns>Perfil actualizado.</returns>
        [HttpPut("profile")]
        [ProducesResponseType(typeof(UserProfileDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateProfile([FromBody] UserUpdateDto dto)
        {
            // Buscar el ID en distintos claim types posibles
            var userIdClaim = User.FindFirstValue("sub") ??
                              User.FindFirstValue(ClaimTypes.NameIdentifier) ??
                              User.FindFirstValue(ClaimTypes.Name) ??
                              User.FindFirstValue("userId"); // opcional si luego lo agregás en JwtHelper

            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return Unauthorized(new { message = "Token inválido o sin información del usuario." });

            var updated = await _userService.UpdateProfileAsync(userId, dto);

            if (updated == null)
                return NotFound(new { message = "Usuario no encontrado." });

            return Ok(updated);
        }

        // ======================================================
        // 6️⃣ ACTUALIZAR USUARIO (ADMIN)
        // ======================================================

        /// <summary>
        /// Permite a un administrador actualizar los datos de cualquier usuario.
        /// </summary>
        /// <param name="id">ID del usuario a modificar.</param>
        /// <param name="dto">Datos a actualizar.</param>
        /// <returns>Usuario actualizado.</returns>
        [HttpPut("{id:int}")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(UserProfileDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
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
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 7️⃣ DESACTIVAR USUARIO (SOFT DELETE)
        // ======================================================

        /// <summary>
        /// Desactiva un usuario sin eliminarlo físicamente de la base de datos.
        /// </summary>
        /// <param name="id">ID del usuario a desactivar.</param>
        /// <returns>Confirmación de la desactivación.</returns>
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
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
                return BadRequest(new { error = ex.Message});
            }
        }

        // ======================================================
        // 8️⃣ REACTIVAR USUARIO
        // ======================================================

        /// <summary>
        /// Reactiva un usuario previamente desactivado.
        /// </summary>
        /// <param name="id">ID del usuario a reactivar.</param>
        /// <returns>Confirmación de la reactivación.</returns>
        [HttpPut("{id:int}/reactivate")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> ReactivateUser(int id)
        {
            try
            {
                var result = await _userService.ReactivateUserAsync(id);
                if (!result)
                    return NotFound(new { message = "Usuario no encontrado." });
                    
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ======================================================
        // 9️⃣ LISTAR PILOTOS
        // ======================================================

        /// <summary>
        /// Obtiene todos los usuarios activos con rol de "Pilot".
        /// </summary>
        /// <returns>Lista de pilotos activos.</returns>
        [HttpGet("pilots")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<UserListDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAllPilots()
        {
            var pilots = await _userService.GetAllPilotsAsync();
            return Ok(pilots);
        }


        [HttpGet("company/{companyId}/pilots")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<UserListDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetPilotsByCompany(int companyId)
        {
            var result = await _userService.GetPilotsByCompanyAsync(companyId);
            return Ok(result);
        }

        /// <summary>
        /// Obtiene los pilotos y administradores pertenecientes a una empresa.
        /// Solo accesible por AdminGeneral o CompanyAdmin.
        /// </summary>
        [HttpGet("company/{companyId}/pilots-admins")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<UserListDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetPilotsAndAdminsByCompany(int companyId)
        {
            var result = await _userService.GetPilotsAndAdminsByCompanyAsync(companyId);
            return Ok(result);
        }

        /// <summary>
        /// Obtiene todos los administradores de una compañía específica.
        /// Solo accesible para roles "Admin" o "CompanyAdmin".
        /// </summary>
        [HttpGet("company/{companyId}/admins")]
        [Authorize(Roles = "Admin,CompanyAdmin")]
        [ProducesResponseType(typeof(IEnumerable<UserListDto>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAdminsByCompany(int companyId)
        {
            var result = await _userService.GetAdminsByCompanyAsync(companyId);
            return Ok(result);
        }

    }
}
