using AeroRide.API.Models.Enums;
using System;
using System.Collections.Generic;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa una reserva de vuelo realizada por un usuario.
    /// Contiene información sobre el cliente, la compañía operadora,
    /// los vuelos asociados y los pasajeros incluidos.
    /// </summary>
    public class Reservation
    {
        /// <summary>
        /// Identificador único de la reserva.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Código único visible de la reserva (ejemplo: AERO-2025-00123).
        /// </summary>
        public string ReservationCode { get; set; } = null!;

        /// <summary>
        /// Usuario que realizó la reserva.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Compañía operadora a la cual pertenece la reserva.
        /// </summary>
        public int CompanyId { get; set; }

        /// <summary>
        /// Porcentaje de ganancia que recibe la aplicación AeroRide
        /// sobre el monto total de la reserva.
        /// </summary>
        public double PorcentPrice { get; set; }

        /// <summary>
        /// Precio total de la reserva, incluyendo tasas e impuestos.
        /// </summary>
        public double TotalPrice { get; set; }

        /// <summary>
        /// Indica si la reserva incluye vuelo de ida y vuelta.
        /// </summary>
        public bool IsRoundTrip { get; set; }

        /// <summary>
        /// Indica si hay un infante en regazo (sin asiento asignado).
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si se requiere asistencia de un animal de apoyo.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        /// <summary>
        /// Estado actual de la reserva (Pendiente, Confirmada, Cancelada).
        /// </summary>
        public ReservationStatus Status { get; set; } = ReservationStatus.Pendiente;

        /// <summary>
        /// Comentarios adicionales asociados a la reserva.
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

        // ===============================
        // 🔗 RELACIONES
        // ===============================

        public User User { get; set; } = null!;

        public Company Company { get; set; } = null!;

        public ICollection<Flight> Flights { get; set; } = new List<Flight>();

        public ICollection<PassengerDetail> Passengers { get; set; } = new List<PassengerDetail>();
    }
}
