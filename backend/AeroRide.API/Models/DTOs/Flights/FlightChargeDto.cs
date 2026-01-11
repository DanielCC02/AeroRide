using System;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Breakdown of costs and taxes associated with a specific flight.
    /// </summary>
    public class FlightChargeDto
    {
        /// <summary>
        /// Unique identifier of the flight charge record.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Base cost of the flight
        /// (aircraft rate multiplied by flight duration).
        /// </summary>
        public double BaseCost { get; set; }

        /// <summary>
        /// Total amount of taxes and additional fees applied to the flight.
        /// </summary>
        public double TaxesAndFees { get; set; }

        /// <summary>
        /// Discount percentage applied to the flight
        /// (e.g., 0.5 = 50% discount).
        /// </summary>
        public double DiscountApplied { get; set; }

        /// <summary>
        /// Final total charge after applying taxes and discounts.
        /// </summary>
        public double TotalCharge { get; set; }

        /// <summary>
        /// Date and time when the flight charges were calculated (UTC).
        /// </summary>
        public DateTime CalculatedAt { get; set; }

        /// <summary>
        /// Identifier of the flight associated with these charges.
        /// </summary>
        public int FlightId { get; set; }

        /// <summary>
        /// Name of the company responsible for the flight operation.
        /// </summary>
        public string CompanyName { get; set; } = null!;
    }
}
