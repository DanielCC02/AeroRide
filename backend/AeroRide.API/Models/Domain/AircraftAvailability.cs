namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Represents time periods of aircraft occupancy or availability.
    /// It is used to prevent scheduling conflicts between reservations,
    /// flights, maintenance, or other operational events.
    /// </summary>
    public class AircraftAvailability
    {
        public int Id { get; set; }

        /// <summary>
        /// Identifier of the associated aircraft.
        /// </summary>
        public int AircraftId { get; set; }

        /// <summary>
        /// Reference to the associated aircraft.
        /// </summary>
        public Aircraft Aircraft { get; set; } = null!;

        /// <summary>
        /// Date and time when the aircraft occupancy period starts.
        /// </summary>
        public DateTime StartTime { get; set; }

        /// <summary>
        /// Date and time when the aircraft occupancy period ends.
        /// </summary>
        public DateTime EndTime { get; set; }

        /// <summary>
        /// Type of occupancy (e.g., Reservation, EmptyLeg, Maintenance, etc.).
        /// </summary>
        public string Type { get; set; } = "Reserva";

        /// <summary>
        /// Identifier of the reservation occupying this time block, if applicable.
        /// </summary>
        public int? ReservationId { get; set; }

        /// <summary>
        /// Reference to the associated reservation, if applicable.
        /// </summary>
        public Reservation? Reservation { get; set; }

        /// <summary>
        /// Current status of the availability block (e.g., Confirmed, Cancelled, Completed).
        /// </summary>
        public string Status { get; set; } = "Confirmado";
    }
}
