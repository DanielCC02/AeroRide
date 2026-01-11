using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// Data Transfer Object used to partially update an existing aircraft.
    /// It allows modifying technical information, capacity, or location.
    /// </summary>
    public class AircraftUpdateDto
    {
        /// <summary>
        /// Updated aircraft registration or tail number.
        /// </summary>
        public string? Patent { get; set; }

        /// <summary>
        /// Updated aircraft model.
        /// </summary>
        public string? Model { get; set; }

        /// <summary>
        /// Updated operational cost per flight minute.
        /// </summary>
        public double? MinuteCost { get; set; }

        /// <summary>
        /// Updated number of passenger seats.
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "The aircraft must have at least one seat.")]
        public int? Seats { get; set; }

        /// <summary>
        /// Updated empty (unloaded) weight of the aircraft.
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "The empty weight must be greater than zero.")]
        public int? EmptyWeight { get; set; }

        /// <summary>
        /// Updated maximum allowable weight of the aircraft.
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "The maximum weight must be greater than zero.")]
        public int? MaxWeight { get; set; }

        /// <summary>
        /// Updated cruising speed of the aircraft in kilometers per hour.
        /// </summary>
        [Range(100, 1000, ErrorMessage = "The cruising speed must be between 100 and 1000 km/h.")]
        public double? CruisingSpeed { get; set; }

        /// <summary>
        /// Indicates whether the aircraft is authorized to operate international flights.
        /// </summary>
        public bool? CanFlyInternational { get; set; }

        /// <summary>
        /// New technical state of the aircraft
        /// (Disponible, EnMantenimiento, or FueraDeServicio).
        /// </summary>
        public AircraftState? State { get; set; }

        /// <summary>
        /// Updated image representing the aircraft.
        /// </summary>
        public string? Image { get; set; }

        /// <summary>
        /// Indicates whether the aircraft is active in the system.
        /// </summary>
        public bool? IsActive { get; set; }

        /// <summary>
        /// New base airport, if the aircraft is being relocated.
        /// </summary>
        public int? BaseAirportId { get; set; }

        /// <summary>
        /// Current airport, if the aircraft is temporarily outside its base.
        /// </summary>
        public int? CurrentAirportId { get; set; }
    }
}
