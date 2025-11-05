using System;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Resumen de un vuelo asociado a una reserva.
    /// </summary>
    public class FlightSummaryDto
    {
        public int Id { get; set; }

        public DateTime DepartureTime { get; set; }

        public DateTime ArrivalTime { get; set; }

        public double DurationMinutes { get; set; }

        public bool IsEmptyLeg { get; set; }

        public bool IsInternational { get; set; }

        public FlightStatus Status { get; set; }

        public string DepartureAirportName { get; set; } = null!;

        public string ArrivalAirportName { get; set; } = null!;

        public string AircraftModel { get; set; } = null!;

        public string CompanyName { get; set; } = null!;
    }
}
