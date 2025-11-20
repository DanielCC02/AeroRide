namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO utilizado para representar una categoría agrupada de aeronaves disponibles.
    /// </summary>
    public class AircraftCategoryDto
    {
        public string Model { get; set; } = null!;
        public int Seats { get; set; }
        public int CompanyId { get; set; }
        public string CompanyName { get; set; } = null!;
        public string Image { get; set; } = null!;
        public string BaseCountry { get; set; } = null!;
        public string BaseAirportName { get; set; } = null!;
        public bool CanFlyInternational { get; set; }

        // 🔥 NECESARIO PARA SABER QUÉ AERONAVE REAL ESCOLLER
        public List<int> AircraftIds { get; set; } = new();
    }

}
