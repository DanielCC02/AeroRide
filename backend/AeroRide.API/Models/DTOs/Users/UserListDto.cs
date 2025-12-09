namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Objeto de transferencia que representa la información básica de un usuario.
    /// Utilizado principalmente en listados administrativos o reportes.
    /// </summary>
    public class UserListDto
    {
        /// <summary>
        /// Identificador único del usuario.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Nombre del usuario.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Apellido del usuario.
        /// </summary>
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Correo electrónico del usuario.
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// Número de teléfono o contacto principal.
        /// </summary>
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Rol asignado (Admin, Broker, Pilot o User).
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Indica si el usuario se encuentra activo o desactivado.
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Indica a que empresa pertence el usuario.
        /// </summary>
        public string? CompanyName { get; set; }

        public string Country { get; set; } = null!;

    }
}
