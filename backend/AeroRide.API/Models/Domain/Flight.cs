namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa un vuelo registrado en el sistema AeroRide.
    /// 
    /// Puede corresponder a un vuelo reservado por un cliente o a un
    /// "Empty Leg" (pierna vacía) disponible para oferta.
    /// Incluye información de horarios, aeropuertos, aeronave, empresa operadora
    /// y los cargos asociados.
    /// </summary>
    public class Flight
    {
        /// <summary>
        /// Identificador único del vuelo.
        /// </summary>
        public int Id { get; set; }

        // ======================================================
        // 🕒 DATOS OPERATIVOS
        // ======================================================

        /// <summary>
        /// Fecha y hora de salida del vuelo (en UTC o zona definida).
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Fecha y hora de llegada del vuelo.
        /// </summary>
        public DateTime ArrivalTime { get; set; }

        /// <summary>
        /// Duración total del vuelo en minutos (calculada automáticamente al crear el vuelo).
        /// </summary>
        public double DurationMinutes { get; set; }

        /// <summary>
        /// Indica si el vuelo es un "Empty Leg" (vuelo vacío disponible para promoción o reserva).
        /// </summary>
        public bool IsEmptyLeg { get; set; }

        /// <summary>
        /// Indica si el vuelo es internacional (país de origen distinto al país de destino).
        /// </summary>
        public bool IsInternational { get; set; }

        /// <summary>
        /// Estado operativo actual del vuelo.
        /// Ejemplos: <c>Programado</c>, <c>En curso</c>, <c>Completado</c>, <c>Cancelado</c>.
        /// </summary>
        public string Status { get; set; } = "Programado";

        /// <summary>
        /// Fecha y hora en que se creó el registro del vuelo.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================

        /// <summary>
        /// Identificador de la reserva asociada (opcional).
        /// Si el valor es <c>null</c>, el vuelo está disponible como "Empty Leg".
        /// </summary>
        public int? ReservationId { get; set; }

        /// <summary>
        /// Reserva a la que pertenece este vuelo.
        /// Puede ser <c>null</c> si el vuelo aún no ha sido reservado.
        /// </summary>
        public Reservation? Reservation { get; set; }

        /// <summary>
        /// Identificador de la aeronave asignada al vuelo.
        /// </summary>
        public int AircraftId { get; set; }

        /// <summary>
        /// Aeronave asignada al vuelo.
        /// Representa una relación de muchos a uno (<c>N:1</c>) con <see cref="Aircraft"/>.
        /// </summary>
        public Aircraft Aircraft { get; set; } = null!;

        /// <summary>
        /// Identificador del aeropuerto de origen.
        /// </summary>
        public int DepartureAirportId { get; set; }

        /// <summary>
        /// Aeropuerto de salida asociado al vuelo.
        /// </summary>
        public Airport DepartureAirport { get; set; } = null!;

        /// <summary>
        /// Identificador del aeropuerto de destino.
        /// </summary>
        public int ArrivalAirportId { get; set; }

        /// <summary>
        /// Aeropuerto de llegada asociado al vuelo.
        /// </summary>
        public Airport ArrivalAirport { get; set; } = null!;

        /// <summary>
        /// Identificador de la empresa operadora del vuelo.
        /// </summary>
        public int CompanyId { get; set; }

        /// <summary>
        /// Empresa o aerolínea responsable de la operación del vuelo.
        /// </summary>
        public Company Company { get; set; } = null!;

        /// <summary>
        /// Cargos, tasas e impuestos asociados a este vuelo.
        /// </summary>
        public FlightCharge? Charge { get; set; }

        /// <summary>
        /// Colección de asignaciones de pilotos o personal a este vuelo.
        /// Representa una relación uno a muchos (<c>1:N</c>) entre <see cref="Flight"/> y <see cref="FlightAssignment"/>.
        /// </summary>
        public ICollection<FlightAssignment> Assignments { get; set; } = new List<FlightAssignment>();
    }
}
