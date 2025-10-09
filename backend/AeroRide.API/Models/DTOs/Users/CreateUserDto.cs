using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Users
{
    /// <summary>
    /// Objeto de transferencia de datos utilizado para la creación manual de usuarios.
    /// 
    /// Este DTO es empleado por los administradores para registrar nuevos usuarios
    /// dentro del sistema AeroRide con un rol específico (Admin, Pilot, Broker, etc.).
    /// </summary>
    public class CreateUserDto
    {
        /// <summary>
        /// Nombre del nuevo usuario.
        /// </summary>
        [Required(ErrorMessage = "El nombre es obligatorio.")]
        [StringLength(50, ErrorMessage = "El nombre no debe exceder los 50 caracteres.")]
        public string Name { get; set; } = null!;

        /// <summary>
        /// Apellido del nuevo usuario.
        /// </summary>
        [Required(ErrorMessage = "El apellido es obligatorio.")]
        [StringLength(50, ErrorMessage = "El apellido no debe exceder los 50 caracteres.")]
        public string LastName { get; set; } = null!;

        /// <summary>
        /// Correo electrónico único del usuario.
        /// </summary>
        [Required(ErrorMessage = "El correo electrónico es obligatorio.")]
        [EmailAddress(ErrorMessage = "Debe ingresar un correo electrónico válido.")]
        public string Email { get; set; } = null!;

        /// <summary>
        /// Número de teléfono del usuario.
        /// </summary>
        [Required(ErrorMessage = "El número de teléfono es obligatorio.")]
        [Phone(ErrorMessage = "Debe ingresar un número de teléfono válido.")]
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Contraseña inicial del usuario.
        /// Será almacenada en la base de datos en formato hash seguro.
        /// </summary>
        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres.")]
        public string Password { get; set; } = null!;

        /// <summary>
        /// Identificador del rol asignado al usuario (Admin, Pilot, Broker, User, etc.).
        /// </summary>
        [Required(ErrorMessage = "Debe especificar un rol para el usuario.")]
        public int RoleId { get; set; }

        /// <summary>
        /// Indica si el usuario ha aceptado los Términos de Uso.
        /// Por defecto se establece en <c>true</c> en la creación manual.
        /// </summary>
        public bool TermsOfUse { get; set; } = true;

        /// <summary>
        /// Indica si el usuario ha aceptado el Aviso de Privacidad.
        /// Por defecto se establece en <c>true</c> en la creación manual.
        /// </summary>
        public bool PrivacyNotice { get; set; } = true;
    }
}
