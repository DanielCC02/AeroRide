using System.ComponentModel.DataAnnotations;

namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// DTO utilizado para registrar un nuevo aeropuerto en el sistema.
    /// </summary>
    public class AirportCreateDto
    {
        /// <summary>Nombre del aeropuerto (por ejemplo: Aeropuerto Internacional Daniel Oduber Quirós).</summary>
        [Required(ErrorMessage = "El nombre del aeropuerto es obligatorio.")]
        public string Name { get; set; } = null!;

        /// <summary>Código IATA de tres letras (ejemplo: LIR).</summary>
        [Required(ErrorMessage = "El código IATA es obligatorio.")]
        [StringLength(3, MinimumLength = 3, ErrorMessage = "El código IATA debe tener exactamente 3 letras.")]
        public string CodeIATA { get; set; } = null!;

        /// <summary>Código OACI de cuatro letras (ejemplo: MRLB).</summary>
        [Required(ErrorMessage = "El código OACI es obligatorio.")]
        [StringLength(4, MinimumLength = 4, ErrorMessage = "El código OACI debe tener exactamente 4 letras.")]
        public string CodeOACI { get; set; } = null!;

        /// <summary>Ciudad donde se ubica el aeropuerto.</summary>
        [Required(ErrorMessage = "La ciudad es obligatoria.")]
        public string City { get; set; } = null!;

        /// <summary>País donde se localiza el aeropuerto.</summary>
        [Required(ErrorMessage = "El país es obligatorio.")]
        public string Country { get; set; } = null!;

        /// <summary>Hora de apertura (opcional).</summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>Hora de cierre (opcional).</summary>
        public TimeSpan? ClosingTime { get; set; }

        [Required(ErrorMessage = "La zona horaria es obligatoria.")]
        public string TimeZone { get; set; } = null!;

        /// <summary>Latitud geográfica (decimal).</summary>
        [Required(ErrorMessage = "La latitud es obligatoria.")]
        public decimal Latitude { get; set; }

        /// <summary>Longitud geográfica (decimal).</summary>
        [Required(ErrorMessage = "La longitud es obligatoria.")]
        public decimal Longitude { get; set; }

        /// <summary>
        /// URL de la imagen representativa del aeropuerto (opcional).
        /// Se espera que sea la dirección del blob en Azure Storage.
        /// </summary>
        [Required(ErrorMessage = "Debe proporcionar una imagen.")]
        public string Image { get; set; } = null!;

    }
}
