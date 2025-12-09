using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// Objeto de transferencia de datos utilizado para el registro
    /// de nuevos usuarios en la plataforma.
    /// </summary>
    public class UserRegisterDto
    {
        /// <summary>
        /// Nombre del usuario que desea registrarse.
        /// </summary>
        [Required(ErrorMessage = "El nombre es obligatorio.")]
        [StringLength(50, ErrorMessage = "El nombre no debe exceder los 50 caracteres.")]
        public string Name { get; set; } = null!;

        /// <summary>
        /// Apellido del usuario.
        /// </summary>
        [Required(ErrorMessage = "El apellido es obligatorio.")]
        [StringLength(50, ErrorMessage = "El apellido no debe exceder los 50 caracteres.")]
        public string LastName { get; set; } = null!;

        /// <summary>
        /// País principal del usuario (ej: "Costa Rica", "Mexico").
        /// Se usará para segmentar notificaciones de empty legs.
        /// </summary>
        public string? Country { get; set; }

        /// <summary>
        /// Correo electrónico del usuario (debe ser único en el sistema).
        /// </summary>
        [Required(ErrorMessage = "El correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "Debe ingresar un correo electrónico válido.")]
        public string Email { get; set; } = null!;

        /// <summary>
        /// Contraseña del usuario. Se almacenará en formato hash.
        /// </summary>
        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres.")]
        public string Password { get; set; } = null!;

        /// <summary>
        /// Número de teléfono del usuario.
        /// </summary>
        [Required(ErrorMessage = "El número de teléfono es obligatorio.")]
        [Phone(ErrorMessage = "Debe ingresar un número de teléfono válido.")]
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Indica si el usuario acepta los Términos de Uso.
        /// </summary>
        public bool TermsOfUse { get; set; }

        /// <summary>
        /// Indica si el usuario acepta el Aviso de Privacidad.
        /// </summary>
        public bool PrivacyNotice { get; set; }
    }
}
