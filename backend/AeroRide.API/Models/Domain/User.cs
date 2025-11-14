namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa a un usuario registrado en el sistema AeroRide.
    /// 
    /// Un usuario puede ser cliente, piloto, administrador o broker según su rol.
    /// Los usuarios pueden realizar reservas, registrar bitácoras de vuelo (si son pilotos)
    /// y acceder a los servicios de la plataforma según sus permisos.
    /// </summary>
    public class User
    {
        /// <summary>
        /// Identificador único del usuario.
        /// </summary>
        public int Id { get; set; }

        // ======================================================
        // 📋 DATOS PERSONALES
        // ======================================================

        /// <summary>
        /// Nombre del usuario.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Apellido del usuario.
        /// </summary>
        public string LastName { get; set; } = null!;

        // ======================================================
        // 📧 INFORMACIÓN DE CONTACTO Y SEGURIDAD
        // ======================================================

        /// <summary>
        /// Correo electrónico del usuario (debe ser único en el sistema).
        /// </summary>
        public string Email { get; set; } = null!;

        /// <summary>
        /// Contraseña del usuario, almacenada en formato hash seguro.
        /// Nunca se guarda en texto plano.
        /// </summary>
        public string Password { get; set; } = null!;

        /// <summary>
        /// Número de teléfono asociado al usuario.
        /// </summary>
        public string PhoneNumber { get; set; } = null!;

        // ======================================================
        // 🕒 INFORMACIÓN DE REGISTRO
        // ======================================================

        /// <summary>
        /// Fecha y hora en que el usuario se registró en la plataforma.
        /// </summary>
        public DateTime RegistrationDate { get; set; }

        // ======================================================
        // ⚖️ CONSENTIMIENTOS LEGALES
        // ======================================================

        /// <summary>
        /// Indica si el usuario aceptó los Términos de Uso de la plataforma.
        /// </summary>
        public bool TermsOfUse { get; set; }

        /// <summary>
        /// Indica si el usuario aceptó el Aviso de Privacidad.
        /// </summary>
        public bool PrivacyNotice { get; set; }

        // ======================================================
        // 🔐 VERIFICACIÓN Y SEGURIDAD DE CUENTA
        // ======================================================

        /// <summary>
        /// Identificador del rol asignado al usuario.
        /// </summary>
        public int? RoleId { get; set; }

        /// <summary>
        /// Token temporal generado al registrarse, utilizado para la verificación de correo electrónico.
        /// </summary>
        public string? EmailVerificationToken { get; set; }

        /// <summary>
        /// Indica si el correo electrónico del usuario ha sido verificado.
        /// </summary>
        public bool IsVerified { get; set; } = false;

        /// <summary>
        /// Token temporal generado para el proceso de restablecimiento de contraseña.
        /// </summary>
        public string? PasswordResetToken { get; set; }

        /// <summary>
        /// Fecha de expiración del token de restablecimiento de contraseña.
        /// </summary>
        public DateTime? PasswordResetTokenExpires { get; set; }

        /// <summary>
        /// Indica si la cuenta del usuario está activa.
        /// Los usuarios inactivos no pueden autenticarse ni aparecer en consultas públicas.
        /// </summary>
        public bool IsActive { get; set; } = true;

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================

        /// <summary>
        /// Rol asignado al usuario (por ejemplo: Admin, Broker, Pilot o User).
        /// </summary>
        public Role? Role { get; set; }

        /// <summary>
        /// (Opcional) Identificador de la empresa a la que pertenece el usuario.
        /// Aplica solo para pilotos, administradores o brokers.
        /// </summary>
        public int? CompanyId { get; set; }

        /// <summary>
        /// (Opcional) Empresa o aerolínea asociada al usuario.
        /// </summary>
        public Company? Company { get; set; }

        /// <summary>
        /// Colección de reservas realizadas por el usuario.
        /// </summary>
        public ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

        /// <summary>
        /// Colección de bitácoras de vuelo registradas por el usuario (solo si es piloto).
        /// </summary>
        public ICollection<FlightLog> FlightLogs { get; set; } = new List<FlightLog>();

        /// <summary>
        /// Colección de Refresh Tokens activos asociados al usuario.
        /// Permite mantener sesiones seguras y múltiples dispositivos autenticados.
        /// </summary>
        public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

        /// <summary>
        /// Vuelos asignados al piloto.
        /// </summary>
        public ICollection<FlightAssignment> FlightAssignments { get; set; } = new List<FlightAssignment>();

    }
}
