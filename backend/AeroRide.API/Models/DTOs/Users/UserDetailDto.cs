namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Data Transfer Object (DTO) that represents detailed user information
    /// within the AeroRide system.
    ///
    /// This model is mainly used for administrative queries
    /// or to display full information about an authenticated user,
    /// excluding passwords and sensitive tokens.
    /// </summary>
    public class UserDetailDto
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
        /// Role assigned to the user (e.g., Admin, Pilot, Broker, User).
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Date when the user registered on the platform.
        /// </summary>
        public DateTime RegistrationDate { get; set; }

        /// <summary>
        /// Indicates whether the user accepted the Terms of Use during registration.
        /// </summary>
        public bool TermsOfUse { get; set; }

        /// <summary>
        /// Indicates whether the user accepted the Privacy Notice during registration.
        /// </summary>
        public bool PrivacyNotice { get; set; }

        /// <summary>
        /// Indicates whether the user is verified (true) or not (false).
        /// </summary>
        public bool IsVerified { get; set; }

        /// <summary>
        /// Indicates whether the user is active (true) or deactivated (false).
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Name of the associated company (optional).
        /// </summary>
        public string? CompanyName { get; set; }

        /// <summary>
        /// User's primary country.
        /// </summary>
        public string Country { get; set; } = null!;
    }
}
