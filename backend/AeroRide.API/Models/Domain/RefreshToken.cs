namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa un Refresh Token emitido a un usuario.
    /// 
    /// Su propósito es permitir la renovación segura del token de acceso (JWT)
    /// sin que el usuario deba volver a autenticarse con sus credenciales.
    /// 
    /// Cada usuario puede tener varios Refresh Tokens activos, asociados a distintos dispositivos o sesiones.
    /// </summary>
    public class RefreshToken
    {
        /// <summary>
        /// Identificador único del Refresh Token dentro del sistema.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Cadena aleatoria única que representa el token de refresco entregado al cliente.
        /// Se genera mediante <see cref="Guid.NewGuid()"/> u otro método criptográficamente seguro.
        /// </summary>
        public string Token { get; set; } = null!;

        /// <summary>
        /// Fecha y hora de expiración del Refresh Token.
        /// Una vez vencido, ya no puede utilizarse para generar nuevos JWT.
        /// </summary>
        public DateTime Expiration { get; set; }

        /// <summary>
        /// Indica si el token ha sido revocado manualmente (por ejemplo, durante un cierre de sesión o logout).
        /// </summary>
        public bool IsRevoked { get; set; } = false;

        /// <summary>
        /// Identificador del usuario propietario del Refresh Token.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Referencia al usuario asociado a este Refresh Token.
        /// Representa una relación muchos a uno (<c>N:1</c>) con la entidad <see cref="User"/>.
        /// </summary>
        public User User { get; set; } = null!;
    }
}
