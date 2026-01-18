using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Data Transfer Object used for registering new users
    /// on the platform.
    /// </summary>
    public class UserRegisterDto
    {
        /// <summary>
        /// First name of the user registering on the platform.
        /// </summary>
        [Required(ErrorMessage = "The first name is required.")]
        [StringLength(50, ErrorMessage = "The first name must not exceed 50 characters.")]
        public string Name { get; set; } = null!;

        /// <summary>
        /// Last name of the user.
        /// </summary>
        [Required(ErrorMessage = "The last name is required.")]
        [StringLength(50, ErrorMessage = "The last name must not exceed 50 characters.")]
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Primary country of the user (e.g., \"Costa Rica\", \"Mexico\").
        /// Used to segment empty leg notifications.
        /// </summary>
        public string? Country { get; set; }

        /// <summary>
        /// User's email address (must be unique in the system).
        /// </summary>
        [Required(ErrorMessage = "The email address is required.")]
        [EmailAddress(ErrorMessage = "A valid email address must be provided.")]
        public string Email { get; set; } = null!;

        /// <summary>
        /// User password. It will be stored in hashed format.
        /// </summary>
        [Required(ErrorMessage = "The password is required.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "The password must be at least 6 characters long.")]
        public string Password { get; set; } = null!;

        /// <summary>
        /// User phone number.
        /// </summary>
        [Required(ErrorMessage = "The phone number is required.")]
        [Phone(ErrorMessage = "A valid phone number must be provided.")]
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Indicates whether the user explicitly accepts the Terms of Use.
        /// This value must be true to complete the registration.
        /// </summary>
        public bool TermsOfUse { get; set; }

        /// <summary>
        /// Indicates whether the user explicitly accepts the Privacy Notice.
        /// This value must be true to complete the registration.
        /// </summary>
        public bool PrivacyNotice { get; set; }

    }
}
