using AeroRide.API.Models.Domain;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents a role within the AeroRide system.
    ///
    /// Roles define the access levels and permissions assigned to users.
    /// Examples include: <c>Admin</c>, <c>Broker</c>, <c>Pilot</c>, and <c>User</c>.
    /// </summary>
    public class Role
    {
        /// <summary>
        /// Unique identifier of the role.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Name of the assigned role (e.g., <c>Admin</c>, <c>Pilot</c>, <c>User</c>).
        /// This value must be unique within the database.
        /// </summary>
        public string Name { get; set; } = default!;

        /// <summary>
        /// Collection of users assigned to this role.
        /// Represents a one-to-many (<c>1:N</c>) relationship with the <see cref="User"/> entity.
        /// </summary>
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
