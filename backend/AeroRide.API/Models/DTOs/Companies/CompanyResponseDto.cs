namespace AeroRide.API.Models.DTOs.Companies
{
    /// <summary>
    /// Response Data Transfer Object that represents a company
    /// stored in the AeroRide system.
    /// </summary>
    public class CompanyResponseDto
    {
        /// <summary>
        /// Unique identifier of the company.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Company legal or commercial name.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Primary contact email address of the company.
        /// </summary>
        public string? Email { get; set; }

        /// <summary>
        /// Primary contact phone number of the company.
        /// </summary>
        public string? PhoneNumber { get; set; }

        /// <summary>
        /// Physical or legal address of the company.
        /// </summary>
        public string? Address { get; set; }

        /// <summary>
        /// Discount percentage applied to Empty Leg flights
        /// (e.g., 0.5 = 50% discount).
        /// </summary>
        public double EmptyLegDiscount { get; set; }

        /// <summary>
        /// Indicates whether the company is active in the system.
        /// </summary>
        public bool IsActive { get; set; }

        /// <summary>
        /// Date and time when the company was created (UTC).
        /// </summary>
        public DateTime CreatedAt { get; set; }

        // ======================================================
        // 💰 PRICING CONFIGURATION
        // ======================================================

        /// <summary>
        /// Hourly waiting cost for domestic flights.
        /// </summary>
        public double DomesticWaitHourCost { get; set; }

        /// <summary>
        /// Hourly waiting cost for international flights.
        /// </summary>
        public double InternationalWaitHourCost { get; set; }

        /// <summary>
        /// Overnight stay cost for domestic flights.
        /// </summary>
        public double DomesticOvernightCost { get; set; }

        /// <summary>
        /// Overnight stay cost for international flights.
        /// </summary>
        public double InternationalOvernightCost { get; set; }

        /// <summary>
        /// Airport tax applied per passenger (international flights only).
        /// </summary>
        public double AirportTaxPerPassenger { get; set; }

        /// <summary>
        /// Handling fee applied per passenger (international flights only).
        /// </summary>
        public double HandlingPerPassenger { get; set; }
    }
}
