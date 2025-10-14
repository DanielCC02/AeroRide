namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// DTO que muestra toda la información detallada de un aeropuerto.
    /// </summary>
    public class AirportDetailDto
    {
        /// <summary>Identificador único del aeropuerto.</summary>
        public int Id { get; set; }

        /// <summary>Nombre oficial del aeropuerto.</summary>
        public string Name { get; set; } = null!;

        /// <summary>Código IATA (tres letras).</summary>
        public string CodeIATA { get; set; } = null!;

        /// <summary>Código OACI (cuatro letras).</summary>
        public string CodeOACI { get; set; } = null!;

        /// <summary>Ciudad donde se ubica.</summary>
        public string City { get; set; } = null!;

        /// <summary>País donde se localiza.</summary>
        public string Country { get; set; } = null!;

        /// <summary>Hora de apertura del aeropuerto (opcional).</summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>Hora de cierre del aeropuerto (opcional).</summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>Latitud geográfica (decimal).</summary>
        public decimal Latitude { get; set; }

        /// <summary>Longitud geográfica (decimal).</summary>
        public decimal Longitude { get; set; }

        /// <summary>Tasa aeroportuaria aplicada a vuelos.</summary>
        public double Tax { get; set; }

        /// <summary>URL de la imagen principal del aeropuerto.</summary>
        public string Image { get; set; } = null!;

        /// <summary>Indica si el aeropuerto está activo en el sistema.</summary>
        public bool IsActive { get; set; }
    }
}
