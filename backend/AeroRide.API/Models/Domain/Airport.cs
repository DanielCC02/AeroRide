using NetTopologySuite.Geometries;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa un aeropuerto registrado en el sistema AeroRide.
    /// Contiene información general, ubicación geográfica y relaciones con los vuelos
    /// que despegan o aterrizan en este aeropuerto.
    /// </summary>
    public class Airport
    {
        /// <summary>
        /// Identificador único del aeropuerto.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Nombre oficial del aeropuerto (por ejemplo: Aeropuerto Internacional Juan Santamaría).
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Código IATA (International Air Transport Association) de tres letras. Ejemplo: SJO.
        /// </summary>
        public string CodeIATA { get; set; } = null!;

        /// <summary>
        /// Código OACI (Organización de Aviación Civil Internacional) de cuatro letras. Ejemplo: MROC.
        /// </summary>
        public string CodeOACI { get; set; } = null!;

        /// <summary>
        /// Ciudad en la que se encuentra ubicado el aeropuerto.
        /// </summary>
        public string City { get; set; } = null!;

        /// <summary>
        /// País donde se localiza el aeropuerto.
        /// </summary>
        public string Country { get; set; } = null!;

        /// <summary>
        /// Hora de apertura del aeropuerto (opcional).
        /// </summary>
        public TimeSpan? OpeningTime { get; set; }

        /// <summary>
        /// Hora de cierre del aeropuerto (opcional).
        /// </summary>
        public TimeSpan? ClosingTime { get; set; }

        /// <summary>
        /// Latitud geográfica expresada en formato decimal.
        /// </summary>
        public decimal Latitude { get; set; }

        /// <summary>
        /// Longitud geográfica expresada en formato decimal.
        /// </summary>
        public decimal Longitude { get; set; }

        /// <summary>
        /// Representación geoespacial del aeropuerto como punto en PostGIS (SRID 4326).
        /// </summary>
        public Point Ubication { get; set; } = null!;

        /// <summary>
        /// Imagen o recurso gráfico representativo del aeropuerto (URL o ruta local).
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Impuesto o tasa aeroportuaria aplicada a los vuelos que operan en este aeropuerto.
        /// </summary>
        public double Tax { get; set; }

        /// <summary>
        /// Indica si el aeropuerto se encuentra activo en el sistema.
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Colección de vuelos que despegan desde este aeropuerto.
        /// </summary>
        public ICollection<Flight> DepartureFlights { get; set; } = new List<Flight>();

        /// <summary>
        /// Colección de vuelos que aterrizan en este aeropuerto.
        /// </summary>
        public ICollection<Flight> ArrivalFlights { get; set; } = new List<Flight>();
    }
}
