namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// DTO de respuesta utilizado al crear o actualizar un aeropuerto.
    /// Contiene los datos finales almacenados en el sistema.
    /// </summary>
    public class AirportResponseDto
    {
        /// <summary>Identificador único del aeropuerto.</summary>
        public int Id { get; set; }

        /// <summary>Nombre oficial del aeropuerto.</summary>
        public string Name { get; set; } = null!;

        /// <summary>Código IATA de tres letras.</summary>
        public string CodeIATA { get; set; } = null!;

        /// <summary>Código OACI de cuatro letras.</summary>
        public string CodeOACI { get; set; } = null!;

        /// <summary>Ciudad donde se encuentra el aeropuerto.</summary>
        public string City { get; set; } = null!;

        /// <summary>País donde se localiza el aeropuerto.</summary>
        public string Country { get; set; } = null!;

        /// <summary>Hora de apertura (puede ser nula si opera 24/7).</summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>Hora de cierre (puede ser nula si opera 24/7).</summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>Latitud geográfica en formato decimal.</summary>
        public decimal Latitude { get; set; }

        /// <summary>Longitud geográfica en formato decimal.</summary>
        public decimal Longitude { get; set; }

        /// <summary>URL de la imagen representativa del aeropuerto.</summary>
        public string Image { get; set; } = null!;

        /// <summary>Indica si el aeropuerto está activo o no en el sistema.</summary>
        public bool IsActive { get; set; }
    }
}
