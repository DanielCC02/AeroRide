using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// Data Transfer Object used to update the operational
    /// state of an aircraft.
    /// </summary>
    public class UpdateAircraftStateDto
    {
        /// <summary>
        /// New operational state of the aircraft.
        /// </summary>
        public AircraftState State { get; set; } = AircraftState.Disponible;
    }
}
