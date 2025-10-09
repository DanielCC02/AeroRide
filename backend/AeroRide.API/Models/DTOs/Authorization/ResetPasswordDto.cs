using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Authorization
{
    /// <summary>
    /// DTO utilizado para restablecer la contraseña de un usuario
    /// mediante un token de recuperación válido.
    /// </summary>
    public class ResetPasswordDto
    {
        /// <summary>
        /// Token único recibido por correo electrónico.
        /// </summary>
        [Required(ErrorMessage = "El token de recuperación es obligatorio.")]
        public string Token { get; set; } = null!;

        /// <summary>
        /// Nueva contraseña que reemplazará a la anterior.
        /// </summary>
        [Required(ErrorMessage = "Debe ingresar una nueva contraseña.")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres.")]
        public string NewPassword { get; set; } = null!;
    }
}