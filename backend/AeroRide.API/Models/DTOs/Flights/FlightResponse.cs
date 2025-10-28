namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Objeto de transferencia utilizado para devolver los detalles completos de un vuelo.
    /// Incluye la información de horarios, aeropuertos y aeronave asignada.
    /// </summary>
    public class FlightResponse
    {
        /// <summary>
        /// Identificador único del vuelo.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identificador de la aeronave asignada.
        /// </summary>
        public int AircraftId { get; set; }

        /// <summary>
        /// Nombre o código del aeropuerto de salida.
        /// </summary>
        public string DepartureAirport { get; set; } = null!;

        /// <summary>
        /// Nombre o código del aeropuerto de llegada.
        /// </summary>
        public string ArrivalAirport { get; set; } = null!;

        /// <summary>
        /// Fecha y hora de salida.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Fecha y hora de llegada.
        /// </summary>
        public DateTime ArrivalTime { get; set; }

        /// <summary>
        /// Indica si el vuelo es un "Empty Leg" (vuelo vacío).
        /// </summary>
        public bool IsEmptyLeg { get; set; }
    }
}
