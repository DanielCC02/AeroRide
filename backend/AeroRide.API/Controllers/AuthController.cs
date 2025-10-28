using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeroRide.API.Controllers
{
    /// <summary>
    /// Controlador responsable de la autenticación y manejo de credenciales de usuario.
    /// Incluye endpoints para registro, inicio de sesión, verificación de cuenta,
    /// recuperación de contraseña y renovación de tokens.
    /// </summary>
    [ApiController]
    [Route("auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        /// <summary>
        /// Inicializa una nueva instancia del controlador de autenticación.
        /// </summary>
        /// <param name="authService">Servicio que gestiona las operaciones de autenticación.</param>
        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        // ======================================================
        // 1️⃣ REGISTRO DE USUARIOS
        // ======================================================

        /// <summary>
        /// Registra un nuevo usuario en la plataforma AeroRide.
        /// Envía un correo de verificación al usuario registrado.
        /// </summary>
        /// <param name="dto">Datos de registro proporcionados por el usuario.</param>
        /// <returns>Datos básicos del usuario creado.</returns>
        [HttpPost("register")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(UserResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Register([FromBody] UserRegisterDto dto)
        {
            try
            {
                var user = await _authService.RegisterAsync(dto);
                return CreatedAtAction(nameof(Register), new { user.Id }, user);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 2️⃣ LOGIN
        // ======================================================

        /// <summary>
        /// Inicia sesión validando las credenciales del usuario.
        /// Retorna un JWT válido y un refresh token.
        /// </summary>
        /// <param name="dto">Datos de inicio de sesión (correo y contraseña).</param>
        /// <returns>Token JWT y refresh token asociados al usuario autenticado.</returns>
        [HttpPost("login")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Login([FromBody] UserLoginDto dto)
        {
            try
            {
                var result = await _authService.LoginAsync(dto);
                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 3️⃣ REFRESH TOKEN
        // ======================================================

        /// <summary>
        /// Genera un nuevo JWT y refresh token a partir de un refresh token válido.
        /// </summary>
        /// <param name="dto">Objeto con el refresh token actual.</param>
        /// <returns>Nuevo JWT y refresh token.</returns>
        [HttpPost("refresh")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequestDto dto)
        {
            try
            {
                var result = await _authService.RefreshAsync(dto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 4️⃣ VERIFICAR CORREO
        // ======================================================

        /// <summary>
        /// Verifica la dirección de correo electrónico del usuario utilizando un token enviado por correo.
        /// </summary>
        /// <param name="token">Token único de verificación recibido por email.</param>
        /// <returns>Mensaje confirmando el resultado de la verificación.</returns>
        [HttpGet("verify-email")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> VerifyEmail([FromQuery] string token)
        {
            try
            {
                var result = await _authService.VerifyEmailAsync(token);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 5️⃣ LOGOUT
        // ======================================================

        /// <summary>
        /// Cierra sesión revocando el refresh token activo del usuario.
        /// </summary>
        /// <param name="refreshToken">Refresh token actual.</param>
        /// <returns>Confirmación del cierre de sesión.</returns>
        [HttpPost("logout")]
        [Authorize]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Logout(RefreshTokenRequestDto dto)
        {
            try
            {
                await _authService.LogoutAsync(dto.RefreshToken);
                return Ok(new { message = "Sesion cerrada correctamente." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 6️⃣ SOLICITAR RESTABLECIMIENTO DE CONTRASEÑA
        // ======================================================

        /// <summary>
        /// Envía un correo con un enlace para restablecer la contraseña del usuario.
        /// </summary>
        /// <param name="dto">Objeto con el correo electrónico del usuario.</param>
        /// <returns>Mensaje de confirmación del envío del correo.</returns>
        [HttpPost("forgot-password")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
        {
            try
            {
                var result = await _authService.SendPasswordResetEmailAsync(dto.Email);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 7️⃣ RESTABLECER CONTRASEÑA
        // ======================================================

        /// <summary>
        /// Restablece la contraseña del usuario utilizando el token recibido por correo.
        /// </summary>
        /// <param name="dto">Objeto que contiene el token y la nueva contraseña.</param>
        /// <returns>Mensaje confirmando el restablecimiento exitoso.</returns>
        [HttpPut("reset-password")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(string), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            try
            {
                var result = await _authService.ResetPasswordAsync(dto.Token, dto.NewPassword);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
