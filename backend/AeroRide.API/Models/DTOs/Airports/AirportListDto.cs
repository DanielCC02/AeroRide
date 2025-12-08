namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// DTO para mostrar listados de aeropuertos en vistas o tablas administrativas.
    /// </summary>
    public class AirportListDto
    {
        /// <summary>Identificador único del aeropuerto.</summary>
        public int Id { get; set; }

        /// <summary>Nombre del aeropuerto.</summary>
        public string Name { get; set; } = null!;


        /// <summary>Código IATA.</summary>
        public string CodeIATA { get; set; } = null!;

        /// <summary>Código OACI (cuatro letras).</summary>
        public string CodeOACI { get; set; } = null!;

        /// <summary>Ciudad donde se encuentra.</summary>
        public string City { get; set; } = null!;

        public string TimeZone { get; set; } = null!;

        /// <summary>País del aeropuerto.</summary>
        public string Country { get; set; } = null!;

        /// <summary>Latitud geográfica (decimal).</summary>
        public decimal Latitude { get; set; }

        /// <summary>Longitud geográfica (decimal).</summary>
        public decimal Longitude { get; set; }
        public int DepartureMarginMinutes { get; set; }
        public int ArrivalMarginMinutes { get; set; }

        /// <summary>URL de la imagen principal del aeropuerto.</summary>
        public string Image { get; set; } = null!;

        /// <summary>Indica si el aeropuerto está activo o no.</summary>
        public bool IsActive { get; set; }

        /// <summary>Peso máximo permitido en el aeropuerto (en kg).</summary>
        public int MaxAllowedWeight { get; set; }

    }
}
