namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para representar una categoría agrupada de aeronaves disponibles.
    /// </summary>
    public class AircraftCategoryDto
    {
        public int Id { get; set; }                 // <-- ADD THIS
        public string Model { get; set; } = null!;
        public int Seats { get; set; }
        public int CompanyId { get; set; }          // <-- ADD THIS
        public string CompanyName { get; set; } = null!;
        public string State { get; set; } = null!;

        /// <summary>
        /// Indica si las aeronaves de este modelo pueden operar vuelos internacionales.
        /// </summary>
        public bool CanFlyInternational { get; set; }

        /// <summary>
        /// Imagen representativa del modelo.
        /// </summary>
        public string Image { get; set; } = null!;

        public string BaseCountry { get; set; } = null!;   // ← NUEVO
        public string BaseAirportName { get; set; } = null!; // ← opcional pero recomendable
    }
}
