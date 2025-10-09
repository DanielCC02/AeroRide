namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa un token JWT que ha sido invalidado manualmente.
    /// 
    /// Se utiliza como registro de seguridad para evitar el uso de tokens revocados,
    /// por ejemplo, en casos de cierre de sesión (<c>logout</c>), cambio de credenciales
    /// o suspensión del usuario.
    /// </summary>
    public class RevokedToken
    {
        /// <summary>
        /// Identificador único del registro de token revocado.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Token JWT que fue revocado e invalidado.
        /// </summary>
        public string Token { get; set; } = null!;

        /// <summary>
        /// Identificador del usuario al que pertenecía el token revocado.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Fecha y hora en que el token fue revocado.
        /// Se almacena en formato UTC para garantizar consistencia temporal.
        /// </summary>
        public DateTime RevokedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Referencia al usuario propietario del token revocado.
        /// </summary>
        public User User { get; set; } = null!;
    }
}
