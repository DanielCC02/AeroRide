using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// Data Transfer Object used to register a new aircraft in the AeroRide system.
    /// It contains technical information, capacity details, and base location data.
    /// </summary>
    public class AircraftCreateDto
    {
        // ======================================================
        // 🔑 IDENTIFICATION
        // ======================================================

        /// <summary>
        /// Aircraft registration or tail number.
        /// </summary>
        [Required(ErrorMessage = "The 'Patent' field is required.")]
        [StringLength(20, ErrorMessage = "The registration number cannot exceed 20 characters.")]
        public string Patent { get; set; } = null!;

        /// <summary>
        /// Aircraft model.
        /// </summary>
        [Required(ErrorMessage = "The 'Model' field is required.")]
        [StringLength(100, ErrorMessage = "The model name cannot exceed 100 characters.")]
        public string Model { get; set; } = null!;

        // ======================================================
        // 💰 FEATURES AND CAPACITY
        // ======================================================

        /// <summary>
        /// Operational cost per flight minute.
        /// </summary>
        [Range(0, double.MaxValue, ErrorMessage = "The minute cost must be a positive value.")]
        public double MinuteCost { get; set; }

        /// <summary>
        /// Number of passenger seats available in the aircraft.
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "The aircraft must have at least one seat.")]
        public int Seats { get; set; }

        /// <summary>
        /// Empty (unloaded) weight of the aircraft.
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "The empty weight must be greater than zero.")]
        public int EmptyWeight { get; set; }

        /// <summary>
        /// Maximum allowable weight of the aircraft.
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "The maximum weight must be greater than zero.")]
        public int MaxWeight { get; set; }

        /// <summary>
        /// Cruising speed of the aircraft in kilometers per hour.
        /// </summary>
        [Range(100, 1000, ErrorMessage = "The cruising speed must be between 100 and 1000 km/h.")]
        public double CruisingSpeed { get; set; }

        /// <summary>
        /// Indicates whether the aircraft is authorized to operate international flights.
        /// </summary>
        public bool CanFlyInternational { get; set; } = false;

        /// <summary>
        /// Initial technical state of the aircraft
        /// (Disponible, EnMantenimiento, or FueraDeServicio).
        /// </summary>
        [EnumDataType(typeof(AircraftState))]
        public AircraftState State { get; set; } = AircraftState.Disponible;

        /// <summary>
        /// Image representing the aircraft.
        /// </summary>
        [Required(ErrorMessage = "An image must be provided.")]
        public string Image { get; set; } = null!;

        // ======================================================
        // 🌎 LOCATION AND RELATIONSHIPS
        // ======================================================

        /// <summary>
        /// Identifier of the base airport where the aircraft normally operates.
        /// </summary>
        [Required(ErrorMessage = "The base airport must be specified.")]
        public int BaseAirportId { get; set; }

        /// <summary>
        /// Identifier of the airport where the aircraft is currently located (optional).
        /// If not specified, it is assumed to be the same as the base airport.
        /// </summary>
        public int? CurrentAirportId { get; set; }

        /// <summary>
        /// Identifier of the company that owns the aircraft.
        /// </summary>
        [Required(ErrorMessage = "The owning company must be specified.")]
        public int CompanyId { get; set; }
    }
}
