using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Represents a flight segment within a reservation.
    /// Allows creating multiple segments
    /// (e.g., A → B → C → A).
    /// </summary>
    public class FlightSegmentDto
    {
        /// <summary>
        /// Identifier of the departure airport for this flight segment.
        /// </summary>
        [Required]
        public int DepartureAirportId { get; set; }

        /// <summary>
        /// Identifier of the arrival airport for this flight segment.
        /// </summary>
        [Required]
        public int ArrivalAirportId { get; set; }

        /// <summary>
        /// Scheduled departure date and time for this segment.
        /// </summary>
        [Required]
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Scheduled arrival date and time for this segment.
        /// </summary>
        [Required]
        public DateTime ArrivalTime { get; set; }
    }
}
