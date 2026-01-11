using AeroRide.API.Models.DTOs.Flights;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Data Transfer Object used to request a price and availability
    /// estimate for a reservation.
    /// </summary>
    public class ReservationEstimateDto
    {
        /// <summary>
        /// List of real aircraft identifiers that belong to the selected model.
        /// The backend will select the best available aircraft.
        /// </summary>
        public List<int> AircraftIds { get; set; } = new();

        /// <summary>
        /// Total number of passengers included in the reservation.
        /// </summary>
        public int TotalPassengers { get; set; }

        /// <summary>
        /// List of flight segments used to calculate the estimate.
        /// </summary>
        public List<FlightSegmentDto> Segments { get; set; } = new();
    }
}
