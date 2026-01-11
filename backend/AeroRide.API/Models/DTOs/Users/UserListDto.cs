namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Data Transfer Object that represents basic user information.
    /// It is mainly used in administrative listings or reports.
    /// </summary>
    public class UserListDto
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
        /// Primary phone number or contact information.
        /// </summary>
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Assigned role (Admin, Broker, Pilot, or User).
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Indicates whether the user is active or deactivated.
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Name of the company the user belongs to (if applicable).
        /// </summary>
        public string? CompanyName { get; set; }

        /// <summary>
        /// User's primary country.
        /// </summary>
        public string Country { get; set; } = null!;
    }
}
