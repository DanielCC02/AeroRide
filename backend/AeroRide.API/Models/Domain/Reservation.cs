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
        /// Código único de la reserva (por ejemplo: "AERO-2025-00123").
        /// Útil para identificación pública o confirmaciones por correo.
        /// </summary>
        public string ReservationCode { get; set; } = null!;

        /// <summary>
        /// Identificador del usuario que realizó la reserva.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Identificador de la empresa operadora de la reserva.
        /// </summary>
        public int CompanyId { get; set; }

        //Plata que nos toca, a la sociedad
        public double PorcentPrice { get; set; }

        /// <summary>
        /// Precio total de la reserva, incluyendo tarifas, impuestos, tasas y servicios adicionales.
        /// </summary>
        public double TotalPrice { get; set; }

        /// <summary>
        /// Indica si la reserva es de tipo ida y vuelta (Round Trip) o solo de ida (One Way).
        /// </summary>
        public bool IsRoundTrip { get; set; }

        /// <summary>
        /// Indica si entre los pasajeros viaja un infante en regazo (sin asiento asignado).
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si se requiere asistencia de un animal de apoyo o servicio durante el vuelo.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        /// <summary>
        /// Estado actual de la reserva (Pendiente, Confirmada, Cancelada).
        /// </summary>
        public string Status { get; set; } = "Pendiente";

        /// <summary>
        /// Observaciones o comentarios asociados a la reserva.
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// Fecha y hora en que se creó la reserva.
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Fecha y hora de la última actualización de la reserva.
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        // ======================================================
        // 🔗 RELACIONES DE NAVEGACIÓN
        // ======================================================

        /// <summary>
        /// Usuario propietario de la reserva.
        /// </summary>
        public User User { get; set; } = null!;

        /// <summary>
        /// Empresa o aerolínea responsable de la operación de los vuelos en esta reserva.
        /// </summary>
        public Company Company { get; set; } = null!;

        /// <summary>
        /// Colección de vuelos asociados a la reserva.
        /// Una reserva puede incluir uno o varios vuelos (por ejemplo, ida y vuelta).
        /// </summary>
        public ICollection<Flight> Flights { get; set; } = new List<Flight>();

        /// <summary>
        /// Lista de pasajeros registrados en la reserva.
        /// Cada pasajero se almacena en la entidad <see cref="PassengerDetail"/>.
        /// </summary>
        public ICollection<PassengerDetail> Passengers { get; set; } = new List<PassengerDetail>();
    }
}
