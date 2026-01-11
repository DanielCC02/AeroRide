using AeroRide.API.Models.Enums;
using System;
using System.Collections.Generic;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents a flight reservation made by a user.
    /// It contains information about the customer, the operating company,
    /// the associated flights, and the included passengers.
    /// </summary>
    public class Reservation
    {
        /// <summary>
        /// Unique identifier of the reservation.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Unique, user-visible reservation code (e.g., AERO-2025-00123).
        /// </summary>
        public string ReservationCode { get; set; } = null!;

        /// <summary>
        /// Identifier of the user who created the reservation.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Identifier of the operating company associated with the reservation.
        /// </summary>
        public int CompanyId { get; set; }

        /// <summary>
        /// Profit percentage received by the AeroRide platform
        /// from the total reservation amount.
        /// </summary>
        public double PorcentPrice { get; set; }

        /// <summary>
        /// Total price of the reservation, including fees and taxes.
        /// </summary>
        public double TotalPrice { get; set; }

        /// <summary>
        /// Indicates whether the reservation includes a round-trip flight.
        /// </summary>
        public bool IsRoundTrip { get; set; }

        /// <summary>
        /// Indicates whether the reservation includes a lap child
        /// (infant without an assigned seat).
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indicates whether an assistance animal is required.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        /// <summary>
        /// Current status of the reservation (Pending, Confirmed, Cancelled).
        /// </summary>
        public ReservationStatus Status { get; set; } = ReservationStatus.Pendiente;

        /// <summary>
        /// Additional comments or notes associated with the reservation.
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// UTC date and time when the reservation was created.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// UTC date and time when the reservation was last updated, if applicable.
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        // ===============================
        // 🔗 RELATIONSHIPS
        // ===============================

        /// <summary>
        /// Reference to the user who created the reservation.
        /// </summary>
        public User User { get; set; } = null!;

        /// <summary>
        /// Reference to the operating company associated with the reservation.
        /// </summary>
        public Company Company { get; set; } = null!;

        /// <summary>
        /// Collection of flights associated with this reservation.
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();

        /// <summary>
        /// Collection of passengers included in this reservation.
        /// </summary>
        public ICollection<PassengerDetail> Passengers { get; set; } = new List<PassengerDetail>();
    }
}
