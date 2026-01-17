using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Response sent to the client after a successful login or token refresh.
    /// It includes a valid JWT access token and an associated Refresh Token.
    /// </summary>
    public class AuthResponseDto
    {
        /// <summary>
        /// Primary JWT access token.
        /// </summary>
        /// <remarks>
        /// Typically expires in 1 hour.
        /// </remarks>
        public string Token { get; set; } = null!;

        /// <summary>
        /// Refresh Token used to renew the session without re-authentication.
        /// </summary>
        /// <remarks>
        /// Typically expires in 7 days.
        /// </remarks>
        public string RefreshToken { get; set; } = null!;

        /// <summary>
        /// Unique identifier of the authenticated user.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Email address of the authenticated user.
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// Role assigned to the user within the system
        /// (e.g., Admin, Broker, Pilot, or User).
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Name of the company associated with the user, if applicable.
        /// </summary>
        public string? CompanyName { get; set; }
    }
}
