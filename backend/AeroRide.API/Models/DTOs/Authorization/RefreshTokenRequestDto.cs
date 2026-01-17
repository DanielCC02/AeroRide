using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Input object used to request a new JWT
    /// using a valid Refresh Token.
    /// </summary>
    public class RefreshTokenRequestDto
    {
        /// <summary>
        /// Refresh Token provided to the user during login.
        /// </summary>
        [Required(ErrorMessage = "The refresh token is required.")]
        public string RefreshToken { get; set; } = null!;
    }
}
