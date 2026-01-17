namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// Full Data Transfer Object used to display the technical
    /// and operational details of an aircraft.
    /// </summary>
    public class AircraftResponseDto
    {
        /// <summary>
        /// Unique identifier of the aircraft.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Aircraft registration or tail number.
        /// </summary>
        public string Patent { get; set; } = null!;

        /// <summary>
        /// Aircraft model.
        /// </summary>
        public string Model { get; set; } = null!;

        /// <summary>
        /// Operational cost per flight minute.
        /// </summary>
        public double MinuteCost { get; set; }

        /// <summary>
        /// Number of passenger seats available in the aircraft.
        /// </summary>
        public int Seats { get; set; }

        /// <summary>
        /// Empty (unloaded) weight of the aircraft.
        /// </summary>
        public int EmptyWeight { get; set; }

        /// <summary>
        /// Maximum allowable weight of the aircraft.
        /// </summary>
        public int MaxWeight { get; set; }

        /// <summary>
        /// Cruising speed of the aircraft.
        /// </summary>
        public double CruisingSpeed { get; set; }

        /// <summary>
        /// Indicates whether the aircraft is authorized
        /// to operate international flights.
        /// </summary>
        public bool CanFlyInternational { get; set; }

        /// <summary>
        /// Current operational state of the aircraft, represented as text.
        /// </summary>
        public string State { get; set; } = null!;

        /// <summary>
        /// Image representing the aircraft.
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Indicates whether the aircraft is active in the system.
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Name of the company that owns or operates the aircraft.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Name of the base airport where the aircraft normally operates.
        /// </summary>
        public string BaseAirportName { get; set; } = null!;

        /// <summary>
        /// Name of the current airport where the aircraft is located, if applicable.
        /// </summary>
        public string? CurrentAirportName { get; set; }
    }
}
