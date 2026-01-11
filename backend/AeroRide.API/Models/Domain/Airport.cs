using NetTopologySuite.Geometries;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents an airport registered in the AeroRide system.
    /// It contains general information, geographic location data, and
    /// relationships with flights that depart from or arrive at this airport.
    /// </summary>
    public class Airport
    {
        /// <summary>
        /// Unique identifier of the airport.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Official name of the airport (e.g., Juan Santamaría International Airport).
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Three-letter IATA (International Air Transport Association) code.
        /// Example: SJO.
        /// </summary>
        public string CodeIATA { get; set; } = null!;

        /// <summary>
        /// Four-letter ICAO (International Civil Aviation Organization) code.
        /// Example: MROC.
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
        /// Time zone of the airport (e.g., "America/Costa_Rica").
        /// </summary>
        public string TimeZone { get; set; } = null!;

        /// <summary>
        /// Airport opening time (optional).
        /// </summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>
        /// Airport closing time (optional).
        /// </summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>
        /// Minimum number of minutes before closing time required to allow departures.
        /// </summary>
        public int DepartureMarginMinutes { get; set; } = 60;

        /// <summary>
        /// Minimum number of minutes before closing time required to allow arrivals.
        /// </summary>
        public int ArrivalMarginMinutes { get; set; } = 30;

        /// <summary>
        /// Geographic latitude expressed in decimal format.
        /// </summary>
        public decimal Latitude { get; set; }

        /// <summary>
        /// Geographic longitude expressed in decimal format.
        /// </summary>
        public decimal Longitude { get; set; }

        /// <summary>
        /// Geospatial representation of the airport as a point in PostGIS (SRID 4326).
        /// </summary>
        public Point Ubication { get; set; } = null!;

        /// <summary>
        /// Image or graphical resource representing the airport (URL or local path).
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Maximum allowable aircraft weight (in kilograms) that the airport can operate.
        /// Used to restrict aircraft that exceed operational limits.
        /// </summary>
        public int MaxAllowedWeight { get; set; } = 5000;

        /// <summary>
        /// Indicates whether the airport is active in the system.
        /// </summary>
        public bool IsActive { get; set; } = true;

        // =====================
        // RELATIONSHIPS
        // =====================

        /// <summary>
        /// Collection of flights departing from this airport.
        /// </summary>
        public ICollection<Flight> DepartureFlights { get; set; } = new List<Flight>();

        /// <summary>
        /// Collection of flights arriving at this airport.
        /// </summary>
        public ICollection<Flight> ArrivalFlights { get; set; } = new List<Flight>();
    }
}
