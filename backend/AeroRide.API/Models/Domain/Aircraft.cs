using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents an aircraft registered in the AeroRide system.
    /// It includes technical information, capacity, operational status,
    /// and its relationship with the owning company.
    /// </summary>
    public class Aircraft
    {
        // ======================================================
        // 🔑 IDENTIFICATION
        // ======================================================

        public int Id { get; set; }

        // ======================================================
        // ✈️ GENERAL AND TECHNICAL INFORMATION
        // ======================================================

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
        /// Maximum number of passenger seats.
        /// </summary>
        public int Seats { get; set; }

        /// <summary>
        /// Maximum allowable weight of the aircraft.
        /// </summary>
        public int MaxWeight { get; set; }

        /// <summary>
        /// Cruising speed of the aircraft.
        /// </summary>
        public double CruisingSpeed { get; set; }

        /// <summary>
        /// Indicates whether the aircraft is authorized for international flights.
        /// </summary>
        public bool CanFlyInternational { get; set; } = false;

        /// <summary>
        /// Current operational state of the aircraft.
        /// </summary>
        public AircraftState State { get; set; } = AircraftState.Disponible;

        /// <summary>
        /// UTC date and time when the aircraft status was last updated.
        /// </summary>
        public DateTime StatusLastUpdated { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// URL or path to the aircraft image.
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Indicates whether the aircraft is active within the system.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Empty (unloaded) weight of the aircraft.
        /// </summary>
        public int EmptyWeight { get; set; }

        // ======================================================
        // 🌎 LOCATION AND RELATIONSHIPS
        // ======================================================

        /// <summary>
        /// Base airport (hangar) where the aircraft normally operates.
        /// </summary>
        public int BaseAirportId { get; set; }
        public Airport BaseAirport { get; set; } = null!;

        /// <summary>
        /// Airport where the aircraft is currently located.
        /// This may differ from the base airport during operations or recent flights.
        /// </summary>
        public int? CurrentAirportId { get; set; }
        public Airport? CurrentAirport { get; set; }

        /// <summary>
        /// Identifier of the company that owns the aircraft.
        /// </summary>
        public int CompanyId { get; set; }
        public Company Company { get; set; } = null!;

        // ======================================================
        // 🔗 NAVIGATION RELATIONSHIPS
        // ======================================================

        /// <summary>
        /// Collection of flights associated with this aircraft.
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();
    }
}
