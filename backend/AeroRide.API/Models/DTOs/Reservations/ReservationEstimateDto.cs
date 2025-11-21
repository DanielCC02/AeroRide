using AeroRide.API.Models.DTOs.Flights;

namespace AeroRide.API.Models.DTOs.Reservations
{
    public class ReservationEstimateDto
    {
        /// <summary>
        /// Lista de IDs de aeronaves reales que pertenecen al modelo seleccionado.
        /// El backend elegirá la mejor aeronave disponible.
        /// </summary>
        public List<int> AircraftIds { get; set; } = new();

        public int TotalPassengers { get; set; }

        public List<FlightSegmentDto> Segments { get; set; } = new();
    }

}
