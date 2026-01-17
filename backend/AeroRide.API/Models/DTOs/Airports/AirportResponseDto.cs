namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// Response Data Transfer Object used when creating or updating an airport.
    /// It contains the final data stored in the system.
    /// </summary>
    public class AirportResponseDto
    {
        /// <summary>
        /// Unique identifier of the airport.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Official name of the airport.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Three-letter IATA airport code.
        /// </summary>
        public string CodeIATA { get; set; } = null!;

        /// <summary>
        /// Four-letter ICAO airport code.
        /// </summary>
        public string CodeOACI { get; set; } = null!;

        /// <summary>
        /// City where the airport is located.
        /// </summary>
        public string City { get; set; } = null!;

        /// <summary>
        /// Country where the airport is located.
        /// </summary>
        public string Country { get; set; } = null!;

        /// <summary>
        /// Time zone of the airport.
        /// </summary>
        public string TimeZone { get; set; } = null!;

        /// <summary>
        /// Airport opening time.
        /// May be <c>null</c> if the airport operates 24/7.
        /// </summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>
        /// Airport closing time.
        /// May be <c>null</c> if the airport operates 24/7.
        /// </summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>
        /// Number of minutes before closing time during which departures are still allowed.
        /// </summary>
        public int DepartureMarginMinutes { get; set; }

        /// <summary>
        /// Number of minutes before closing time during which arrivals are still allowed.
        /// </summary>
        public int ArrivalMarginMinutes { get; set; }

        /// <summary>
        /// Geographic latitude expressed in decimal format.
        /// </summary>
        public decimal Latitude { get; set; }

        /// <summary>
        /// Geographic longitude expressed in decimal format.
        /// </summary>
        public decimal Longitude { get; set; }

        /// <summary>
        /// URL of the image representing the airport.
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Indicates whether the airport is active in the system.
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Maximum allowable aircraft weight at the airport, in kilograms.
        /// </summary>
        public int MaxAllowedWeight { get; set; }
    }
}
