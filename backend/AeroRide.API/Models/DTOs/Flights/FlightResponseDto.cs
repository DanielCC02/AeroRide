using System;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// DTO de respuesta para representar vuelos con toda la información relacionada.
    /// </summary>
    public class FlightResponseDto
    {
        public int Id { get; set; }
        public DateTime DepartureTime { get; set; }
        public DateTime ArrivalTime { get; set; }
        public double DurationMinutes { get; set; }
        public bool IsEmptyLeg { get; set; }
        public bool IsInternational { get; set; }
        public string Status { get; set; } = string.Empty;

        // =====================
        // 🔗 Relacionados
        // =====================
        public string? DepartureAirportName { get; set; }
        public string? ArrivalAirportName { get; set; }
        public string? AircraftModel { get; set; }
        public string? AircraftPatent { get; set; }
        public string? CompanyName { get; set; }
        public string? ReservationCode { get; set; }
    }
}
