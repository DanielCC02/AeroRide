namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Data Transfer Object used by administrators to update
    /// an existing user's information.
    /// It allows updating the user's name, phone number, role, or active status.
    /// </summary>
    public class UserUpdateAdminDto
    {
        /// <summary>
        /// New first name of the user (optional).
        /// </summary>
        public string? Name { get; set; }

        /// <summary>
        /// New last name of the user (optional).
        /// </summary>
        public string? LastName { get; set; }

        /// <summary>
        /// New email address of the user (optional).
        /// </summary>
        public string? Email { get; set; }

        /// <summary>
        /// New phone number of the user (optional).
        /// </summary>
        public string? PhoneNumber { get; set; }

        /// <summary>
        /// Updated country of the user (optional).
        /// </summary>
        public string? Country { get; set; }

        /// <summary>
        /// Identifier of the new role assigned to the user (optional).
        /// </summary>
        public int? RoleId { get; set; }

        /// <summary>
        /// Identifier of the company associated with the user (optional).
        /// </summary>
        public int? CompanyId { get; set; }

        /// <summary>
        /// Indicates whether the user should be active or inactive.
        /// Allows direct administrative control over the account status.
        /// </summary>
        public bool? IsActive { get; set; }
    }
}