namespace AeroRide.API.Models.DTOs.EmptyLegs
{
    /// <summary>
    /// Data Transfer Object used to display Empty Leg flights
    /// in listing views or cards.
    /// </summary>
    public class EmptyLegListDto
    {
        /// <summary>
        /// Unique identifier of the Empty Leg flight.
        /// </summary>
        public int Id { get; set; }

        // =========================
        // 🕒 SCHEDULE
        // =========================

        /// <summary>
        /// Scheduled departure date and time of the Empty Leg flight.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        // =========================
        // 🛫 / 🛬 AIRPORTS
        // =========================

        /// <summary>
        /// Name of the departure airport.
        /// </summary>
        public string DepartureAirportName { get; set; } = null!;

        /// <summary>
        /// IATA code of the departure airport.
        /// </summary>
        public string DepartureIATA { get; set; } = null!;

        /// <summary>
        /// Name of the arrival airport.
        /// </summary>
        public string ArrivalAirportName { get; set; } = null!;

        /// <summary>
        /// IATA code of the arrival airport.
        /// </summary>
        public string ArrivalIATA { get; set; } = null!;

        // =========================
        // ✈️ AIRCRAFT
        // =========================

        /// <summary>
        /// Aircraft model used for the Empty Leg flight.
        /// </summary>
        public string AircraftModel { get; set; } = null!;

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

        // =========================
        // 💰 PRICING
        // =========================

        /// <summary>
        /// Final price of the Empty Leg flight after applying discounts.
        /// </summary>
        public double FinalPrice { get; set; }
    }
}
