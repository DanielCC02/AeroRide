using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Objeto de entrada para solicitar un nuevo JWT
    /// utilizando un Refresh Token válido.
    /// </summary>
    public class RefreshTokenRequestDto
    {
        /// <summary>
        /// Token de refresco entregado al usuario durante el inicio de sesión.
        /// </summary>
        [Required(ErrorMessage = "El refresh token es obligatorio.")]
        public string RefreshToken { get; set; } = null!;
    }
}