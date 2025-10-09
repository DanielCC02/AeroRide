using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using AeroRide.API.Models.Domain;
using System.Security.Cryptography;

namespace AeroRide.API.Helpers
{
    /// <summary>
    /// Utilidad para generar tokens JWT que se usan en la autenticación.
    /// 
    /// Los tokens incluyen "claims" como:
    /// - UserId
    /// - Email
    /// - Rol
    /// 
    /// Estos claims permiten validar la identidad del usuario en llamadas posteriores.
    /// </summary>
    public static class JwtHelper
    {
        /// <summary>
        /// Genera un JWT válido usando datos del usuario autenticado.
        /// </summary>
        /// <param name="user">Entidad User (incluye rol, email, etc.).</param>
        /// <param name="secretKey">Clave secreta definida en appsettings.json.</param>
        /// <param name="issuer">Quién emite el token (tu API).</param>
        /// <param name="audience">Quién consume el token (tus clientes).</param>
        /// <param name="expireMinutes">Tiempo de expiración en minutos.</param>
        /// <returns>Un string con el token JWT firmado.</returns>
        public static string GenerateToken(User user, string secretKey, string issuer, string audience, int expireMinutes = 60)
        {
            // Claims = información que va dentro del token
            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()), // identificador único
                new Claim(JwtRegisteredClaimNames.Email, user.Email),       // email del usuario
                new Claim(ClaimTypes.Role, user.Role?.Name ?? "User")       // rol (por defecto "User")
            };

            // Crear clave y credenciales de firma
            var keyBytes = SHA256.HashData(Encoding.UTF8.GetBytes(secretKey));
            var key = new SymmetricSecurityKey(keyBytes);
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            // Construir token
            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(expireMinutes),
                signingCredentials: creds
            );

            // Serializar token en string
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
