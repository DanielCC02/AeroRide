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
        /// Nombre oficial del aeropuerto (por ejemplo: <c>Aeropuerto Internacional Juan Santamaría</c>).
        /// </summary>
        public string Name { get; set; } = null!;

        /// <summary>
        /// Código IATA (International Air Transport Association) de tres letras.
        /// Ejemplo: <c>SJO</c>.
        /// </summary>
        public string CodeIATA { get; set; } = null!;

        /// <summary>
        /// Código OACI (Organización de Aviación Civil Internacional) de cuatro letras.
        /// Ejemplo: <c>MROC</c>.
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
        /// Algunos aeropuertos operan las 24 horas, por lo que este campo puede ser <c>null</c>.
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
        /// Representación geoespacial del aeropuerto como punto en PostGIS.
        /// Utiliza el sistema de referencia WGS84 (<c>SRID 4326</c>).
        /// </summary>
        public Point Ubication { get; set; } = null!;

        /// <summary>
        /// Imagen o recurso gráfico representativo del aeropuerto (puede ser URL o ruta local).
        /// </summary>
        public string Image { get; set; } = null!;

        /// <summary>
        /// Impuesto o tasa aeroportuaria aplicada a los vuelos que operan en este aeropuerto.
        /// </summary>
        public double Tax { get; set; }

        /// <summary>
        /// Colección de vuelos que despegan desde este aeropuerto.
        /// Representa la relación uno a muchos (<c>1:N</c>) entre <see cref="Airport"/> y <see cref="Flight"/>.
        /// </summary>
        public ICollection<Flight> DepartureFlights { get; set; } = new List<Flight>();

        /// <summary>
        /// Colección de vuelos que aterrizan en este aeropuerto.
        /// </summary>
        public ICollection<Flight> ArrivalFlights { get; set; } = new List<Flight>();
    }
}
