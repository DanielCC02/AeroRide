using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Lightweight representation of a reservation,
    /// ideal for list and table views.
    /// </summary>
    public class ReservationListDto
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
        /// Name of the company operating the reservation.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Total price of the reservation, including taxes and fees.
        /// </summary>
        public double TotalPrice { get; set; }

        /// <summary>
        /// Current status of the reservation.
        /// </summary>
        public ReservationStatus Status { get; set; }

        /// <summary>
        /// Date and time when the reservation was created (UTC).
        /// </summary>
        public DateTime CreatedAt { get; set; }
    }
}
