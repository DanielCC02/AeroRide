namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Object that represents the authenticated user's profile.
    /// It is used to display the personal information of the
    /// currently logged-in user within the application.
    /// </summary>
    public class UserProfileDto
    {
        /// <summary>
        /// Identifier of the authenticated user.
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
        /// Email address associated with the account.
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// User's phone number.
        /// </summary>
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Current role assigned to the user (Admin, Broker, Pilot, or User).
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Identifier of the company the user belongs to (if applicable).
        /// </summary>
        public int? CompanyId { get; set; }

        /// <summary>
        /// Name of the associated company (e.g., AeroCaribe).
        /// </summary>
        public string? CompanyName { get; set; }

        /// <summary>
        /// Date when the user registered on the platform.
        /// </summary>
        public DateTime RegistrationDate { get; set; }

        /// <summary>
        /// User's primary country.
        /// </summary>
        public string Country { get; set; } = null!;
    }
}