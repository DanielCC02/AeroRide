namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Objeto de transferencia utilizado para mostrar una lista resumida de vuelos.
    /// Ideal para listados administrativos o selección de vuelos disponibles.
    /// </summary>
    public class FlightListDto
    {
        /// <summary>
        /// Identificador único del vuelo.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Aeropuerto de salida (nombre o código).
        /// </summary>
        public string DepartureAirport { get; set; } = null!;

        /// <summary>
        /// Aeropuerto de llegada (nombre o código).
        /// </summary>
        public string ArrivalAirport { get; set; } = null!;

        /// <summary>
        /// Fecha y hora programada de salida.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Fecha y hora programada de llegada.
        /// </summary>
        public DateTime ArrivalTime { get; set; }
    }
}
