using AeroRide.API.Models.Enums;
using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Flights
{
    public class UpdateFlightStatusDto
    {
        [Required]
        public FlightStatus Status { get; set; }
    }
}
