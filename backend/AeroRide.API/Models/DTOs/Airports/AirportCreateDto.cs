using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// Data Transfer Object used to register a new airport in the system.
    /// </summary>
    public class AirportCreateDto
    {
        /// <summary>
        /// Official name of the airport
        /// (e.g., Daniel Oduber Quirós International Airport).
        /// </summary>
        [Required(ErrorMessage = "The airport name is required.")]
        public string Name { get; set; } = null!;

        /// <summary>
        /// Three-letter IATA code (e.g., LIR).
        /// </summary>
        [Required(ErrorMessage = "The IATA code is required.")]
        [StringLength(3, MinimumLength = 3, ErrorMessage = "The IATA code must be exactly 3 letters long.")]
        public string CodeIATA { get; set; } = null!;

        /// <summary>
        /// Four-letter ICAO code (e.g., MRLB).
        /// </summary>
        [Required(ErrorMessage = "The ICAO code is required.")]
        [StringLength(4, MinimumLength = 4, ErrorMessage = "The ICAO code must be exactly 4 letters long.")]
        public string CodeOACI { get; set; } = null!;

        /// <summary>
        /// City where the airport is located.
        /// </summary>
        [Required(ErrorMessage = "The city is required.")]
        public string City { get; set; } = null!;

        /// <summary>
        /// Country where the airport is located.
        /// </summary>
        [Required(ErrorMessage = "The country is required.")]
        public string Country { get; set; } = null!;

        /// <summary>
        /// Airport opening time (optional).
        /// </summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>
        /// Airport closing time (optional).
        /// </summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>
        /// Number of minutes before closing time during which departures are still allowed.
        /// </summary>
        public int DepartureMarginMinutes { get; set; } = 60;

        /// <summary>
        /// Number of minutes before closing time during which arrivals are still allowed.
        /// </summary>
        public int ArrivalMarginMinutes { get; set; } = 30;

        /// <summary>
        /// Time zone of the airport (e.g., "America/Costa_Rica").
        /// </summary>
        [Required(ErrorMessage = "The time zone is required.")]
        public string TimeZone { get; set; } = null!;

        /// <summary>
        /// Geographic latitude expressed in decimal format.
        /// </summary>
        [Required(ErrorMessage = "Latitude is required.")]
        [Range(-90, 90)]
        public decimal Latitude { get; set; }

        /// <summary>
        /// Geographic longitude expressed in decimal format.
        /// </summary>
        [Required(ErrorMessage = "Longitude is required.")]
        [Range(-180, 180)]
        public decimal Longitude { get; set; }

        /// <summary>
        /// URL of the image representing the airport.
        /// It is expected to be a blob URL from Azure Storage.
        /// </summary>
        [Required(ErrorMessage = "An image must be provided.")]
        public string Image { get; set; } = null!;

        /// <summary>
        /// Maximum allowable aircraft weight at the airport, in kilograms.
        /// </summary>
        public int MaxAllowedWeight { get; set; }
    }
}
