using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents a flight registered in the AeroRide system.
    /// A flight may correspond to a reserved flight or an available Empty Leg.
    /// It includes scheduling information, airports, aircraft, operating company,
    /// and associated charges.
    /// </summary>
    public class Flight
    {
        /// <summary>
        /// Unique identifier of the flight.
        /// </summary>
        public int Id { get; set; }

        // =========================
        // 🕒 OPERATIONAL DATA
        // =========================

        /// <summary>
        /// Scheduled departure date and time.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Scheduled arrival date and time.
        /// </summary>
        public DateTime ArrivalTime { get; set; }

        /// <summary>
        /// Total flight duration in minutes (calculated automatically).
        /// </summary>
        public double DurationMinutes { get; set; }

        /// <summary>
        /// Indicates whether the flight is an Empty Leg.
        /// </summary>
        public bool IsEmptyLeg { get; set; }

        /// <summary>
        /// Indicates whether the flight is international.
        /// </summary>
        public bool IsInternational { get; set; }

        /// <summary>
        /// Current operational status of the flight.
        /// </summary>
        public FlightStatus Status { get; set; } = FlightStatus.PreFlight;

        /// <summary>
        /// UTC date and time when the flight was created.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// UTC date and time when the flight was last updated, if applicable.
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        // =========================
        // 🔗 RELATIONSHIPS
        // =========================

        /// <summary>
        /// Identifier of the associated reservation, if applicable.
        /// </summary>
        public int? ReservationId { get; set; }

        /// <summary>
        /// Reference to the associated reservation, if applicable.
        /// </summary>
        public Reservation? Reservation { get; set; }

        /// <summary>
        /// Identifier of the aircraft assigned to the flight.
        /// </summary>
        public int AircraftId { get; set; }

        /// <summary>
        /// Reference to the aircraft assigned to the flight.
        /// </summary>
        public Aircraft Aircraft { get; set; } = null!;

        /// <summary>
        /// Identifier of the departure airport.
        /// </summary>
        public int DepartureAirportId { get; set; }

        /// <summary>
        /// Reference to the departure airport.
        /// </summary>
        public Airport DepartureAirport { get; set; } = null!;

        /// <summary>
        /// Identifier of the arrival airport.
        /// </summary>
        public int ArrivalAirportId { get; set; }

        /// <summary>
        /// Reference to the arrival airport.
        /// </summary>
        public Airport ArrivalAirport { get; set; } = null!;

        /// <summary>
        /// Identifier of the operating company.
        /// </summary>
        public int CompanyId { get; set; }

        /// <summary>
        /// Reference to the operating company.
        /// </summary>
        public Company Company { get; set; } = null!;

        /// <summary>
        /// Charges associated with the flight, if applicable.
        /// </summary>
        public FlightCharge? Charge { get; set; }

        /// <summary>
        /// Collection of crew assignments associated with the flight.
        /// </summary>
        public ICollection<FlightAssignment> Assignments { get; set; } = new List<FlightAssignment>();

        /// <summary>
        /// Collection of operational logs associated with the flight.
        /// </summary>
        public ICollection<FlightLog> Logs { get; set; } = new List<FlightLog>();
    }
}
