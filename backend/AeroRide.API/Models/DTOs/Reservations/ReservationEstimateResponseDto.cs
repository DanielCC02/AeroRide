namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Representa el desglose detallado del costo estimado de una reserva de vuelo,
    /// incluyendo duración total, costos base, impuestos, horas de espera y pernocta.
    /// </summary>
    public class ReservationEstimateResponseDto
    {
        /// <summary>Duración total del vuelo en minutos (sumatoria de todos los tramos).</summary>
        public double TotalMinutes { get; set; }

        /// <summary>Tarifa por minuto de vuelo según el modelo de aeronave seleccionado.</summary>
        public double MinuteCost { get; set; }

        /// <summary>Costo base del vuelo (sin incluir impuestos ni cargos adicionales).</summary>
        public double BaseCost { get; set; }

        /// <summary>Impuestos aeroportuarios y de handling (solo para vuelos internacionales).</summary>
        public double Taxes { get; set; }

        /// <summary>Costo por horas de espera entre segmentos.</summary>
        public double WaitCost { get; set; }

        /// <summary>Costo de pernocta si la aeronave queda fuera de su base.</summary>
        public double OvernightCost { get; set; }

        /// <summary>Precio total calculado de la reserva (base + impuestos + extras).</summary>
        public double TotalPrice { get; set; }

        /// <summary>Indica si la ruta incluye segmentos internacionales.</summary>
        public bool IsInternational { get; set; }
    }
}
