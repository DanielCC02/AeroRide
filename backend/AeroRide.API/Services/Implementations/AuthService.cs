using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using AeroRide.API.Helpers.Templates;
using AeroRide.API.Models.DTOs.Authorization;

namespace AeroRide.API.Services.Implementations
{
    /// <summary>
    /// Servicio encargado de la autenticación y gestión de credenciales de usuario.
    /// Incluye registro, inicio de sesión, verificación de correo, refresco de tokens,
    /// cierre de sesión y restablecimiento de contraseña.
    /// </summary>
    public class AuthService : IAuthService
    {
        private readonly AeroRideDbContext _db;
        private readonly IMapper _mapper;
        private readonly IConfiguration _config;

        /// <summary>
        /// Inicializa una nueva instancia del servicio de autenticación.
        /// </summary>
        /// <param name="db">Contexto de base de datos de AeroRide.</param>
        /// <param name="mapper">Instancia de AutoMapper para mapear entidades y DTOs.</param>
        /// <param name="config">Configuración general del sistema (appsettings.json).</param>
        public AuthService(AeroRideDbContext db, IMapper mapper, IConfiguration config)
        {
            _db = db;
            _mapper = mapper;
            _config = config;
        }

        // ======================================================
        // 1️⃣ REGISTRO DE USUARIOS
        // ======================================================

        /// <summary>
        /// Registra un nuevo usuario en el sistema, encripta su contraseña,
        /// genera un token de verificación y envía un correo de confirmación.
        /// </summary>
        /// <param name="dto">Datos de registro proporcionados por el usuario.</param>
        /// <returns>
        /// Un objeto <see cref="UserResponseDto"/> con los datos básicos del usuario creado.
        /// </returns>
        /// <exception cref="Exception">
        /// Se lanza si el correo electrónico ya se encuentra registrado.
        /// </exception>
        public async Task<UserResponseDto> RegisterAsync(UserRegisterDto dto)
        {
            if (await _db.Users.AnyAsync(u => u.Email == dto.Email))
                throw new Exception("El correo ya está registrado.");

            var user = _mapper.Map<User>(dto);
            user.Password = PasswordHelper.HashPassword(dto.Password);
            user.EmailVerificationToken = Guid.NewGuid().ToString();
            user.IsVerified = false;

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            await SendVerificationEmailAsync(user);

            return _mapper.Map<UserResponseDto>(user);
        }

        /// <summary>
        /// Envía el correo HTML de verificación de cuenta mediante SendGrid.
        /// </summary>
        /// <param name="user">Usuario recién registrado.</param>
        private async Task SendVerificationEmailAsync(User user)
        {
            try
            {
                string apiKey = _config["SendGrid:ApiKey"] ?? throw new Exception("Falta API Key de SendGrid");
                string fromEmail = _config["SendGrid:FromEmail"]!;
                string fromName = _config["SendGrid:FromName"]!;
                string baseUrl = _config["SendGrid:VerificationBaseUrl"]!;

                string verificationLink = $"{baseUrl}{user.EmailVerificationToken}";
                string htmlContent = EmailVerificationTemplate.Build(user.Name, verificationLink);

                await EmailHelper.SendEmailAsync(apiKey, fromEmail, fromName, user.Email,
                    "Verifica tu cuenta AeroRide ✈️", htmlContent);

                Console.WriteLine($"✅ Correo de verificación enviado a {user.Email}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️ Error al enviar correo de verificación: {ex.Message}");
            }
        }

        // ======================================================
        // 2️⃣ VERIFICACIÓN DE CORREO
        // ======================================================

        /// <summary>
        /// Verifica la dirección de correo electrónico de un usuario
        /// a partir del token recibido por correo electrónico.
        /// </summary>
        /// <param name="token">Token único de verificación de correo.</param>
        /// <returns>Mensaje de confirmación del estado de la verificación.</returns>
        /// <exception cref="Exception">
        /// Se lanza si el token es inválido, no existe o ya fue utilizado.
        /// </exception>
        public async Task<string> VerifyEmailAsync(string token)
        {
            if (string.IsNullOrEmpty(token))
                throw new Exception("El token de verificación es requerido.");

            var user = await _db.Users.FirstOrDefaultAsync(u => u.EmailVerificationToken == token);

            if (user == null)
                throw new Exception("Token inválido o usuario no encontrado.");

            if (user.IsVerified)
                return "Tu correo ya había sido verificado previamente ✅.";

            user.IsVerified = true;
            user.EmailVerificationToken = null;

            await _db.SaveChangesAsync();

            return "¡Correo verificado exitosamente! 🎉";
        }

