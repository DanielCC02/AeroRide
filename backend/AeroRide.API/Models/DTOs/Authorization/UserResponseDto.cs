using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Objeto de salida que representa la información de un usuario
    /// después de un registro exitoso o consulta de perfil.
    /// </summary>
    public class UserResponseDto
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
        /// Rol asignado al usuario dentro del sistema.
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Nombre de la empresa asociada (si aplica).
        /// </summary>
        public string? CompanyName { get; set; }
    }
}
