namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Represents an operational base (airport) associated with an airline company.
    /// Each company may have multiple bases, with one designated as the primary base.
    /// </summary>
    public class CompanyBase
    {
        /// <summary>
        /// Unique identifier of the company base record.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identifier of the company that owns this operational base.
        /// </summary>
        public int CompanyId { get; set; }
        public Company Company { get; set; } = null!;

        /// <summary>
        /// Identifier of the airport that serves as the operational base.
        /// </summary>
        public int AirportId { get; set; }
        public Airport Airport { get; set; } = null!;

        /// <summary>
        /// Indicates whether this base is the primary base of the company.
        /// </summary>
        public bool IsPrimary { get; set; } = false;
    }
}
