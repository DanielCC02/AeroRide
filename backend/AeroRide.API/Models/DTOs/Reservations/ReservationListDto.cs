using System;
using AeroRide.API.Models.Enums;

namespace AeroRide.API.Models.DTOs.Reservations
{
    /// <summary>
    /// Versión resumida de una reserva, ideal para listados.
    /// </summary>
    public class ReservationListDto
    {
        public int Id { get; set; }
        public string ReservationCode { get; set; } = null!;
        public string CompanyName { get; set; } = null!;
        public double TotalPrice { get; set; }
        public ReservationStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
