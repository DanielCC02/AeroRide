using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Output object that represents user information
    /// after a successful registration or profile retrieval.
    /// </summary>
    public class UserResponseDto
    {
        /// <summary>
        /// Unique identifier of the user.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// User's first name.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// User's last name.
        /// </summary>
        public string LastName { get; set; } = null!;

        /// <summary>
        /// User's email address.
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// Role assigned to the user within the system.
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Name of the associated company, if applicable.
        /// </summary>
        public string? CompanyName { get; set; }
    }
}
