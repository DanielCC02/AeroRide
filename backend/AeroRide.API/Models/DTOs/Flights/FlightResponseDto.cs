namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Data Transfer Object that represents detailed information
    /// about a flight.
    /// </summary>
    public class FlightResponseDto
    {
        /// <summary>
        /// Unique identifier of the flight.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Scheduled departure date and time.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Scheduled arrival date and time.
        /// </summary>
        public DateTime ArrivalTime { get; set; }

        /// <summary>
        /// Total flight duration expressed in minutes.
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
        public string Status { get; set; } = string.Empty;

        // =====================
        // 🛫 / 🛬 AIRPORTS
        // =====================

        /// <summary>
        /// Name of the departure airport.
        /// </summary>
        public string? DepartureAirportName { get; set; }

        /// <summary>
        /// IATA code of the departure airport.
        /// </summary>
        public string? DepartureAirportIATA { get; set; }

        /// <summary>
        /// ICAO code of the departure airport.
        /// </summary>
        public string? DepartureAirportOACI { get; set; }

        /// <summary>
        /// Name of the arrival airport.
        /// </summary>
        public string? ArrivalAirportName { get; set; }

        /// <summary>
        /// IATA code of the arrival airport.
        /// </summary>
        public string? ArrivalAirportIATA { get; set; }

        /// <summary>
        /// ICAO code of the arrival airport.
        /// </summary>
        public string? ArrivalAirportOACI { get; set; }

        // =====================
        // ✈️ AIRCRAFT
        // =====================

        /// <summary>
        /// Aircraft model assigned to the flight.
        /// </summary>
        public string? AircraftModel { get; set; }

        /// <summary>
        /// Aircraft registration or tail number.
        /// </summary>
        public string? AircraftPatent { get; set; }

        // =====================
        // 🏢 COMPANY
        // =====================

        /// <summary>
        /// Name of the company operating the flight.
        /// </summary>
        public string? CompanyName { get; set; }

        // =====================
        // 🧾 RESERVATION
        // =====================

        /// <summary>
        /// Reservation code associated with the flight, if applicable.
        /// </summary>
        public string? ReservationCode { get; set; }

        /// <summary>
        /// Indicates whether pilots have been assigned to the flight.
        /// </summary>
        public bool HasAssignedPilots { get; set; }

        /// <summary>
        /// Total number of pilots assigned to the flight.
        /// </summary>
        public int AssignedPilotCount { get; set; }
    }
}
