using AeroRide.API.Models.DTOs.Authorization;
using AeroRide.API.Models.DTOs.Users;

namespace AeroRide.API.Services.Interfaces
{
    /// <summary>
    /// Define el contrato de la capa de servicios para todas las operaciones
    /// relacionadas con la autenticación, registro y gestión de credenciales de los usuarios.
    /// 
    /// Las implementaciones deben incluir lógica para:
    /// - Registro de nuevos usuarios.
    /// - Autenticación (login) y generación de tokens JWT.
    /// - Renovación de tokens mediante refresh tokens.
    /// - Cierre de sesión (revocación de tokens).
    /// - Verificación de cuentas por correo electrónico.
    /// - Recuperación y restablecimiento de contraseñas.
    /// </summary>
    public interface IAuthService
    {
        /// <summary>
        /// Registra un nuevo usuario en la plataforma y envía un correo de verificación.
        /// </summary>
        /// <param name="dto">Datos del usuario a registrar (nombre, correo, contraseña, etc.).</param>
        /// <returns>
        /// Un objeto <see cref="UserResponseDto"/> con la información del usuario creado.
        /// </returns>
        /// <exception cref="InvalidOperationException">
        /// Se lanza si el correo ya está registrado o los datos son inválidos.
        /// </exception>
        Task<UserResponseDto> RegisterAsync(UserRegisterDto dto);

        /// <summary>
        /// Autentica a un usuario mediante su correo y contraseña.
        /// </summary>
        /// <param name="dto">Credenciales del usuario (correo electrónico y contraseña).</param>
        /// <returns>
        /// Un objeto <see cref="AuthResponseDto"/> que contiene el token JWT,
        /// el refresh token y la información básica del usuario autenticado.
        /// </returns>
        /// <exception cref="UnauthorizedAccessException">
        /// Se lanza si las credenciales son incorrectas o el usuario no está verificado.
        /// </exception>
        Task<AuthResponseDto> LoginAsync(UserLoginDto dto);

        /// <summary>
        /// Genera un nuevo token JWT y refresh token a partir de uno válido existente.
        /// </summary>
        /// <param name="dto">Objeto que contiene el refresh token actual emitido al usuario.</param>
        /// <returns>
        /// Un objeto <see cref="AuthResponseDto"/> con los nuevos tokens actualizados.
        /// </returns>
        /// <exception cref="SecurityTokenException">
        /// Se lanza si el refresh token es inválido, ha expirado o ya fue revocado.
        /// </exception>
        Task<AuthResponseDto> RefreshAsync(RefreshTokenRequestDto dto);

        /// <summary>
        /// Cierra la sesión del usuario actual revocando el refresh token activo.
        /// </summary>
        /// <param name="refreshToken">Refresh token que se desea invalidar.</param>
        /// <returns>Tarea asíncrona que indica la finalización del proceso de logout.</returns>
        Task LogoutAsync(string refreshToken);

        /// <summary>
        /// Verifica el correo electrónico del usuario utilizando el token enviado por email.
        /// </summary>
        /// <param name="token">Token de verificación único asociado al usuario.</param>
        /// <returns>
        /// Mensaje descriptivo indicando si la verificación fue exitosa o si ocurrió un error.
        /// </returns>
        /// <exception cref="InvalidOperationException">
        /// Se lanza si el token es inválido o ha expirado.
        /// </exception>
        Task<string> VerifyEmailAsync(string token);

        /// <summary>
        /// Envía un correo con un enlace para restablecer la contraseña del usuario.
        /// </summary>
        /// <param name="email">Dirección de correo electrónico del usuario que solicita el restablecimiento.</param>
        /// <returns>
        /// Mensaje confirmando el envío del correo, o una descripción del error si no fue posible.
        /// </returns>
        /// <exception cref="KeyNotFoundException">
        /// Se lanza si no existe ningún usuario asociado a ese correo.
        /// </exception>
        Task<string> SendPasswordResetEmailAsync(string email);

        /// <summary>
        /// Restablece la contraseña del usuario utilizando el token recibido por correo electrónico.
        /// </summary>
        /// <param name="token">Token de seguridad recibido en el enlace del correo.</param>
        /// <param name="newPassword">Nueva contraseña que reemplazará la anterior.</param>
        /// <returns>
        /// Mensaje confirmando que la contraseña fue actualizada correctamente.
        /// </returns>
        /// <exception cref="InvalidOperationException">
        /// Se lanza si el token es inválido o ha expirado.
        /// </exception>
        Task<string> ResetPasswordAsync(string token, string newPassword);
    }
}
