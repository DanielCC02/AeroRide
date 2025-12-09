namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Objeto de transferencia de datos (DTO) que representa la información
    /// detallada de un usuario dentro del sistema AeroRide.
    /// 
    /// Este modelo se utiliza principalmente para consultas administrativas
    /// o para mostrar la información completa de un usuario autenticado,
    /// sin incluir la contraseña ni tokens sensibles.
    /// </summary>
    public class UserDetailDto
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
        /// Rol asignado al usuario (por ejemplo: Admin, Pilot, Broker, User).
        /// </summary>
        public string Role { get; set; } = null!;

        /// <summary>
        /// Fecha en la que el usuario se registró en la plataforma.
        /// </summary>
        public DateTime RegistrationDate { get; set; }

        /// <summary>
        /// Indica si el usuario aceptó los Términos de Uso al registrarse.
        /// </summary>
        public bool TermsOfUse { get; set; }

        /// <summary>
        /// Indica si el usuario aceptó el Aviso de Privacidad al registrarse.
        /// </summary>
        public bool PrivacyNotice { get; set; }

        /// <summary>
        /// Indica si el usuario se encuentra verificado (true) o no (false).
        /// </summary>
        public bool IsVerified { get; set; }

        /// <summary>
        /// Indica si el usuario se encuentra activo (true) o desactivado (false).
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Nombre de la empresa asociada (opcional).
        /// </summary>
        public string? CompanyName { get; set; }

        public string Country { get; set; } = null!;


    }
}
