using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Representa un tramo de vuelo dentro de una reserva.
    /// Permite crear múltiples segmentos (ejemplo: A → B → C → A).
    /// </summary>
    public class FlightSegmentDto
    {
        [Required]
        public int DepartureAirportId { get; set; }

        [Required]
        public int ArrivalAirportId { get; set; }

        [Required]
        public DateTime DepartureTime { get; set; }

        [Required]
        public DateTime ArrivalTime { get; set; }
    }
}
