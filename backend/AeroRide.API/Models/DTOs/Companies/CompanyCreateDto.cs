using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Companies
{
    /// <summary>
    /// Data Transfer Object used to create a new company
    /// within the AeroRide system.
    /// </summary>
    public class CompanyCreateDto
    {
        /// <summary>
        /// Company legal or commercial name.
        /// </summary>
        [Required, StringLength(100)]
        public string Name { get; set; } = null!;

        /// <summary>
        /// Primary contact email address of the company.
        /// </summary>
        [Required, EmailAddress]
        public string Email { get; set; } = null!;

        /// <summary>
        /// Primary contact phone number of the company.
        /// </summary>
        [Required, Phone]
        public string PhoneNumber { get; set; } = null!;

        /// <summary>
        /// Physical or legal address of the company.
        /// </summary>
        [Required, StringLength(200)]
        public string Address { get; set; } = null!;

        /// <summary>
        /// Discount percentage applied to Empty Leg flights
        /// (e.g., 0.5 = 50% discount).
        /// </summary>
        [Range(0, 1)]
        public double EmptyLegDiscount { get; set; } = 0.5;

        // ======================================================
        // 💰 OPTIONAL PRICING CONFIGURATION
        // ======================================================

        /// <summary>
        /// Hourly waiting cost for domestic flights.
        /// If not provided, the system default value is used.
        /// </summary>
        public double? DomesticWaitHourCost { get; set; }

        /// <summary>
        /// Hourly waiting cost for international flights.
        /// If not provided, the system default value is used.
        /// </summary>
        public double? InternationalWaitHourCost { get; set; }

        /// <summary>
        /// Overnight stay cost for domestic flights.
        /// If not provided, the system default value is used.
        /// </summary>
        public double? DomesticOvernightCost { get; set; }

        /// <summary>
        /// Overnight stay cost for international flights.
        /// If not provided, the system default value is used.
        /// </summary>
        public double? InternationalOvernightCost { get; set; }

        /// <summary>
        /// Airport tax applied per passenger (international flights only).
        /// If not provided, the system default value is used.
        /// </summary>
        public double? AirportTaxPerPassenger { get; set; }

        /// <summary>
        /// Handling fee applied per passenger (international flights only).
        /// If not provided, the system default value is used.
        /// </summary>
        public double? HandlingPerPassenger { get; set; }
    }
}
