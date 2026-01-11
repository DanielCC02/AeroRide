namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents a registered user within the AeroRide system.
    ///
    /// A user may act as a customer, pilot, administrator, or broker depending on their role.
    /// Users can create reservations, register flight logs (if they are pilots),
    /// and access platform services according to their assigned permissions.
    /// </summary>
    public class User
    {
        /// <summary>
        /// Unique identifier of the user.
        /// </summary>
        public int Id { get; set; }

        // ======================================================
        // 📋 PERSONAL INFORMATION
        // ======================================================

        /// <summary>
        /// User's first name.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// User's last name.
        /// </summary>
        public string LastName { get; set; } = null!;

        // ======================================================
        // 📧 CONTACT AND SECURITY INFORMATION
        // ======================================================

        /// <summary>
        /// User's email address (must be unique within the system).
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// User's password, stored as a secure hash.
        /// It is never stored in plain text.
        /// </summary>
        public string Password { get; set; } = null!;

        /// <summary>
        /// Phone number associated with the user.
        /// </summary>
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// User's primary country of residence (e.g., "Costa Rica", "Mexico").
        /// </summary>
        public string? Country { get; set; }

        // ======================================================
        // 🕒 REGISTRATION INFORMATION
        // ======================================================

        /// <summary>
        /// Date and time when the user registered on the platform.
        /// </summary>
        public DateTime RegistrationDate { get; set; }

        // ======================================================
        // ⚖️ LEGAL CONSENTS
        // ======================================================

        /// <summary>
        /// Indicates whether the user has accepted the platform's Terms of Use.
        /// </summary>
        public bool TermsOfUse { get; set; }

        /// <summary>
        /// Indicates whether the user has accepted the Privacy Notice.
        /// </summary>
        public bool PrivacyNotice { get; set; }

        // ======================================================
        // 🔐 ACCOUNT VERIFICATION AND SECURITY
        // ======================================================

        /// <summary>
        /// Identifier of the role assigned to the user.
        /// </summary>
        public int? RoleId { get; set; }

        /// <summary>
        /// Temporary token generated during registration and used for email verification.
        /// </summary>
        public string? EmailVerificationToken { get; set; }

        /// <summary>
        /// Indicates whether the user's email address has been verified.
        /// </summary>
        public bool IsVerified { get; set; } = false;

        /// <summary>
        /// Temporary token generated for the password reset process.
        /// </summary>
        public string? PasswordResetToken { get; set; }

        /// <summary>
        /// Expiration date and time of the password reset token.
        /// </summary>
        public DateTime? PasswordResetTokenExpires { get; set; }

        /// <summary>
        /// Indicates whether the user account is active.
        /// Inactive users cannot authenticate or appear in public queries.
        /// </summary>
        public bool IsActive { get; set; } = true;

        // ======================================================
        // 🔗 NAVIGATION RELATIONSHIPS
        // ======================================================

        /// <summary>
        /// Role assigned to the user (e.g., Admin, Broker, Pilot, or User).
        /// </summary>
        public Role? Role { get; set; }

        /// <summary>
        /// (Optional) Identifier of the company to which the user belongs.
        /// Applies to pilots, administrators, and brokers.
        /// </summary>
        public int? CompanyId { get; set; }

        /// <summary>
        /// (Optional) Company or airline associated with the user.
        /// </summary>
        public Company? Company { get; set; }

        /// <summary>
        /// Collection of reservations created by the user.
        /// </summary>
        public ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

        /// <summary>
        /// Collection of flight logs recorded by the user (pilot only).
        /// </summary>
        public ICollection<FlightLog> FlightLogs { get; set; } = new List<FlightLog>();

        /// <summary>
        /// Collection of active refresh tokens associated with the user.
        /// Allows secure sessions across multiple authenticated devices.
        /// </summary>
        public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

        /// <summary>
        /// Collection of flight assignments assigned to the pilot.
        /// </summary>
        public ICollection<FlightAssignment> FlightAssignments { get; set; } = new List<FlightAssignment>();
    }
}
