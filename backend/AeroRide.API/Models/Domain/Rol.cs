using AeroRide.API.Models.Domain;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa un rol dentro del sistema AeroRide.
    /// 
    /// Los roles determinan los niveles de acceso y permisos de los usuarios.
    /// Ejemplos: <c>Admin</c>, <c>Broker</c>, <c>Pilot</c>, <c>User</c>.
    /// </summary>
    public class Role
    {
        /// <summary>
        /// Identificador único del rol.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Nombre del rol asignado (por ejemplo: <c>Admin</c>, <c>Pilot</c>, <c>User</c>).
        /// Debe ser único en la base de datos.
        /// </summary>
        public string Name { get; set; } = default!;

        /// <summary>
        /// Colección de usuarios que tienen asignado este rol.
        /// Representa una relación uno a muchos (<c>1:N</c>) con la entidad <see cref="User"/>.
        /// </summary>
        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
