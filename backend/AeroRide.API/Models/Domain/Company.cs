namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entity that represents a company or airline registered in the AeroRide system.
    /// Each company may own aircraft, operate flights, manage reservations,
    /// and have associated staff (users).
    /// It also defines company-specific pricing policies for waiting time,
    /// overnight stays, and applicable taxes.
    /// </summary>
    public class Company
    {
        /// <summary>
        /// Unique identifier of the company.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Legal or commercial name of the company.
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Contact email address of the company.
        /// </summary>
        public string? Email { get; set; }

        /// <summary>
        /// Contact phone number of the company.
        /// </summary>
        public string? PhoneNumber { get; set; }

        /// <summary>
        /// Physical or mailing address of the company.
        /// </summary>
        public string? Address { get; set; }

        /// <summary>
        /// Discount percentage applied to Empty Leg flights
        /// (e.g., 0.5 represents a 50% discount).
        /// </summary>
        public double EmptyLegDiscount { get; set; } = 0.5;

        /// <summary>
        /// Indicates whether the company is active in the system.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// UTC date and time when the company record was created.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // ======================================================
        // 💰 COMPANY-SPECIFIC PRICING CONFIGURATION
        // ======================================================

        /// <summary>
        /// Cost per hour of waiting time for domestic flights.
        /// </summary>
        public double DomesticWaitHourCost { get; set; } = 50;

        /// <summary>
        /// Cost per hour of waiting time for international flights.
        /// </summary>
        public double InternationalWaitHourCost { get; set; } = 200;

        /// <summary>
        /// Overnight stay cost for domestic flights.
        /// </summary>
        public double DomesticOvernightCost { get; set; } = 300;

        /// <summary>
        /// Overnight stay cost for international flights.
        /// </summary>
        public double InternationalOvernightCost { get; set; } = 500;

        /// <summary>
        /// Airport tax applied per passenger for international flights.
        /// </summary>
        public double AirportTaxPerPassenger { get; set; } = 30;

        /// <summary>
        /// Handling cost applied per passenger for international flights.
        /// </summary>
        public double HandlingPerPassenger { get; set; } = 100;

        // ======================================================
        // 🔗 NAVIGATION RELATIONSHIPS
        // ======================================================

        /// <summary>
        /// Collection of base airports associated with the company.
        /// </summary>
        public ICollection<CompanyBase> Bases { get; set; } = new List<CompanyBase>();

        /// <summary>
        /// Collection of users (staff) associated with the company.
        /// </summary>
        public ICollection<User> Users { get; set; } = new List<User>();

        /// <summary>
        /// Collection of aircraft owned or operated by the company.
        /// </summary>
        public ICollection<Aircraft> Aircrafts { get; set; } = new List<Aircraft>();

        /// <summary>
        /// Collection of flights operated by the company.
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();

        /// <summary>
        /// Collection of reservations associated with the company.
        /// </summary>
        public ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

        /// <summary>
        /// Collection of flight charges applied to the company's flights.
        /// </summary>
        public ICollection<FlightCharge> FlightCharges { get; set; } = new List<FlightCharge>();
    }
}
