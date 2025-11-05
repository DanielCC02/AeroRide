using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Aircrafts
{
    public class UpdateAircraftStateDto
    {
        public AircraftState State { get; set; } = AircraftState.Disponible;
    }
}
