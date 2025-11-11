namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO completo utilizado para mostrar los detalles técnicos de una aeronave.
    /// </summary>
    public class AircraftResponseDto
    {
        public int Id { get; set; }
        public string Patent { get; set; } = null!;
        public string Model { get; set; } = null!;
        public double MinuteCost { get; set; }
        public int Seats { get; set; }
        public int EmptyWeight { get; set; }
        public int MaxWeight { get; set; }
        public double CruisingSpeed { get; set; }
        public bool CanFlyInternational { get; set; }
        public string State { get; set; } = null!;
        public string Image { get; set; } = null!;
        public bool IsActive { get; set; }

        /// <summary>Nombre de la compañía propietaria.</summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>Nombre del aeropuerto base.</summary>
        public string BaseAirportName { get; set; } = null!;

        /// <summary>Nombre del aeropuerto actual (si aplica).</summary>
        public string? CurrentAirportName { get; set; }
    }
}
