using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador responsable de la autenticación y manejo de credenciales de usuario.
    /// Incluye endpoints para registro, inicio de sesión, actualización de tokens y recuperación de contraseñas.
    /// </summary>
    [ApiController]
    [Route("auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        /// <summary>
        /// Inicializa una nueva instancia del controlador de autenticación.
        /// </summary>
        /// <param name="authService">Servicio encargado de la lógica de autenticación y generación de tokens.</param>
        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        // =======================================================
        //  🔹 REGISTRO DE USUARIOS
        // =======================================================

        /// <summary>
        /// Registra un nuevo usuario en el sistema.
        /// </summary>
        /// <param name="dto">Datos de registro del usuario (nombre, correo, contraseña, etc.).</param>
        /// <returns>Objeto con la información del usuario registrado.</returns>
        /// <remarks>
        /// Este endpoint es público, no requiere autenticación.
        /// </remarks>
        [HttpPost("register")]
        [AllowAnonymous] // ✅ Público: usuarios nuevos no tienen token todavía
        public async Task<ActionResult<UserResponseDto>> Register(UserRegisterDto dto)
        {
            try
            {
                var result = await _authService.RegisterAsync(dto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // =======================================================
        //  🔹 LOGIN
        // =======================================================

        /// <summary>
        /// Autentica al usuario y genera los tokens JWT y Refresh Token.
        /// </summary>
        /// <param name="dto">Credenciales del usuario (correo y contraseña).</param>
        /// <returns>Tokens de acceso y refresco válidos para la sesión.</returns>
        /// <remarks>
        /// Este endpoint es público y permite a los usuarios autenticarse.
        /// </remarks>
        [HttpPost("login")]
        [AllowAnonymous] // ✅ Público: permite obtener el token
        public async Task<ActionResult<AuthResponseDto>> Login(UserLoginDto dto)
        {
            try
            {
                var result = await _authService.LoginAsync(dto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        // =======================================================
        //  🔹 REFRESH TOKEN
        // =======================================================

        /// <summary>
        /// Refresca el JWT de un usuario autenticado utilizando su Refresh Token.
        /// </summary>
        /// <param name="dto">Token de refresco actual emitido previamente.</param>
        /// <returns>Nuevo token JWT y refresh token.</returns>
        /// <remarks>
        /// Este endpoint debe estar protegido, ya que requiere un token de refresco válido.
        /// </remarks>
        [HttpPost("refresh")]
        [AllowAnonymous] // ⚠️ Puede mantenerse público porque el refresh token ya se valida internamente
        public async Task<ActionResult<AuthResponseDto>> Refresh(RefreshTokenRequestDto dto)
        {
            try
            {
                var result = await _authService.RefreshAsync(dto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        // =======================================================
        //  🔹 LOGOUT
        // =======================================================

        /// <summary>
        /// Cierra sesión y revoca el token de refresco asociado al usuario.
        /// </summary>
        /// <param name="dto">Refresh token a invalidar.</param>
        /// <returns>Mensaje de confirmación de cierre de sesión.</returns>
        /// <remarks>
        /// Este endpoint requiere que el usuario esté autenticado.
        /// </remarks>
        [HttpPost("logout")]
        [Authorize] // ✅ Protegido: solo usuarios autenticados pueden cerrar sesión
        public async Task<IActionResult> Logout(RefreshTokenRequestDto dto)
        {
            await _authService.LogoutAsync(dto.RefreshToken);
            return Ok(new { message = "Sesión cerrada correctamente." });
        }

        // =======================================================
        //  🔹 VERIFICACIÓN DE CORREO
        // =======================================================

        /// <summary>
        /// Verifica la dirección de correo electrónico del usuario mediante un token enviado por email.
        /// </summary>
        /// <param name="token">Token de verificación recibido por correo.</param>
        /// <returns>Mensaje de confirmación de verificación de correo.</returns>
        [HttpGet("verify-email")]
        [AllowAnonymous] // ✅ Público: los usuarios verifican su email sin iniciar sesión
        public async Task<IActionResult> VerifyEmail([FromQuery] string token)
        {
            try
            {
                var message = await _authService.VerifyEmailAsync(token);
                return Ok(new { message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // =======================================================
        //  🔹 RECUPERACIÓN DE CONTRASEÑA
        // =======================================================

        /// <summary>
        /// Envía un correo con el enlace para restablecer la contraseña.
        /// </summary>
        /// <param name="dto">Correo electrónico del usuario que solicita el restablecimiento.</param>
        /// <returns>Mensaje indicando el resultado del envío.</returns>
        [HttpPost("forgot-password")]
        [AllowAnonymous] // ✅ Público: se usa cuando el usuario no puede iniciar sesión
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
        {
            try
            {
                var message = await _authService.SendPasswordResetEmailAsync(dto.Email);
                return Ok(new { message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        /// <summary>
        /// Restablece la contraseña del usuario mediante un token válido.
        /// </summary>
        /// <param name="dto">Datos con el token de recuperación y la nueva contraseña.</param>
        /// <returns>Mensaje de confirmación de restablecimiento de contraseña.</returns>
        [HttpPut("reset-password")]
        [AllowAnonymous] // ✅ Público: el usuario aún no está autenticado
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            try
            {
                var message = await _authService.ResetPasswordAsync(dto.Token, dto.NewPassword);
                return Ok(new { message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
