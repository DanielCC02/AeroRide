using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{

    /// <summary>
    /// Objeto de transferencia utilizado para iniciar sesión.
    /// Contiene las credenciales del usuario (correo y contraseña).
    /// </summary>
    public class UserLoginDto
    {
        /// <summary>
        /// Correo electrónico del usuario registrado.
        /// </summary>
        [Required(ErrorMessage = "El correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "Debe ingresar un correo electrónico válido.")]
        public string Email { get; set; } = null!;

        /// <summary>
        /// Contraseña del usuario en texto plano.
        /// Se validará contra el hash almacenado en la base de datos.
        /// </summary>
        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres.")]
        public string Password { get; set; } = null!;
    }
}