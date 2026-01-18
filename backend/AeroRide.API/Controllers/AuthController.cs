using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using AeroRide.Helpers.Templates;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Controllers
{
    [ApiController]
    [Route("auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        // ======================================================
        // 1️⃣ REGISTER
        // ======================================================
        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] UserRegisterDto dto)
        {
            try
            {
                var user = await _authService.RegisterAsync(dto);
                return CreatedAtAction(nameof(Register), new { user.Id }, user);
            }
            catch (ValidationException ex)
            {
                // Errores de validación (consentimiento, email duplicado, etc.)
                return BadRequest(new
                {
                    message = ex.Message
                });
            }
            catch (Exception)
            {
                // Error inesperado (no se expone detalle interno)
                return StatusCode(500, new
                {
                    message = "An unexpected error occurred. Please try again later."
                });
            }
        }


        // ======================================================
        // 2️⃣ LOGIN
        // ======================================================
        [HttpPost("login")]
        [AllowAnonymous]
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
        [HttpPost("refresh")]
        [AllowAnonymous]
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
        // 4️⃣ VERIFY EMAIL (HTML)
        // ======================================================
        [HttpGet("verify-email")]
        [AllowAnonymous]
        public async Task<IActionResult> VerifyEmail([FromQuery] string token)
        {
            try
            {
                var result = await _authService.VerifyEmailAsync(token);

                return Content(
                    EmailVerificationResultTemplate.Success(result),
                    "text/html"
                );
            }
            catch (Exception ex)
            {
                Response.StatusCode = StatusCodes.Status400BadRequest;

                return Content(
                    EmailVerificationResultTemplate.Error(ex.Message),
                    "text/html"
                );
            }
        }

        // ======================================================
        // 5️⃣ LOGOUT
        // ======================================================
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout([FromBody] RefreshTokenRequestDto dto)
        {
            try
            {
                await _authService.LogoutAsync(dto.RefreshToken);
                return Ok(new { message = "Session closed successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ======================================================
        // 6️⃣ FORGOT PASSWORD (SEND EMAIL)
        // ======================================================
        [HttpPost("forgot-password")]
        [AllowAnonymous]
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
        // 7️⃣ RESET PASSWORD (HTML FORM)
        // ======================================================
        [HttpGet("reset-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPasswordPage([FromQuery] string token)
        {
            try
            {
                await _authService.ValidatePasswordResetTokenAsync(token);

                return Content(
                    PasswordResetResultTemplate.Form(token),
                    "text/html"
                );
            }
            catch (Exception ex)
            {
                return Content(
                    PasswordResetResultTemplate.ErrorFinal(ex.Message),
                    "text/html"
                );
            }
        }

        // ======================================================
        // 8️⃣ RESET PASSWORD (HTML SUBMIT)
        // ======================================================
        [HttpPost("reset-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPasswordSubmit(
            [FromForm] string token,
            [FromForm] string newPassword,
            [FromForm] string confirmPassword
        )
        {
            // ❌ Form error → stay in form
            if (newPassword != confirmPassword)
            {
                return Content(
                    PasswordResetResultTemplate.Form(
                        token,
                        "Passwords do not match."
                    ),
                    "text/html"
                );
            }

            try
            {
                await _authService.ResetPasswordAsync(token, newPassword);

                return Content(
                    PasswordResetResultTemplate.Success(),
                    "text/html"
                );
            }
            catch (Exception ex)
            {
                return Content(
                    PasswordResetResultTemplate.ErrorFinal(ex.Message),
                    "text/html"
                );
            }
        }




        // ======================================================
        // 9️⃣ RESET PASSWORD (API / FLUTTER)
        // ======================================================
        [HttpPut("reset-password")]
        [AllowAnonymous]
        public async Task<IActionResult> ResetPasswordApi([FromBody] ResetPasswordDto dto)
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
