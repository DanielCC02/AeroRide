namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una reserva de vuelo realizada por un usuario.
    /// 
    /// Contiene la información de costos, servicios especiales, 
    /// pasajeros asociados y los vuelos incluidos en la reserva.
    /// 
    /// Una reserva puede incluir uno o varios vuelos (ida, vuelta o conexiones),
    /// y múltiples pasajeros registrados bajo el mismo usuario.
    /// </summary>
    public class Reservation
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
        /// Precio total de la reserva, incluyendo tarifas, impuestos, tasas y servicios adicionales.
        /// </summary>
        public double Price { get; set; }

        /// <summary>
        /// Indica si entre los pasajeros viaja un infante en regazo (sin asiento asignado).
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si se requiere asistencia de un animal de apoyo o servicio durante el vuelo.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        // ======================================================
        // 🔗 Relaciones de navegación
        // ======================================================

        /// <summary>
        /// Usuario propietario de la reserva.
        /// </summary>
        public User User { get; set; } = null!;

        /// <summary>
        /// Colección de vuelos asociados a la reserva.
        /// Una reserva puede incluir uno o varios vuelos (por ejemplo, ida y vuelta).
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();

        /// <summary>
        /// Lista de pasajeros registrados en la reserva.
        /// Cada pasajero se almacena en la entidad <see cref="PassengerDetails"/>.
        /// </summary>
        public ICollection<PassengerDetails> Passengers { get; set; } = new List<PassengerDetails>();
    }
}
