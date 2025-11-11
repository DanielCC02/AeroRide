namespace AeroRide.API.Models.DTOs.Aircrafts
{
    /// <summary>
    /// DTO liviano para listados generales de aeronaves.
    /// </summary>
    public class AircraftListDto
    {
        public int Id { get; set; }
        public string Patent { get; set; } = null!;
        public string Model { get; set; } = null!;
        public string State { get; set; } = null!;
        public bool IsActive { get; set; }

        /// <summary>Peso en vacío de la aeronave (kg).</summary>
        public int EmptyWeight { get; set; }

        /// <summary>Nombre de la compañía a la que pertenece.</summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>Aeropuerto base de la aeronave.</summary>
        public string BaseAirportName { get; set; } = null!;
    }
}
