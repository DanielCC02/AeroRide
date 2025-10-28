using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.DTOs.Passengers;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Objeto de respuesta detallada que representa una reserva con sus relaciones.
    /// Incluye la información del usuario, los vuelos y los pasajeros asociados.
    /// </summary>
    public class ReservationResponse
    {
        /// <summary>
        /// Identificador único de la reserva.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Identificador del usuario que realizó la reserva.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Correo electrónico del usuario asociado a la reserva.
        /// </summary>
        public string UserEmail { get; set; } = null!;

        /// <summary>
        /// Precio total de la reserva, incluyendo todos los cargos e impuestos.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Indica si en la reserva viaja un infante en regazo.
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si algún pasajero requiere viajar con un animal de asistencia.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        /// <summary>
        /// Lista de pasajeros registrados bajo la reserva.
        /// </summary>
        public List<PassengerResponse> Passengers { get; set; } = new();

        /// <summary>
        /// Lista de vuelos asociados a la reserva.
        /// </summary>
        public List<FlightResponse> Flights { get; set; } = new();
    }
}
