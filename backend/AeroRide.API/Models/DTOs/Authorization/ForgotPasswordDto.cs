using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// DTO utilizado para solicitar un correo de recuperación de contraseña.
    /// </summary>
    public class ForgotPasswordDto
    {
        /// <summary>
        /// Correo electrónico del usuario que solicita el restablecimiento.
        /// </summary>
        [Required(ErrorMessage = "El correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "Debe ingresar un correo electrónico válido.")]
        public string Email { get; set; } = null!;
    }
}