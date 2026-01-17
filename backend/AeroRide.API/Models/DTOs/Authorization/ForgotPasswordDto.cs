using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Data Transfer Object used to request a password recovery email.
    /// </summary>
    public class ForgotPasswordDto
    {
        /// <summary>
        /// Email address of the user requesting the password reset.
        /// </summary>
        [Required(ErrorMessage = "The email address is required.")]
        [EmailAddress(ErrorMessage = "A valid email address must be provided.")]
        public string Email { get; set; } = null!;
    }
}
