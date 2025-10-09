using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{

    /// <summary>
    /// Respuesta enviada al cliente después de un login o refresh exitoso.
    /// Incluye un JWT válido y un Refresh Token asociado.
    /// </summary>
    public class AuthResponseDto
    {
        /// <summary>
        /// Token JWT principal de acceso.
        /// </summary>
        /// <remarks>Expira normalmente en 1 hora.</remarks>
        public string Token { get; set; } = null!;

        /// <summary>
        /// Refresh Token asociado para renovar la sesión sin volver a autenticarse.
        /// </summary>
        /// <remarks>Expira normalmente en 7 días.</remarks>
        public string RefreshToken { get; set; } = null!;

        /// <summary>
        /// Identificador único del usuario autenticado.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Correo electrónico del usuario autenticado.
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// Rol asignado al usuario dentro del sistema (Admin, Broker, Pilot o User).
        /// </summary>
        public string Role { get; set; } = null!;
    }
}