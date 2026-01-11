using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Data Transfer Object used to authenticate a user.
    /// It contains the user's credentials (email and password).
    /// </summary>
    public class UserLoginDto
    {
        /// <summary>
        /// Email address of the registered user.
        /// </summary>
        [Required(ErrorMessage = "The email address is required.")]
        [EmailAddress(ErrorMessage = "A valid email address must be provided.")]
        public string Email { get; set; } = null!;

        /// <summary>
        /// User password in plain text.
        /// It will be validated against the hashed password stored in the database.
        /// </summary>
        [Required(ErrorMessage = "The password is required.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "The password must be at least 6 characters long.")]
        public string Password { get; set; } = null!;
    }
}
