namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// Data Transfer Object used to represent a grouped category
    /// of available aircraft.
    /// </summary>
    public class AircraftCategoryDto
    {
        /// <summary>
        /// Aircraft model name used to group similar aircraft.
        /// </summary>
        public string Model { get; set; } = null!;

        /// <summary>
        /// Number of passenger seats available in the aircraft.
        /// </summary>
        public int Seats { get; set; }

        /// <summary>
        /// Identifier of the company that operates the aircraft.
        /// </summary>
        public int CompanyId { get; set; }

        /// <summary>
        /// Name of the company that operates the aircraft.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Image representing the aircraft category.
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Country where the aircraft base airport is located.
        /// </summary>
        public string BaseCountry { get; set; } = null!;

        /// <summary>
        /// Name of the base airport where the aircraft normally operates.
        /// </summary>
        public string BaseAirportName { get; set; } = null!;

        /// <summary>
        /// Indicates whether the aircraft category is authorized
        /// to operate international flights.
        /// </summary>
        public bool CanFlyInternational { get; set; }

        /// <summary>
        /// List of identifiers of the actual aircraft instances
        /// belonging to this category.
        /// This is required to determine which specific aircraft
        /// will be selected for a reservation.
        /// </summary>
        public List<int> AircraftIds { get; set; } = new();
    }
}
