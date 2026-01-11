using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.DTOs.Passengers;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Represents the complete information of a reservation registered in the system.
    /// Includes associated flights, passengers, operating company, and cost details.
    /// </summary>
    public class ReservationResponseDto
    {
        /// <summary>
        /// Unique identifier of the reservation.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Public reservation code (e.g., AERO-2025-00123).
        /// </summary>
        public string ReservationCode { get; set; } = null!;

        /// <summary>
        /// Identifier of the user who created the reservation.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Name of the company operating the flights in this reservation.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Percentage of profit allocated to the AeroRide platform.
        /// </summary>
        public double PorcentPrice { get; set; }

        /// <summary>
        /// Total reservation price, including taxes and fees.
        /// </summary>
        public double TotalPrice { get; set; }

        /// <summary>
        /// Indicates whether the reservation is a round trip.
        /// </summary>
        public bool IsRoundTrip { get; set; }

        /// <summary>
        /// Indicates whether there is a lap infant (no assigned seat).
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indicates whether assistance from a support animal is required.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        /// <summary>
        /// Current status of the reservation (Pending, Confirmed, Cancelled).
        /// </summary>
        public ReservationStatus Status { get; set; }

        /// <summary>
        /// Additional notes or comments associated with the reservation.
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// Date and time when the reservation was created (UTC).
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// Date and time of the last update, if applicable (UTC).
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        /// <summary>
        /// List of passengers included in the reservation.
        /// </summary>
        public List<PassengerDetailDto> Passengers { get; set; } = new();

        /// <summary>
        /// List of flights associated with this reservation.
        /// </summary>
        public List<FlightSummaryDto> Flights { get; set; } = new();
    }
}
