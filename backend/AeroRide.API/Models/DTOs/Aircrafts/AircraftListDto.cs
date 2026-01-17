namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// Lightweight Data Transfer Object used for general aircraft listings.
    /// </summary>
    public class AircraftListDto
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
        /// Current operational state of the aircraft, represented as text.
        /// </summary>
        public string State { get; set; } = null!;

        /// <summary>
        /// Indicates whether the aircraft is active in the system.
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Empty (unloaded) weight of the aircraft, in kilograms.
        /// </summary>
        public int EmptyWeight { get; set; }

        /// <summary>
        /// Name of the company that owns or operates the aircraft.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Name of the base airport where the aircraft normally operates.
        /// </summary>
        public string BaseAirportName { get; set; } = null!;
    }
}
