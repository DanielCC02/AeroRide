using System;

namespace AeroRide.API.Models.DTOs.Flights
{
    /// <summary>
    /// Desglose de costos e impuestos asociados a un vuelo.
    /// </summary>
    public class FlightChargeDto
    {
        public int Id { get; set; }

        public double BaseCost { get; set; }

        public double TaxesAndFees { get; set; }

        public double DiscountApplied { get; set; }

        public double TotalCharge { get; set; }

        public DateTime CalculatedAt { get; set; }

        public int FlightId { get; set; }

        public string CompanyName { get; set; } = null!;
    }
}
