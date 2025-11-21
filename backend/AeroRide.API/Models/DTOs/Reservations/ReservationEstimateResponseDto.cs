namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Representa el desglose detallado del costo estimado de una reserva de vuelo,
    /// incluyendo duración total, costos base, impuestos, horas de espera y pernocta.
    /// </summary>
    public class ReservationEstimateResponseDto
    {
        public int AircraftId { get; set; }

        public double TotalMinutes { get; set; }
        public double MinuteCost { get; set; }
        public double BaseCost { get; set; }
        public double Taxes { get; set; }
        public double WaitCost { get; set; }
        public double OvernightCost { get; set; }
        public double TotalPrice { get; set; }
        public bool IsInternational { get; set; }
    }

}
