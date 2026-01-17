namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// Data Transfer Object used to update an existing airport.
    /// It allows one or more fields to be updated optionally.
    /// </summary>
    public class AirportUpdateDto
    {
        /// <summary>
        /// Updated official name of the airport (optional).
        /// </summary>
        public string? Name { get; set; }

        /// <summary>
        /// Updated three-letter IATA code (optional).
        /// </summary>
        public string? CodeIATA { get; set; }

        /// <summary>
        /// Updated four-letter ICAO code (optional).
        /// </summary>
        public string? CodeOACI { get; set; }

        /// <summary>
        /// Updated city where the airport is located (optional).
        /// </summary>
        public string? City { get; set; }

        /// <summary>
        /// Updated country where the airport is located (optional).
        /// </summary>
        public string? Country { get; set; }

        /// <summary>
        /// Updated time zone of the airport (optional).
        /// </summary>
        public string? TimeZone { get; set; }

        /// <summary>
        /// Updated airport opening time (optional).
        /// </summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>
        /// Updated airport closing time (optional).
        /// </summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>
        /// Updates the departure margin before closing time, in minutes (optional).
        /// </summary>
        public int? DepartureMarginMinutes { get; set; }

        /// <summary>
        /// Updates the arrival margin before closing time, in minutes (optional).
        /// </summary>
        public int? ArrivalMarginMinutes { get; set; }

        /// <summary>
        /// Updated geographic latitude, in decimal format (optional).
        /// </summary>
        public decimal? Latitude { get; set; }

        /// <summary>
        /// Updated geographic longitude, in decimal format (optional).
        /// </summary>
        public decimal? Longitude { get; set; }

        /// <summary>
        /// URL of the updated airport image (optional).
        /// If changed, the previous image will be removed from Azure Storage.
        /// </summary>
        public string? Image { get; set; }

        /// <summary>
        /// Indicates whether the airport should be active or inactive (optional).
        /// If <c>true</c>, the airport is activated; if <c>false</c>, it is deactivated.
        /// </summary>
        public bool? IsActive { get; set; }

        /// <summary>
        /// Updates the maximum allowable aircraft weight at the airport, in kilograms (optional).
        /// </summary>
        public int? MaxAllowedWeight { get; set; }
    }
}
