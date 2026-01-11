using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Companies
{
    /// <summary>
    /// Data Transfer Object used to update an existing company.
    /// All properties are optional and only the provided fields
    /// will be updated.
    /// </summary>
    public class CompanyUpdateDto
    {
        /// <summary>
        /// Updated legal or commercial name of the company (optional).
        /// </summary>
        [StringLength(100)]
        public string? Name { get; set; }

        /// <summary>
        /// Updated primary contact email address of the company (optional).
        /// </summary>
        [EmailAddress]
        public string? Email { get; set; }

        /// <summary>
        /// Updated primary contact phone number of the company (optional).
        /// </summary>
        [Phone]
        public string? PhoneNumber { get; set; }

        /// <summary>
        /// Updated physical or legal address of the company (optional).
        /// </summary>
        [StringLength(200)]
        public string? Address { get; set; }

        /// <summary>
        /// Updated discount percentage applied to Empty Leg flights
        /// (e.g., 0.5 = 50% discount) (optional).
        /// </summary>
        [Range(0, 1)]
        public double? EmptyLegDiscount { get; set; }

        /// <summary>
        /// Indicates whether the company should be active or inactive (optional).
        /// </summary>
        public bool? IsActive { get; set; }

        // ======================================================
        // 💰 OPTIONAL PRICING CONFIGURATION
        // ======================================================

        /// <summary>
        /// Updated hourly waiting cost for domestic flights (optional).
        /// </summary>
        public double? DomesticWaitHourCost { get; set; }

        /// <summary>
        /// Updated hourly waiting cost for international flights (optional).
        /// </summary>
        public double? InternationalWaitHourCost { get; set; }

        /// <summary>
        /// Updated overnight stay cost for domestic flights (optional).
        /// </summary>
        public double? DomesticOvernightCost { get; set; }

        /// <summary>
        /// Updated overnight stay cost for international flights (optional).
        /// </summary>
        public double? InternationalOvernightCost { get; set; }

        /// <summary>
        /// Updated airport tax applied per passenger (international flights only) (optional).
        /// </summary>
        public double? AirportTaxPerPassenger { get; set; }

        /// <summary>
        /// Updated handling fee applied per passenger (international flights only) (optional).
        /// </summary>
        public double? HandlingPerPassenger { get; set; }
    }
}
