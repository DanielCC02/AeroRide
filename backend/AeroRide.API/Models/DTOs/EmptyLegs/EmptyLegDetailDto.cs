namespace AeroRide.API.Models.DTOs.EmptyLegs
{
    /// <summary>
    /// Data Transfer Object that provides detailed information
    /// about an available Empty Leg flight.
    /// </summary>
    public class EmptyLegDetailDto
    {
        /// <summary>
        /// Unique identifier of the Empty Leg flight.
        /// </summary>
        public int Id { get; set; }

        // =========================
        // ✈️ AIRCRAFT INFORMATION
        // =========================

        /// <summary>
        /// Aircraft model.
        /// </summary>
        public string AircraftModel { get; set; } = null!;

        /// <summary>
        /// Aircraft registration or tail number.
        /// </summary>
        public string AircraftPatent { get; set; } = null!;

        /// <summary>
        /// Image URL representing the aircraft.
        /// </summary>
        public string AircraftImage { get; set; } = null!;

        /// <summary>
        /// Total number of seats available on the aircraft.
        /// </summary>
        public int Seats { get; set; }

        /// <summary>
        /// Maximum allowable weight for the aircraft.
        /// </summary>
        public int MaxWeight { get; set; }

        /// <summary>
        /// Cost per flight minute for the aircraft.
        /// </summary>
        public double MinuteCost { get; set; }

        /// <summary>
        /// Indicates whether the aircraft can operate international flights.
        /// </summary>
        public bool CanFlyInternational { get; set; }

        // =========================
        // 💰 PRICING
        // =========================

        /// <summary>
        /// Final price of the Empty Leg flight after applying discounts.
        /// </summary>
        public double FinalPrice { get; set; }

        // =========================
        // 🕒 ITINERARY
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
        /// Total flight duration in minutes.
        /// </summary>
        public double DurationMinutes { get; set; }

        /// <summary>
        /// Estimated Flight Time formatted as a human-readable string
        /// (e.g., "0h 40m").
        /// </summary>
        public string EFT { get; set; } = null!;

        // =========================
        // 🛫 DEPARTURE AIRPORT
        // =========================

        /// <summary>
        /// IATA code of the departure airport.
        /// </summary>
        public string DepartureIATA { get; set; } = null!;

        /// <summary>
        /// ICAO code of the departure airport.
        /// </summary>
        public string DepartureOACI { get; set; } = null!;

        /// <summary>
        /// Name of the departure airport.
        /// </summary>
        public string DepartureAirportName { get; set; } = null!;

        /// <summary>
        /// City of the departure airport.
        /// </summary>
        public string DepartureCity { get; set; } = null!;

        /// <summary>
        /// Country of the departure airport.
        /// </summary>
        public string DepartureCountry { get; set; } = null!;

        /// <summary>
        /// Image URL representing the departure airport.
        /// </summary>
        public string DepartureAirportImage { get; set; } = null!;

        // =========================
        // 🛬 ARRIVAL AIRPORT
        // =========================

        /// <summary>
        /// IATA code of the arrival airport.
        /// </summary>
        public string ArrivalIATA { get; set; } = null!;

        /// <summary>
        /// ICAO code of the arrival airport.
        /// </summary>
        public string ArrivalOACI { get; set; } = null!;

        /// <summary>
        /// Name of the arrival airport.
        /// </summary>
        public string ArrivalAirportName { get; set; } = null!;

        /// <summary>
        /// City of the arrival airport.
        /// </summary>
        public string ArrivalCity { get; set; } = null!;

        /// <summary>
        /// Country of the arrival airport.
        /// </summary>
        public string ArrivalCountry { get; set; } = null!;

        /// <summary>
        /// Image URL representing the arrival airport.
        /// </summary>
        public string ArrivalAirportImage { get; set; } = null!;

        // =========================
        // 🏢 COMPANY INFORMATION
        // =========================

        /// <summary>
        /// Name of the company offering the Empty Leg flight.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Identifier of the company offering the Empty Leg flight.
        /// </summary>
        public int CompanyId { get; set; }

        // =========================
        // 🧾 FRONTEND HELPERS
        // =========================

        /// <summary>
        /// Maximum number of passengers allowed for booking.
        /// For Empty Leg flights, this equals the total number of seats.
        /// </summary>
        public int MaxPassengerCount => Seats;
    }
}
