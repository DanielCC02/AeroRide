using AeroRide.API.Models.DTOs.Flights;

namespace AeroRide.API.Models.DTOs.Reservations
{
    public class ReservationEstimateDto
    {
        public int CompanyId { get; set; }
        public string AircraftModel { get; set; } = null!;
        public int TotalPassengers { get; set; }
        public List<FlightSegmentDto> Segments { get; set; } = new();
    }
}
