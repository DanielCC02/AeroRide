using System;
using System.Collections.Generic;
using AeroRide.API.Models.DTOs.Flights;
using AeroRide.API.Models.DTOs.Passengers;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Representa la información completa de una reserva registrada en el sistema.
    /// Incluye vuelos, pasajeros, compañía y detalles de costos.
    /// </summary>
    public class ReservationResponseDto
    {
        /// <summary>
        /// Identificador único de la reserva.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Código visible de la reserva (ejemplo: AERO-2025-00123).
        /// </summary>
        public string ReservationCode { get; set; } = null!;

        /// <summary>
        /// Identificador del usuario que realizó la reserva.
        /// </summary>
        public int UserId { get; set; }

        /// <summary>
        /// Compañía operadora de los vuelos en esta reserva.
        /// </summary>
        public string CompanyName { get; set; } = null!;

        /// <summary>
        /// Porcentaje de ganancia que corresponde a la aplicación AeroRide.
        /// </summary>
        public double PorcentPrice { get; set; }

        /// <summary>
        /// Precio total de la reserva incluyendo tasas e impuestos.
        /// </summary>
        public double TotalPrice { get; set; }

        /// <summary>
        /// Indica si la reserva es de ida y vuelta.
        /// </summary>
        public bool IsRoundTrip { get; set; }

        /// <summary>
        /// Indica si hay un infante en regazo (sin asiento asignado).
        /// </summary>
        public bool LapChild { get; set; }

        /// <summary>
        /// Indica si se requiere asistencia de animal de apoyo.
        /// </summary>
        public bool AssistanceAnimal { get; set; }

        /// <summary>
        /// Estado actual de la reserva (Pendiente, Confirmada, Cancelada).
        /// </summary>
        public ReservationStatus Status { get; set; }

        /// <summary>
        /// Observaciones o comentarios asociados a la reserva.
        /// </summary>
        public string? Notes { get; set; }

        /// <summary>
        /// Fecha de creación de la reserva.
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// Fecha de última actualización (si aplica).
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        /// <summary>
        /// Lista de pasajeros incluidos en la reserva.
        /// </summary>
        public List<PassengerDetailDto> Passengers { get; set; } = new();

        /// <summary>
        /// Lista de vuelos asociados a esta reserva.
        /// </summary>
        public List<FlightSummaryDto> Flights { get; set; } = new();
    }
}
