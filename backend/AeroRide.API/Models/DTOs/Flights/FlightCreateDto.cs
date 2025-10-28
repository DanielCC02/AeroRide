namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Objeto de transferencia utilizado para crear un nuevo vuelo en el sistema.
    /// Puede corresponder a un vuelo programado o un "Empty Leg".
    /// </summary>
    public class FlightCreateDto
    {
        /// <summary>
        /// Identificador de la aeronave asignada al vuelo.
        /// </summary>
        public int AircraftId { get; set; }

        /// <summary>
        /// Identificador del aeropuerto de salida.
        /// </summary>
        public int DepartureAirportId { get; set; }

        /// <summary>
        /// Identificador del aeropuerto de llegada.
        /// </summary>
        public int ArrivalAirportId { get; set; }

        /// <summary>
        /// Fecha y hora de salida del vuelo.
        /// </summary>
        public DateTime DepartureTime { get; set; }

        /// <summary>
        /// Fecha y hora de llegada del vuelo.
        /// </summary>
        public DateTime ArrivalTime { get; set; }

        /// <summary>
        /// Indica si el vuelo es un "Empty Leg" (vuelo vacío disponible para reserva).
        /// </summary>
        public bool IsEmptyLeg { get; set; }
    }
}
