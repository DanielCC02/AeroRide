using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Data Transfer Object used for manual user creation.
    ///
    /// This DTO is intended to be used by administrators to register new users
    /// in the AeroRide system with a specific role (Admin, Pilot, Broker, etc.).
    /// </summary>
    public class CreateUserDto
    {
        /// <summary>
        /// First name of the new user.
        /// </summary>
        [Required(ErrorMessage = "First name is required.")]
        [StringLength(50, ErrorMessage = "First name must not exceed 50 characters.")]
        public string Name { get; set; } = null!;

        /// <summary>
        /// Last name of the new user.
        /// </summary>
        [Required(ErrorMessage = "Last name is required.")]
        [StringLength(50, ErrorMessage = "Last name must not exceed 50 characters.")]
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Primary country of the user (e.g., \"Costa Rica\", \"Mexico\").
        /// This value may be used to segment empty-leg notifications.
        /// </summary>
        public string? Country { get; set; }

        /// <summary>
        /// Unique email address of the user.
        /// </summary>
        [Required(ErrorMessage = "Email address is required.")]
        [EmailAddress(ErrorMessage = "A valid email address must be provided.")]
        public string Email { get; set; } = null!;

        /// <summary>
        /// User's phone number.
        /// </summary>
        [Required(ErrorMessage = "Phone number is required.")]
        [Phone(ErrorMessage = "A valid phone number must be provided.")]
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Initial password for the user.
        /// It will be stored in the database using a secure hashing mechanism.
        /// </summary>
        [Required(ErrorMessage = "Password is required.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters long.")]
        public string Password { get; set; } = null!;

        /// <summary>
        /// Role assigned to the user.
        /// - AdminGeneral can assign any role.
        /// - CompanyAdmin can only assign \"Pilot\" or \"CompanyAdmin\".
        /// </summary>
        [Required(ErrorMessage = "A role must be specified for the user.")]
        public int RoleId { get; set; }

        /// <summary>
        /// Identifier of the company the user belongs to (optional for AdminGeneral).
        /// If created by a CompanyAdmin, this value must be forced to the creator's CompanyId.
        /// </summary>
        public int? CompanyId { get; set; }
    }
}
