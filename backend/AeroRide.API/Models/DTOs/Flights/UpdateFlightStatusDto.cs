using AeroRide.API.Models.Enums;
using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Data Transfer Object used to update the operational
    /// status of an existing flight.
    /// </summary>
    public class UpdateFlightStatusDto
    {
        /// <summary>
        /// New operational status of the flight.
        /// </summary>
        [Required]
        public FlightStatus Status { get; set; }
    }
}