        // ======================================================
        // 3️⃣ LOGIN
        // ======================================================

        /// <summary>
        /// Inicia sesión validando las credenciales del usuario, genera un JWT y un refresh token.
        /// Si el usuario no está verificado, reenvía el correo de confirmación.
        /// </summary>
        /// <param name="dto">Datos de inicio de sesión (correo y contraseña).</param>
        /// <returns>
        /// Un objeto <see cref="AuthResponseDto"/> con el token JWT, refresh token e información básica del usuario.
        /// </returns>
        /// <exception cref="Exception">
        /// Se lanza si el usuario no existe, la contraseña es incorrecta o la cuenta no está verificada.
        /// </exception>
        public async Task<AuthResponseDto> LoginAsync(UserLoginDto dto)
        {
            var user = await _db.Users.Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Email == dto.Email);

            if (user == null)
                throw new Exception("Usuario no encontrado.");

            if (!user.IsActive)
                throw new Exception("Tu cuenta ha sido desactivada.");

            if (!PasswordHelper.VerifyPassword(dto.Password, user.Password))
                throw new Exception("Contraseña incorrecta.");

            if (!user.IsVerified)
            {
                await ResendVerificationEmailAsync(user);
                throw new Exception("Tu cuenta no ha sido verificada. Se ha reenviado un correo de confirmación.");
            }

            // Generar JWT
            string token = JwtHelper.GenerateToken(user,
                _config["Jwt:Key"]!, _config["Jwt:Issuer"]!, _config["Jwt:Audience"]!, 60);

            // Generar Refresh Token
            var refreshToken = new RefreshToken
            {
                Token = Guid.NewGuid().ToString(),
                Expiration = DateTime.UtcNow.AddDays(7),
                UserId = user.Id
            };

            _db.RefreshTokens.Add(refreshToken);
            await _db.SaveChangesAsync();

            return new AuthResponseDto
            {
                Token = token,
                RefreshToken = refreshToken.Token,
                UserId = user.Id,
                Email = user.Email,
                Role = user.Role?.Name ?? "User"
            };
        }

