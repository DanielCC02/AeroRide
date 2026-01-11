using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.DTOs.Passengers;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Data required to create a new reservation
    /// within the AeroRide system.
    /// </summary>
    public class ReservationCreateDto
    {
        /// <summary>
        /// Identifier of the company operating the reservation.
        /// </summary>
        [Required]
        public int CompanyId { get; set; }

        /// <summary>
        /// Aircraft model selected for the reservation.
        /// </summary>
        [Required]
        [StringLength(100)]
        public string AircraftModel { get; set; } = null!;

        /// <summary>
        /// List of valid aircraft identifiers available
        /// for the selected model and company.
        /// </summary>
        public List<int> AircraftIds { get; set; } = new();

        /// <summary>
        /// Percentage of profit applied by the AeroRide platform.
        /// </summary>
        [Range(0, 100)]
        public double PorcentPrice { get; set; }

        /// <summary>
        /// Total price of the reservation, including all taxes and fees.
        /// </summary>
        [Range(0, double.MaxValue)]
        public double TotalPrice { get; set; }

        /// <summary>
        /// Indicates whether the reservation is a round trip.
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
        /// Optional additional notes associated with the reservation.
        /// </summary>
        [StringLength(250)]
        public string? Notes { get; set; }

        /// <summary>
        /// List of passengers included in the reservation.
        /// At least one passenger is required.
        /// </summary>
        [Required]
        [MinLength(1, ErrorMessage = "At least one passenger must be included.")]
        public List<PassengerCreateDto> Passengers { get; set; } = new();

        /// <summary>
        /// List of flight segments that compose the reservation.
        /// At least one segment is required.
        /// </summary>
        [Required]
        [MinLength(1, ErrorMessage = "At least one flight segment must be included.")]
        public List<FlightSegmentDto> Segments { get; set; } = new();
    }
}
