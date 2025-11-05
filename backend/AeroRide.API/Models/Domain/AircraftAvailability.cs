namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Representa los períodos de ocupación o disponibilidad de una aeronave.
    /// Se usa para evitar conflictos de horarios entre reservas o vuelos.
    /// </summary>
    public class AircraftAvailability
    {
        public int Id { get; set; }

        public int AircraftId { get; set; }
        public Aircraft Aircraft { get; set; } = null!;

        /// <summary>
        /// Fecha y hora en que inicia la ocupación de la aeronave.
        /// </summary>
        public DateTime StartTime { get; set; }

        /// <summary>
        /// Fecha y hora en que termina la ocupación de la aeronave.
        /// </summary>
        public DateTime EndTime { get; set; }

        /// <summary>
        /// Tipo de ocupación (Reserva, EmptyLeg, Mantenimiento, etc.).
        /// </summary>
        public string Type { get; set; } = "Reserva";

        /// <summary>
        /// Identificador de la reserva que ocupa este bloque (si aplica).
        /// </summary>
        public int? ReservationId { get; set; }
        public Reservation? Reservation { get; set; }

        /// <summary>
        /// Estado del bloque (Confirmado, Cancelado, Finalizado).
        /// </summary>
        public string Status { get; set; } = "Confirmado";
    }
}
