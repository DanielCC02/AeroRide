namespace AeroRide.API.Models.DTOs.Airports
{
    /// <summary>
    /// DTO utilizado para modificar los datos de un aeropuerto existente.
    /// Permite actualizar uno o varios campos de forma opcional.
    /// </summary>
    public class AirportUpdateDto
    {
        /// <summary>Nuevo nombre oficial del aeropuerto (opcional).</summary>
        public string? Name { get; set; }

        /// <summary>Nuevo código IATA de tres letras (opcional).</summary>
        public string? CodeIATA { get; set; }

        /// <summary>Nuevo código OACI de cuatro letras (opcional).</summary>
        public string? CodeOACI { get; set; }

        /// <summary>Nueva ciudad donde se ubica el aeropuerto (opcional).</summary>
        public string? City { get; set; }

        /// <summary>Nuevo país donde se localiza el aeropuerto (opcional).</summary>
        public string? Country { get; set; }

        public string? TimeZone { get; set; }  // agregado

        /// <summary>Hora de apertura actualizada (opcional).</summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>Hora de cierre actualizada (opcional).</summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>Nueva latitud geográfica (opcional).</summary>
        public decimal? Latitude { get; set; }

        /// <summary>Nueva longitud geográfica (opcional).</summary>
        public decimal? Longitude { get; set; }

        /// <summary>
        /// URL de la nueva imagen representativa del aeropuerto (opcional).
        /// Si se cambia, la imagen anterior será eliminada del contenedor de Azure.
        /// </summary>
        public string? Image { get; set; }

        /// <summary>
        /// Indica si el aeropuerto debe estar activo o desactivado (opcional).
        /// Si se envía <c>true</c>, se reactiva; si se envía <c>false</c>, se desactiva.
        /// </summary>
        public bool? IsActive { get; set; }

        /// <summary>Actualiza el peso máximo permitido en el aeropuerto (en kg).</summary>
        public int? MaxAllowedWeight { get; set; }

    }
}
