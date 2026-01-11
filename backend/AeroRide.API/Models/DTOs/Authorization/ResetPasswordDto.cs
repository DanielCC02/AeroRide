using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Data Transfer Object used to reset a user's password
    /// using a valid recovery token.
    /// </summary>
    public class ResetPasswordDto
    {
        /// <summary>
        /// Unique recovery token received via email.
        /// </summary>
        [Required(ErrorMessage = "The recovery token is required.")]
        public string Token { get; set; } = null!;

        /// <summary>
        /// New password that will replace the previous one.
        /// </summary>
        [Required(ErrorMessage = "A new password must be provided.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "The password must be at least 6 characters long.")]
        public string NewPassword { get; set; } = null!;
    }
}
