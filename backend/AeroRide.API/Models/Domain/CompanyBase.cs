namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Representa una base operativa (aeropuerto) perteneciente a una compañía aérea.
    /// Cada compañía puede tener múltiples bases y una marcada como principal.
    /// </summary>
    public class CompanyBase
    {
        public int Id { get; set; }

        /// <summary>
        /// Identificador de la compañía propietaria de esta base.
        /// </summary>
        public int CompanyId { get; set; }
        public Company Company { get; set; } = null!;

        /// <summary>
        /// Identificador del aeropuerto que actúa como base operativa.
        /// </summary>
        public int AirportId { get; set; }
        public Airport Airport { get; set; } = null!;

        /// <summary>
        /// Indica si esta base es la base principal de la compañía.
        /// </summary>
        public bool IsPrimary { get; set; } = false;
    }
}
