using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Summary information of a flight associated with a reservation.
    /// </summary>
    public class FlightSummaryDto
    {
        /// <summary>
        /// Unique identifier of the flight.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Scheduled departure date and time of the flight.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Scheduled arrival date and time of the flight.
        /// </summary>
        public DateTime ArrivalTime { get; set; }

        /// <summary>
        /// Total flight duration expressed in minutes.
        /// </summary>
        public double DurationMinutes { get; set; }

        /// <summary>
        /// Indicates whether the flight is an Empty Leg.
        /// </summary>
        public bool IsEmptyLeg { get; set; }

        /// <summary>
        /// Indicates whether the flight is international.
        /// </summary>
        public bool IsInternational { get; set; }

        /// <summary>
        /// Current operational status of the flight.
        /// </summary>
        public FlightStatus Status { get; set; }

        /// <summary>
        /// Name of the departure airport.
        /// </summary>
        public string DepartureAirportName { get; set; } = null!;

        /// <summary>
        /// Name of the arrival airport.
        /// </summary>
        public string ArrivalAirportName { get; set; } = null!;

        /// <summary>
        /// Model of the aircraft assigned to the flight.
        /// </summary>
        public string AircraftModel { get; set; } = null!;

        /// <summary>
        /// Name of the company operating the flight.
        /// </summary>
        public string CompanyName { get; set; } = null!;
    }
}