        /// <summary>
        /// Reenvía un nuevo correo de verificación a un usuario que aún no ha confirmado su cuenta.
        /// </summary>
        /// <param name="user">Usuario no verificado al que se reenviará el correo.</param>
        private async Task ResendVerificationEmailAsync(User user)
        {
            try
            {
                user.EmailVerificationToken = Guid.NewGuid().ToString();
                await _db.SaveChangesAsync();

                string apiKey = _config["SendGrid:ApiKey"] ?? throw new Exception("Falta API Key de SendGrid");
                string fromEmail = _config["SendGrid:FromEmail"]!;
                string fromName = _config["SendGrid:FromName"]!;
                string baseUrl = _config["SendGrid:VerificationBaseUrl"]!;

                string verificationLink = $"{baseUrl}{user.EmailVerificationToken}";
                string htmlContent = EmailVerificationTemplate.Build(user.Name, verificationLink);

                await EmailHelper.SendEmailAsync(apiKey, fromEmail, fromName, user.Email,
                    "Verifica tu cuenta AeroRide ✈️ (reenviado)", htmlContent);

                Console.WriteLine($"📨 Correo de verificación reenviado a {user.Email}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"⚠️ Error al reenviar correo de verificación: {ex.Message}");
            }
        }

        // ======================================================
        // 4️⃣ REFRESH TOKEN
        // ======================================================

        /// <summary>
        /// Genera un nuevo JWT y refresh token a partir de un refresh token válido.
        /// </summary>
        /// <param name="dto">Objeto con el refresh token actual.</param>
        /// <returns>
        /// Un objeto <see cref="AuthResponseDto"/> con los nuevos tokens generados.
        /// </returns>
        /// <exception cref="Exception">
        /// Se lanza si el refresh token es inválido, expirado o revocado.
        /// </exception>
        public async Task<AuthResponseDto> RefreshAsync(RefreshTokenRequestDto dto)
        {
            var refreshToken = await _db.RefreshTokens
                .Include(r => r.User).ThenInclude(u => u.Role)
                .FirstOrDefaultAsync(r => r.Token == dto.RefreshToken);

            if (refreshToken == null || refreshToken.IsRevoked || refreshToken.Expiration < DateTime.UtcNow)
                throw new Exception("Refresh token inválido o expirado.");

            var user = refreshToken.User;

            string newJwt = JwtHelper.GenerateToken(user,
                _config["Jwt:Key"]!, _config["Jwt:Issuer"]!, _config["Jwt:Audience"]!, 60);

            refreshToken.IsRevoked = true;

            var newRefresh = new RefreshToken
            {
                Token = Guid.NewGuid().ToString(),
                Expiration = DateTime.UtcNow.AddDays(7),
                UserId = user.Id
            };

            _db.RefreshTokens.Add(newRefresh);
            await _db.SaveChangesAsync();

            return new AuthResponseDto
            {
                Token = newJwt,
                RefreshToken = newRefresh.Token,
                UserId = user.Id,
                Email = user.Email,
                Role = user.Role?.Name ?? "User"
            };
        }

        // ======================================================
        // 5️⃣ LOGOUT
        // ======================================================

        /// <summary>
        /// Revoca el refresh token asociado al usuario actual, cerrando su sesión.
        /// </summary>
        /// <param name="refreshToken">Token que se desea invalidar.</param>
        public async Task LogoutAsync(string refreshToken)
        {
            var token = await _db.RefreshTokens.FirstOrDefaultAsync(r => r.Token == refreshToken);
            if (token == null) return;

            token.IsRevoked = true;
            await _db.SaveChangesAsync();
        }

        // ======================================================
        // 6️⃣ RECUPERACIÓN DE CONTRASEÑA
        // ======================================================

        /// <summary>
        /// Envía un correo electrónico con un enlace para restablecer la contraseña.
        /// </summary>
        /// <param name="email">Correo electrónico asociado a la cuenta.</param>
        /// <returns>Mensaje confirmando el envío del correo.</returns>
        /// <exception cref="Exception">
        /// Se lanza si no existe un usuario con ese correo.
        /// </exception>
        public async Task<string> SendPasswordResetEmailAsync(string email)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
                throw new Exception("No existe ninguna cuenta asociada a ese correo.");

            user.PasswordResetToken = Guid.NewGuid().ToString();
            user.PasswordResetTokenExpires = DateTime.UtcNow.AddMinutes(30);
            await _db.SaveChangesAsync();

            string apiKey = _config["SendGrid:ApiKey"] ?? throw new Exception("Falta API Key de SendGrid");
            string fromEmail = _config["SendGrid:FromEmail"]!;
            string fromName = _config["SendGrid:FromName"]!;
            string baseUrl = _config["SendGrid:PasswordResetBaseUrl"] ?? "http://localhost:5192/api/auth/reset-password?token=";

            string resetLink = $"{baseUrl}{user.PasswordResetToken}";
            string html = PasswordResetTemplate.Build(user.Name, resetLink);

            await EmailHelper.SendEmailAsync(apiKey, fromEmail, fromName, user.Email,
                "Restablecer tu contraseña AeroRide", html);

            return "Correo de recuperación enviado correctamente. Verifica tu bandeja de entrada.";
        }

        /// <summary>
        /// Restablece la contraseña del usuario utilizando un token de recuperación válido.
        /// </summary>
        /// <param name="token">Token de recuperación recibido por correo.</param>
        /// <param name="newPassword">Nueva contraseña elegida por el usuario.</param>
        /// <returns>Mensaje confirmando el restablecimiento exitoso.</returns>
        /// <exception cref="Exception">
        /// Se lanza si el token es inválido o ha expirado.
        /// </exception>
        public async Task<string> ResetPasswordAsync(string token, string newPassword)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.PasswordResetToken == token);

            if (user == null || user.PasswordResetTokenExpires < DateTime.UtcNow)
                throw new Exception("Token inválido o expirado.");

            user.Password = PasswordHelper.HashPassword(newPassword);
            user.PasswordResetToken = null;
            user.PasswordResetTokenExpires = null;

            await _db.SaveChangesAsync();

            return "Tu contraseña ha sido restablecida exitosamente.";
        }
    }
}
