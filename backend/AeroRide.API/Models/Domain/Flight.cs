using AeroRide.API.Models.Enums;
using System;
using System.Collections.Generic;

namespace AeroRide.API.Models.Domain
{
    /// <summary>
    /// Entidad que representa un vuelo registrado en el sistema AeroRide.
    /// Puede corresponder a un vuelo reservado o a un "Empty Leg" disponible.
    /// Incluye horarios, aeropuertos, aeronave, empresa operadora y cargos asociados.
    /// </summary>
    public class Flight
    {
        public int Id { get; set; }

        // =========================
        // 🕒 DATOS OPERATIVOS
        // =========================
        public DateTime DepartureTime { get; set; }

        public DateTime ArrivalTime { get; set; }

        /// <summary>
        /// Duración total en minutos (calculada automáticamente).
        /// </summary>
        public double DurationMinutes { get; set; }

        public bool IsEmptyLeg { get; set; }

        public bool IsInternational { get; set; }

        public FlightStatus Status { get; set; } = FlightStatus.Programado;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        // =========================
        // 🔗 RELACIONES
        // =========================

        public int? ReservationId { get; set; }
        public Reservation? Reservation { get; set; }

        public int AircraftId { get; set; }
        public Aircraft Aircraft { get; set; } = null!;

        public int DepartureAirportId { get; set; }
        public Airport DepartureAirport { get; set; } = null!;

        public int ArrivalAirportId { get; set; }
        public Airport ArrivalAirport { get; set; } = null!;

        public int CompanyId { get; set; }
        public Company Company { get; set; } = null!;

        public FlightCharge? Charge { get; set; }

        public ICollection<FlightAssignment> Assignments { get; set; } = new List<FlightAssignment>();
    }
}
