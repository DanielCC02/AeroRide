using AeroRide.API.Data;
using AeroRide.API.Helpers;
using AeroRide.API.Helpers.Templates;
using AeroRide.API.Models.Domain;
using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;
using AeroRide.API.Services.Interfaces;
using AutoMapper;
using Microsoft.EntityFrameworkCore;

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

        private const int JwtExpirationMinutes = 60;
        private const int RefreshTokenDays = 7;
        private const int PasswordResetMinutes = 30;

        public AuthService(AeroRideDbContext db, IMapper mapper, IConfiguration config)
        {
            _db = db;
            _mapper = mapper;
            _config = config;
        }

        // ======================================================
        // 1️⃣ REGISTRO DE USUARIOS
        // ======================================================
        public async Task<UserResponseDto> RegisterAsync(UserRegisterDto dto)
        {
            // Validar correo único
            if (await _db.Users.AnyAsync(u => u.Email == dto.Email))
                throw new Exception("El correo ya está registrado.");

            // Mapear DTO → entidad User
            var user = _mapper.Map<User>(dto);

            // Asegurar campos críticos
            user.Password = PasswordHelper.HashPassword(dto.Password);
            user.EmailVerificationToken = Guid.NewGuid().ToString();

            // 🔴 IMPORTANTE: asegurar que Country / TermsOfUse / PrivacyNotice
            // queden explícitamente seteados (por si el Profile de AutoMapper
            // todavía no contemplaba estas propiedades).
            user.Country = dto.Country;
            user.TermsOfUse = dto.TermsOfUse;
            user.PrivacyNotice = dto.PrivacyNotice;

            // Opcional: si no se setea en otro lado, puedes fijar RegistrationDate
            if (user.RegistrationDate == default)
            {
                user.RegistrationDate = DateTime.UtcNow;
            }

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            // Enviar correo de verificación
            await EmailHelper.SendVerificationEmailAsync(user, _config);

            return _mapper.Map<UserResponseDto>(user);
        }

        // ======================================================
        // 2️⃣ LOGIN
        // ======================================================
        public async Task<AuthResponseDto> LoginAsync(UserLoginDto dto)
        {
            var user = await _db.Users
               .IgnoreQueryFilters()
               .Include(u => u.Role)
               .Include(u => u.Company)
               .FirstOrDefaultAsync(u => u.Email == dto.Email);

            if (user == null || !PasswordHelper.VerifyPassword(dto.Password, user.Password))
                throw new UnauthorizedAccessException("Credenciales inválidas.");

            if (!user.IsVerified)
            {
                await ResendVerificationEmailAsync(user);
                throw new UnauthorizedAccessException("Tu cuenta aún no está verificada. Se ha reenviado un nuevo correo de confirmación.");
            }

            if (!user.IsActive)
                throw new UnauthorizedAccessException("Esta cuenta está desactivada.");

            string token = JwtHelper.GenerateToken(
                user,
                _config["Jwt:Key"]!,
                _config["Jwt:Issuer"]!,
                _config["Jwt:Audience"]!,
                JwtExpirationMinutes
            );

            var refreshToken = new RefreshToken
            {
                Token = Guid.NewGuid().ToString(),
                Expiration = DateTime.UtcNow.AddDays(RefreshTokenDays),
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
                Role = user.Role?.Name ?? "User",
                CompanyName = user.Company?.Name
            };
        }

        // ======================================================
        // 3️⃣ REFRESH TOKEN
        // ======================================================
        public async Task<AuthResponseDto> RefreshAsync(RefreshTokenRequestDto dto)
        {
            var refreshToken = await _db.RefreshTokens
                .Include(r => r.User).ThenInclude(u => u.Role)
                .Include(r => r.User).ThenInclude(u => u.Company)
                .FirstOrDefaultAsync(r => r.Token == dto.RefreshToken);

            if (refreshToken == null || refreshToken.IsRevoked || refreshToken.Expiration < DateTime.UtcNow)
                throw new Exception("Refresh token inválido o expirado.");

            var user = refreshToken.User;

            string newJwt = JwtHelper.GenerateToken(
                user,
                _config["Jwt:Key"]!,
                _config["Jwt:Issuer"]!,
                _config["Jwt:Audience"]!,
                JwtExpirationMinutes
            );

            refreshToken.IsRevoked = true;

            var newRefresh = new RefreshToken
            {
                Token = Guid.NewGuid().ToString(),
                Expiration = DateTime.UtcNow.AddDays(RefreshTokenDays),
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
                Role = user.Role?.Name ?? "User",
                CompanyName = user.Company?.Name
            };
        }

        // ======================================================
        // 4️⃣ EMAIL VERIFICATION
        // ======================================================
        public async Task<string> VerifyEmailAsync(string token)
        {
            if (string.IsNullOrEmpty(token))
                throw new Exception("The email verification token is required.");

            var user = await _db.Users
                .FirstOrDefaultAsync(u => u.EmailVerificationToken == token);

            if (user == null)
                throw new Exception("Invalid or expired verification token.");

            if (user.IsVerified)
                return "Your email address was already verified.";

            user.IsVerified = true;
            user.EmailVerificationToken = null;

            await _db.SaveChangesAsync();

            return "Your email address has been successfully verified.";
        }


        private async Task ResendVerificationEmailAsync(User user)
        {
            user.EmailVerificationToken = Guid.NewGuid().ToString();
            await _db.SaveChangesAsync();
            await EmailHelper.SendVerificationEmailAsync(user, _config, true);
        }

        // ======================================================
        // 5️⃣ LOGOUT
        // ======================================================
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
        public async Task<string> SendPasswordResetEmailAsync(string email)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null)
                throw new Exception("No account is associated with this email address.");

            user.PasswordResetToken = Guid.NewGuid().ToString();
            user.PasswordResetTokenExpires = DateTime.UtcNow.AddMinutes(PasswordResetMinutes);
            await _db.SaveChangesAsync();

            string apiKey = _config["SendGrid:ApiKey"]
                ?? throw new Exception("Missing SendGrid API key");

            string fromEmail = _config["SendGrid:FromEmail"]!;
            string fromName = _config["SendGrid:FromName"]!;
            string baseUrl = _config["SendGrid:PasswordResetBaseUrl"]
                ?? "http://localhost:5192/auth/reset-password?token=";

            string resetLink = $"{baseUrl}{user.PasswordResetToken}";
            string html = PasswordResetTemplate.Build(user.Name, resetLink);

            await EmailHelper.SendEmailAsync(
                apiKey,
                fromEmail,
                fromName,
                user.Email,
                "Reset your AeroRide password",
                html
            );

            return "A password reset email has been sent. Please check your inbox.";
        }


        public async Task<string> ResetPasswordAsync(string token, string newPassword)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.PasswordResetToken == token);

            if (user == null ||
                user.PasswordResetTokenExpires == null ||
                user.PasswordResetTokenExpires < DateTime.UtcNow)
            {
                throw new Exception("Invalid or expired password reset token.");
            }

            if (!user.IsActive)
                throw new Exception("This account is disabled.");


            user.Password = PasswordHelper.HashPassword(newPassword);
            user.PasswordResetToken = null;
            user.PasswordResetTokenExpires = null;

            await _db.SaveChangesAsync();

            return "Your password has been successfully reset.";
        }

        public async Task ValidatePasswordResetTokenAsync(string token)
        {
            if (string.IsNullOrEmpty(token))
                throw new Exception("Invalid password reset token.");

            var user = await _db.Users
                .FirstOrDefaultAsync(u => u.PasswordResetToken == token);

            if (user == null ||
                user.PasswordResetTokenExpires == null ||
                user.PasswordResetTokenExpires < DateTime.UtcNow)
            {
                throw new Exception("This password reset link has already been used or has expired.");
            }
        }

    }
}
