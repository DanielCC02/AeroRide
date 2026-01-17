namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// Data Transfer Object used to display airport listings
    /// in administrative views or tables.
    /// </summary>
    public class AirportListDto
    {
        /// <summary>
        /// Unique identifier of the airport.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Airport name.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// IATA airport code.
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
        /// Time zone of the airport.
        /// </summary>
        public string TimeZone { get; set; } = null!;

        /// <summary>
        /// Country where the airport is located.
        /// </summary>
        public string Country { get; set; } = null!;

        /// <summary>
        /// Geographic latitude expressed in decimal format.
        /// </summary>
        public decimal Latitude { get; set; }

        /// <summary>
        /// Geographic longitude expressed in decimal format.
        /// </summary>
        public decimal Longitude { get; set; }

        /// <summary>
        /// Number of minutes before closing time during which departures are still allowed.
        /// </summary>
        public int DepartureMarginMinutes { get; set; }

        /// <summary>
        /// Number of minutes before closing time during which arrivals are still allowed.
        /// </summary>
        public int ArrivalMarginMinutes { get; set; }

        /// <summary>
        /// URL of the main image representing the airport.
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
